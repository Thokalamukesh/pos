import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../models/order_models.dart';
import '../../models/pos_bootstrap.dart';
import '../../models/pos_terminal.dart';
import '../../models/printer_config.dart';
import '../../repositories/order_repository.dart';
import '../../repositories/offline_order_repository.dart';
import '../../repositories/pos_menu_repository.dart';
import '../../repositories/printer_repository.dart';
import '../../repositories/shift_repository.dart';
import '../../services/fullscreen/fullscreen_service.dart';
import '../../services/offline_order_sync_service.dart';
import '../../services/smartpos_customer_display_service.dart';
import '../../theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../auth/login_screen.dart';
import '../bootstrap/bootstrap_providers.dart';
import '../customer_display/presentation/customer_display_page.dart';
import '../display/kitchen_display_screen.dart';
import '../terminal/terminal_controller.dart';
import '../terminal/terminal_selection_screen.dart';

class PosShellScreen extends ConsumerWidget {
  const PosShellScreen({super.key});

  static const routePath = '/pos';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final terminal = ref.watch(terminalContextProvider).asData?.value;
    final bootstrap = ref.watch(posBootstrapProvider);

    if (terminal == null) {
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.point_of_sale, size: 54),
                const SizedBox(height: 16),
                Text(
                  'Select POS terminal',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This device is paired, but no terminal is selected for this session.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () =>
                      context.go(TerminalSelectionScreen.routePath),
                  icon: const Icon(Icons.point_of_sale),
                  label: const Text('Choose terminal'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SizedBox.expand(
        child: bootstrap.when(
          data: (data) => SizedBox.expand(
            child: _PosWorkspace(data: data, terminal: terminal),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 48),
                  const SizedBox(height: 12),
                  Text(_errorMessage(error), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => ref.invalidate(posBootstrapProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PosWorkspace extends ConsumerStatefulWidget {
  const _PosWorkspace({required this.data, required this.terminal});

  final PosBootstrap data;
  final TerminalContext terminal;

  @override
  ConsumerState<_PosWorkspace> createState() => _PosWorkspaceState();
}

class _PosWorkspaceState extends ConsumerState<_PosWorkspace> {
  final _searchController = TextEditingController();
  final _orderNoteController = TextEditingController();
  final List<_CartLine> _cart = [];
  final List<_HeldTicket> _heldTickets = [];

  String? _activeCategoryId;
  String _orderType = 'dine_in';
  final String _viewMode = 'grid';
  String? _customerName;
  String? _customerPhone;
  String? _customerAddress;
  String? _orderNotes;
  String? _expandedCartLineKey;
  String? _selectedProductId;
  _Discount? _discount;
  bool _orderTypeExpanded = false;
  bool _customerSearchVisible = false;
  bool _orderNoteEditorVisible = false;
  bool _darkMode = false;
  Map<String, dynamic>? _currentShift;
  List<Map<String, dynamic>>? _menuCategoryData;
  bool _isCharging = false;
  bool _shiftBusy = false;
  int _nextHeldToken = 1;
  Timer? _displaySyncDebounce;
  Timer? _selectedProductResetTimer;
  Timer? _noticeTimer;
  Timer? _orderPollTimer;
  OverlayEntry? _noticeEntry;
  Set<String> _knownOpenOrders = const {};
  bool _orderPollPrimed = false;
  @override
  void initState() {
    super.initState();
    _currentShift = _extractShift(widget.data.currentShift ?? const {});
    _setFirstCategory();
    _searchController.addListener(() => setState(() {}));
    unawaited(_loadMenuCategories());
    _startOrderPolling();
  }

  @override
  void didUpdateWidget(covariant _PosWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.currentShift != widget.data.currentShift) {
      _currentShift = _extractShift(widget.data.currentShift ?? const {});
    }
    if (oldWidget.terminal.branchId != widget.terminal.branchId ||
        oldWidget.data.sync?.menuRevision != widget.data.sync?.menuRevision) {
      if (oldWidget.terminal.branchId != widget.terminal.branchId) {
        _menuCategoryData = null;
      }
      unawaited(_loadMenuCategories());
    }
    if (!_categories.any((category) => category.id == _activeCategoryId)) {
      _setFirstCategory();
    }
  }

  @override
  void dispose() {
    _displaySyncDebounce?.cancel();
    _selectedProductResetTimer?.cancel();
    _noticeTimer?.cancel();
    _orderPollTimer?.cancel();
    _noticeEntry?.remove();
    _searchController.dispose();
    _orderNoteController.dispose();
    super.dispose();
  }

  List<_CatalogCategory> get _categories {
    final source = _mergedCategoryData(
      widget.data.categories,
      _menuCategoryData,
    );
    return source
        .map(_CatalogCategory.fromJson)
        .where((category) => category.id.isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> _mergedCategoryData(
    List<Map<String, dynamic>> bootstrap,
    List<Map<String, dynamic>>? refreshed,
  ) {
    final byKey = <String, Map<String, dynamic>>{};
    final order = <String>[];

    void absorb(Map<String, dynamic> rawCategory) {
      final key = _categoryDataKey(rawCategory);
      if (key.isEmpty) {
        return;
      }

      final incoming = Map<String, dynamic>.from(rawCategory);
      final existing = byKey[key];
      if (existing == null) {
        byKey[key] = incoming;
        order.add(key);
        return;
      }

      final merged = <String, dynamic>{...existing, ...incoming};
      if (!_categoryDataHasItems(incoming) && _categoryDataHasItems(existing)) {
        for (final itemKey in const [
          'items',
          'menu_items',
          'menuItems',
          'products',
        ]) {
          if (existing.containsKey(itemKey)) {
            merged[itemKey] = existing[itemKey];
            break;
          }
        }
      }
      byKey[key] = merged;
    }

    for (final category in bootstrap) {
      absorb(category);
    }
    for (final category in refreshed ?? const <Map<String, dynamic>>[]) {
      absorb(category);
    }

    return [for (final key in order) byKey[key]!];
  }

  String _categoryDataKey(Map<String, dynamic> category) {
    return _stringValue(
      category['id'] ??
          category['category_id'] ??
          category['categoryId'] ??
          category['uuid'] ??
          category['slug'] ??
          category['name'] ??
          category['title'],
    );
  }

  bool _categoryDataHasItems(Map<String, dynamic> category) {
    return _firstMapList(category, const [
      'items',
      'menu_items',
      'menuItems',
      'products',
    ]).isNotEmpty;
  }

  List<_CatalogItem> get _allItems {
    return _categories.expand((category) => category.items).toList();
  }

  List<_CatalogItem> get _popularItems {
    final allById = {for (final item in _allItems) item.id: item};
    final mapped = widget.data.popularItems
        .map((item) => _CatalogItem.fromJson(item, categoryName: 'Popular'))
        .where((item) => item.id.isNotEmpty)
        .map((item) => allById[item.id] ?? item)
        .toList();
    return mapped.isNotEmpty ? mapped : _allItems.take(12).toList();
  }

  List<_CatalogItem> get _visibleItems {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      return _allItems.where((item) {
        return item.name.toLowerCase().contains(query) ||
            item.categoryName.toLowerCase().contains(query) ||
            (item.barcode?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    return _categories
        .where((category) => category.id == _activeCategoryId)
        .expand((category) => category.items)
        .toList();
  }

  String get _currencyCode {
    final value = widget.data.restaurant?.defaultCurrency?.trim();
    return value == null || value.isEmpty ? 'INR' : value;
  }

  NumberFormat get _money => NumberFormat.simpleCurrency(name: _currencyCode);

  double get _subtotal => _cart.fold(0, (sum, line) => sum + line.total);

  double get _discountAmount {
    final discount = _discount;
    if (discount == null || discount.value <= 0 || _subtotal <= 0) {
      return 0;
    }
    final amount = discount.type == 'percent'
        ? _subtotal * discount.value / 100
        : discount.value;
    return amount.clamp(0, _subtotal);
  }

  double get _payable =>
      (_subtotal - _discountAmount).clamp(0, double.infinity);

  void _setFirstCategory() {
    final categories = _categories;
    if (categories.isNotEmpty) {
      _activeCategoryId = categories
          .firstWhere(
            (category) => category.items.isNotEmpty,
            orElse: () => categories.first,
          )
          .id;
    }
  }

  void _selectCategory(String id) {
    setState(() {
      _activeCategoryId = id;
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
      }
    });
  }

  Future<void> _loadMenuCategories() async {
    try {
      final categories = await ref
          .read(posMenuRepositoryProvider)
          .fetchCategories();
      if (!mounted || categories.isEmpty) {
        return;
      }
      setState(() {
        _menuCategoryData = _mergedCategoryData(
          _menuCategoryData ?? const <Map<String, dynamic>>[],
          categories,
        );
        if (!_categories.any((category) => category.id == _activeCategoryId)) {
          _setFirstCategory();
        }
      });
    } on Object {
      // Bootstrap menu remains the fallback if /pos/menu is unavailable.
    }
  }

  void _startOrderPolling() {
    _orderPollTimer?.cancel();
    unawaited(_pollOpenOrders());
    _orderPollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      unawaited(_pollOpenOrders());
    });
  }

  Future<void> _pollOpenOrders() async {
    try {
      final orders = await ref
          .read(posOrderRepositoryProvider)
          .fetchOpenOrders();
      final keys = orders.map(_orderKey).where((key) => key.isNotEmpty).toSet();
      if (!_orderPollPrimed) {
        _knownOpenOrders = keys;
        _orderPollPrimed = true;
        return;
      }
      final newCount = keys.difference(_knownOpenOrders).length;
      _knownOpenOrders = keys;
      if (newCount > 0 && mounted) {
        _showNotice(
          '$newCount new ${newCount == 1 ? 'order' : 'orders'} received',
        );
      }
    } on Object {
      // Polling is non-critical.
    }
  }

  Future<void> _openCustomerDisplay() async {
    await context.push(CustomerDisplayPage.routePath);
  }

  Future<void> _openDisplayLauncher() async {
    final action = await showDialog<_DisplayLaunchAction>(
      context: context,
      builder: (context) => const _DisplayLauncherDialog(),
    );
    if (!mounted || action == null) {
      return;
    }
    switch (action) {
      case _DisplayLaunchAction.kitchen:
        context.push(KitchenDisplayScreen.routePath);
      case _DisplayLaunchAction.customer:
        await _openCustomerDisplay();
    }
  }

  void _queueDisplaySync({bool clear = false}) {
    _displaySyncDebounce?.cancel();
  }

  Future<void> _toggleFullscreen() async {
    try {
      await toggleFullscreen();
    } on Object catch (error) {
      _showSnack(_errorMessage(error), isError: true);
    }
  }

  Future<void> _openPrinterSetup() async {
    final initial = ref.read(printerConfigProvider).asData?.value;
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => _PrinterSetupDialog(initial: initial),
    );
    if (changed == true) {
      ref.invalidate(printerConfigProvider);
    }
  }

  Future<void> _openShift() async {
    if (_shiftBusy) {
      return;
    }
    final request = await showDialog<_OpenShiftRequest>(
      context: context,
      builder: (context) => const _OpenShiftDialog(),
    );
    if (request == null) {
      return;
    }
    setState(() => _shiftBusy = true);
    try {
      final result = await ref
          .read(shiftRepositoryProvider)
          .open(
            openingCashFloat: request.openingCashFloat,
            notes: request.notes,
          );
      if (!mounted) {
        return;
      }
      var nextShift = _extractShift(result);
      if (nextShift == null) {
        try {
          nextShift = _extractShift(
            await ref.read(shiftRepositoryProvider).current(),
          );
        } on Object {
          nextShift = result.isEmpty
              ? <String, dynamic>{'status': 'open'}
              : result;
        }
      }
      setState(() => _currentShift = nextShift);
      ref.invalidate(posBootstrapProvider);
      _showNotice('Shift opened.');
    } on Object catch (error) {
      _showSnack(_errorMessage(error), isError: true);
    } finally {
      if (mounted) {
        setState(() => _shiftBusy = false);
      }
    }
  }

  Future<void> _closeShift() async {
    if (_shiftBusy) {
      return;
    }
    Map<String, dynamic> summary = const {};
    try {
      summary = await ref.read(shiftRepositoryProvider).summary();
    } on Object {
      summary = const {};
    }
    if (!mounted) {
      return;
    }
    final request = await showDialog<_CloseShiftRequest>(
      context: context,
      builder: (context) => _CloseShiftDialog(summary: summary, money: _money),
    );
    if (request == null) {
      return;
    }
    setState(() => _shiftBusy = true);
    try {
      await ref
          .read(shiftRepositoryProvider)
          .close(countedCash: request.countedCash, notes: request.notes);
      if (!mounted) {
        return;
      }
      setState(() => _currentShift = null);
      ref.invalidate(posBootstrapProvider);
      final paidOrders = _summaryInt(summary, const [
        'paid_orders',
        'paid_orders_count',
        'orders_count',
        'count',
      ]);
      final expectedCash = _closeShiftExpected(summary);
      final variance = request.countedCash - expectedCash;
      final varianceState = variance < -0.005 ? 'short' : 'over';
      final varianceText = variance.abs().toStringAsFixed(2);
      final orderText = paidOrders == 1
          ? '1 paid order'
          : '$paidOrders paid orders';
      _showNotice(
        paidOrders > 0
            ? 'Shift closed. $orderText - Cash variance: $varianceText $varianceState.'
            : 'Shift closed.',
      );
    } on Object catch (error) {
      _showSnack(_errorMessage(error), isError: true);
    } finally {
      if (mounted) {
        setState(() => _shiftBusy = false);
      }
    }
  }

  Future<void> _editDiscount() async {
    final discount = await showDialog<_Discount?>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (context) => _DiscountDialog(
        initial: _discount,
        subtotal: _subtotal,
        money: _money,
      ),
    );
    if (discount == null) {
      return;
    }
    setState(() => _discount = discount.value <= 0 ? null : discount);
    _queueDisplaySync();
  }

  void _editOrderNotes() {
    setState(() {
      _orderNoteEditorVisible = true;
      _orderNoteController.text = _orderNotes ?? '';
      _orderNoteController.selection = TextSelection.collapsed(
        offset: _orderNoteController.text.length,
      );
    });
  }

  void _updateOrderNotes(String value) {
    setState(() => _orderNotes = _nullableString(value));
    _queueDisplaySync();
  }

  Future<void> _editLineNote(_CartLine line) async {
    final note = await _textDialog(
      title: 'Line note',
      initialValue: line.note,
      hintText: 'No onion, extra spicy, etc.',
    );
    if (note == null) {
      return;
    }
    setState(() {
      final index = _cart.indexOf(line);
      if (index >= 0) {
        _cart[index] = line.copyWith(note: _nullableString(note));
      }
    });
    _queueDisplaySync();
  }

  Future<String?> _textDialog({
    required String title,
    String? initialValue,
    String? hintText,
  }) {
    final controller = TextEditingController(text: initialValue ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(hintText: hintText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addItem(_CatalogItem item) {
    _flashProductSelection(item.id);
    if (item.hasChoices) {
      unawaited(_configureAndAddItem(item));
      return;
    }
    _addCartLine(_CartLine(item: item));
  }

  void _flashProductSelection(String itemId) {
    if (itemId.isEmpty) {
      return;
    }
    _selectedProductResetTimer?.cancel();
    setState(() => _selectedProductId = itemId);
    _selectedProductResetTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted || _selectedProductId != itemId) {
        return;
      }
      setState(() => _selectedProductId = null);
    });
  }

  Future<void> _configureAndAddItem(_CatalogItem item) async {
    final selection = await showDialog<_ItemChoiceSelection>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (context) => _ItemOptionsDialog(item: item, money: _money),
    );
    if (selection == null || !mounted) {
      return;
    }
    _addCartLine(
      _CartLine(
        item: item,
        note: selection.note,
        variant: selection.variant,
        modifiers: selection.modifiers,
      ),
    );
  }

  void _addCartLine(_CartLine nextLine) {
    setState(() {
      final existingIndex = _cart.indexWhere((line) => line.matches(nextLine));
      late final _CartLine expandedLine;
      if (existingIndex >= 0) {
        final line = _cart[existingIndex];
        expandedLine = line.copyWith(quantity: line.quantity + 1);
        _cart[existingIndex] = expandedLine;
      } else {
        _cart.add(nextLine);
        expandedLine = nextLine;
      }
      _expandedCartLineKey = _cartLineIdentity(expandedLine);
    });
    _queueDisplaySync();
  }

  void _changeQuantity(_CartLine line, int delta) {
    setState(() {
      final index = _cart.indexOf(line);
      if (index < 0) {
        return;
      }
      final next = line.quantity + delta;
      if (next <= 0) {
        final removedKey = _cartLineIdentity(line);
        _cart.removeAt(index);
        if (_expandedCartLineKey == removedKey) {
          _expandedCartLineKey = null;
        }
      } else {
        _cart[index] = line.copyWith(quantity: next);
      }
    });
    _queueDisplaySync(clear: _cart.isEmpty);
  }

  void _removeLine(_CartLine line) {
    setState(() {
      final removedKey = _cartLineIdentity(line);
      _cart.remove(line);
      if (_expandedCartLineKey == removedKey) {
        _expandedCartLineKey = null;
      }
    });
    _queueDisplaySync(clear: _cart.isEmpty);
  }

  void _toggleCartLineExpansion(_CartLine line) {
    final key = _cartLineIdentity(line);
    setState(() {
      _expandedCartLineKey = _expandedCartLineKey == key ? null : key;
    });
  }

  void _clearCart() {
    if (_cart.isEmpty) {
      return;
    }
    setState(_clearOrderState);
    _queueDisplaySync(clear: true);
  }

  void _setInlineCustomer(String value) {
    final text = _nullableString(value);
    if (text == null) {
      return;
    }
    setState(() {
      _customerName = text;
      _customerSearchVisible = false;
    });
    _queueDisplaySync();
  }

  void _holdOrder() {
    if (_cart.isEmpty) {
      return;
    }
    setState(() {
      _heldTickets.add(
        _HeldTicket(
          token: _nextHeldToken++,
          lines: List<_CartLine>.of(_cart),
          orderType: _orderType,
          customerName: _customerName,
          customerPhone: _customerPhone,
          customerAddress: _customerAddress,
          orderNotes: _orderNotes,
          discount: _discount,
          createdAt: DateTime.now(),
        ),
      );
      _clearOrderState();
    });
    _queueDisplaySync(clear: true);
    _showSnack('Order held.');
  }

  Future<void> _openTicketsDrawer() async {
    final ticket = await showGeneralDialog<_HeldTicket>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Open tickets',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _HeldTicketsOverlay(tickets: _heldTickets, money: _money);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
    if (ticket == null) {
      return;
    }
    setState(() {
      _heldTickets.remove(ticket);
      _cart
        ..clear()
        ..addAll(ticket.lines);
      _orderType = ticket.orderType;
      _customerName = ticket.customerName;
      _customerPhone = ticket.customerPhone;
      _customerAddress = ticket.customerAddress;
      _orderNotes = ticket.orderNotes;
      _orderNoteController.text = ticket.orderNotes ?? '';
      _orderNoteEditorVisible = ticket.orderNotes != null;
      _discount = ticket.discount;
      _expandedCartLineKey = null;
    });
    _queueDisplaySync();
  }

  Future<void> _proceedToPayment() async {
    if (_cart.isEmpty || _isCharging) {
      return;
    }
    if (widget.data.requireShiftForPos && _currentShift == null) {
      _showSnack('Open shift before checkout.', isError: true);
      await _openShift();
      return;
    }
    final printerConfig = ref.read(printerConfigProvider).asData?.value;
    if (printerConfig == null || !printerConfig.hasDeviceIdentity) {
      _showSnack('Configure receipt printer before checkout.', isError: true);
      await _openPrinterSetup();
      return;
    }
    unawaited(
      ref
          .read(printerRepositoryProvider)
          .warmUp(printerConfig)
          .catchError((Object _) {}),
    );
    final payment = await showDialog<_PaymentSelection>(
      context: context,
      builder: (context) => _PaymentDialog(total: _payable, money: _money),
    );
    if (payment == null) {
      return;
    }
    if (payment.method == 'upi') {
      _debugUpiQr(
        'payment selected total=$_payable items=${_cart.length} '
        'register=${_registerPaymentFor(payment)?.toJson()}',
      );
    }
    final request = _orderRequest(payment);

    setState(() => _isCharging = true);
    try {
      if (payment.method == 'upi') {
        _debugUpiQr(
          'creating order type=${request.type} terminal=${request.posTerminalCode} '
          'items=${request.items.length} register=${request.posRegisterPayment?.toJson()}',
        );
      }
      final order = await ref
          .read(posOrderRepositoryProvider)
          .createOrder(request);
      if (payment.method == 'upi') {
        _debugUpiQr(
          'order created id=${order.id} number=${order.displayNumber} '
          'total=${order.total}',
        );
      }

      Object? paymentError;
      Object? displayError;
      bool paymentConfirmed = payment.method != 'upi';
      PosOrderPaymentResult? upiPayment;
      if (payment.method == 'upi') {
        final orderId = order.id;
        if (orderId == null) {
          paymentError = const AppException(
            message: 'Order saved but order id was not returned.',
          );
        } else {
          try {
            upiPayment = PosOrderPaymentResult.fromResponse(order.raw);
            _debugUpiQr(
              'order create payment gateway=${upiPayment.gateway} '
              'status=${upiPayment.paymentStatus} '
              'qrLen=${upiPayment.qrText?.length ?? 0} '
              'upi=${upiPayment.qrText?.startsWith('upi://') ?? false}',
            );
            if (upiPayment.qrText == null || upiPayment.qrText!.isEmpty) {
              try {
                _debugUpiQr(
                  'order create missing QR, fetching documented payment QR '
                  'gateway=${upiPayment.gateway ?? 'phonepe'}',
                );
                final paymentQr = await ref
                    .read(posOrderRepositoryProvider)
                    .fetchPaymentQr(
                      orderId,
                      gateway: upiPayment.gateway ?? 'phonepe',
                    );
                _debugUpiQr(
                  'documented QR response gateway=${paymentQr.gateway} '
                  'status=${paymentQr.paymentStatus} '
                  'qrLen=${paymentQr.qrText?.length ?? 0} '
                  'upi=${paymentQr.qrText?.startsWith('upi://') ?? false}',
                );
                upiPayment = paymentQr;
              } on Object catch (error) {
                _debugUpiQr(
                  'documented QR endpoint failed=${_errorMessage(error)}',
                );
                rethrow;
              }
            }
            final resolvedUpiPayment = upiPayment;
            final qr = resolvedUpiPayment.qrText;
            if (qr == null || qr.isEmpty) {
              throw const AppException(
                message: 'UPI payment QR was not returned.',
              );
            }
            String? displayMode;
            try {
              _debugUpiQr('sending QR to customer display orderId=$orderId');
              displayMode = await showSmartPosUpiQr(
                qr: qr,
                orderNumber:
                    resolvedUpiPayment.orderNumber ?? order.displayNumber,
                amount: resolvedUpiPayment.total ?? order.total,
                payeeName: resolvedUpiPayment.payeeName,
                upiId: resolvedUpiPayment.displayUpiId,
                timeoutSeconds: resolvedUpiPayment.timeoutSeconds,
              );
              _debugUpiQr('customer display mode=$displayMode');
            } on Object catch (error) {
              displayError = error;
              _debugUpiQr('customer display error=${_errorMessage(error)}');
            }

            final paymentFuture = _waitForUpiPayment(
              orderId,
              initial: resolvedUpiPayment,
              timeoutSeconds: resolvedUpiPayment.timeoutSeconds,
            );
            final subDisplayReady = _isUpiQrSubDisplayMode(displayMode);
            if (subDisplayReady) {
              _debugUpiQr('sub display ready, waiting for payment status');
              await paymentFuture;
              paymentConfirmed = true;
            } else {
              _debugUpiQr(
                'sub display not ready mode=$displayMode, showing POS dialog',
              );
              if (!mounted) {
                return;
              }
              final paid = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => _UpiQrPaymentDialog(
                  qr: qr,
                  orderNumber: upiPayment?.orderNumber ?? order.displayNumber,
                  amount: upiPayment?.total ?? order.total ?? _payable,
                  money: _money,
                  payeeName: upiPayment?.payeeName,
                  upiId: upiPayment?.displayUpiId,
                  paymentFuture: paymentFuture,
                ),
              );
              paymentConfirmed = paid == true;
              _debugUpiQr('POS QR dialog closed paid=$paymentConfirmed');
              if (!paymentConfirmed) {
                throw const AppException(
                  message: 'UPI payment was not confirmed.',
                );
              }
            }
          } on Object catch (error) {
            paymentError = error;
            _debugUpiQr('UPI flow error=${_errorMessage(error)}');
          }
        }
      }

      Object? printError;
      int? printedBytes;
      final orderId = order.id;
      if (payment.method == 'upi' && !paymentConfirmed) {
        printError = null;
      } else if (orderId == null) {
        printError = const AppException(
          message: 'Order saved but receipt id was not returned.',
        );
      } else {
        try {
          final receipt = await ref
              .read(posOrderRepositoryProvider)
              .fetchReceipt(orderId);
          printedBytes = await ref
              .read(printerRepositoryProvider)
              .printReceipt(
                receipt,
                currencyCode: _currencyCode,
                config: printerConfig,
              );
        } on Object catch (error) {
          printError = error;
        }
      }

      if (paymentConfirmed) {
        unawaited(
          clearSmartPosCustomerDisplay().catchError((Object error) {
            displayError ??= error;
          }),
        );
      }

      if (!mounted) {
        return;
      }
      setState(_clearOrderState);
      _queueDisplaySync(clear: true);
      if (payment.method == 'upi' &&
          paymentError == null &&
          printError == null) {
        final suffix = printedBytes == null ? '' : ' Receipt printed.';
        _showNotice('UPI payment received.$suffix');
      } else if (printError == null) {
        final suffix = printedBytes == null ? '' : ' Receipt printed.';
        _showNotice('Order ${order.displayNumber} placed.$suffix');
      } else {
        _showNotice('Order ${order.displayNumber} placed.');
      }
      if (paymentError != null) {
        _showSnack(
          'UPI QR failed: ${_errorMessage(paymentError)}',
          isError: true,
        );
      } else if (displayError != null && payment.method != 'upi') {
        _showSnack(
          'Customer display failed: ${_errorMessage(displayError!)}',
          isError: true,
        );
      }
      if (printError != null) {
        _showSnack('Print failed: ${_errorMessage(printError)}', isError: true);
      }
    } on Object catch (error) {
      final queued = await _queueOfflineOrderIfNeeded(
        error: error,
        payment: payment,
        request: request,
      );
      if (queued) {
        return;
      }
      if (mounted) {
        final message =
            payment.method == 'upi' && error is AppException && error.isNetwork
            ? 'UPI QR needs internet. Use cash/card offline, or try UPI when online.'
            : _errorMessage(error);
        _showSnack(message, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isCharging = false);
      }
    }
  }

  Future<bool> _queueOfflineOrderIfNeeded({
    required Object error,
    required _PaymentSelection payment,
    required CreatePosOrderRequest request,
  }) async {
    if (payment.method == 'upi' || error is! AppException || !error.isNetwork) {
      return false;
    }
    try {
      final queued = await ref
          .read(offlineOrderRepositoryProvider)
          .enqueue(
            request: request,
            paymentMethod: payment.method,
            total: _payable,
          );
      unawaited(ref.read(offlineOrderSyncServiceProvider).syncNow());
      if (!mounted) {
        return true;
      }
      setState(_clearOrderState);
      _queueDisplaySync(clear: true);
      _showNotice(
        'Offline order saved (${queued.localId}). It will sync when internet returns.',
      );
      return true;
    } on Object catch (queueError) {
      if (mounted) {
        _showSnack(
          'Offline save failed: ${_errorMessage(queueError)}',
          isError: true,
        );
      }
      return true;
    }
  }

  Future<PosOrderPaymentResult> _waitForUpiPayment(
    int orderId, {
    required PosOrderPaymentResult initial,
    int? timeoutSeconds,
  }) async {
    if (_isPaidPaymentStatus(initial.paymentStatus)) {
      return initial;
    }
    final seconds = timeoutSeconds == null || timeoutSeconds <= 0
        ? 180
        : timeoutSeconds.clamp(15, 600);
    final deadline = DateTime.now().add(Duration(seconds: seconds));
    Object? lastError;

    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(seconds: 3));
      try {
        final status = await ref
            .read(posOrderRepositoryProvider)
            .fetchPaymentStatus(orderId);
        if (_isPaidPaymentStatus(status.paymentStatus)) {
          return status;
        }
        if (_isFailedPaymentStatus(status.paymentStatus)) {
          throw AppException(message: 'UPI payment ${status.paymentStatus}.');
        }
      } on Object catch (error) {
        lastError = error;
        if (error is AppException &&
            error.statusCode != null &&
            error.statusCode! < 500 &&
            error.statusCode != 404 &&
            error.statusCode != 405 &&
            error.statusCode != 429) {
          rethrow;
        }
      }
    }

    if (lastError != null) {
      throw AppException(
        message: 'UPI payment was not confirmed: ${_errorMessage(lastError)}',
      );
    }
    throw const AppException(
      message: 'UPI payment was not confirmed before the QR expired.',
    );
  }

  bool _isPaidPaymentStatus(String? status) {
    final value = status?.trim().toLowerCase();
    return value == 'paid' ||
        value == 'success' ||
        value == 'successful' ||
        value == 'completed' ||
        value == 'captured' ||
        value == 'settled';
  }

  bool _isFailedPaymentStatus(String? status) {
    final value = status?.trim().toLowerCase();
    return value == 'failed' ||
        value == 'failure' ||
        value == 'cancelled' ||
        value == 'canceled' ||
        value == 'expired';
  }

  bool _isUpiQrSubDisplayMode(String? displayMode) {
    return displayMode == 'lcd' || displayMode == 'secondary_display';
  }

  CreatePosOrderRequest _orderRequest(_PaymentSelection payment) {
    return CreatePosOrderRequest(
      type: _orderType,
      posTerminalCode: widget.terminal.terminalCode,
      customerName: _customerName ?? 'Guest',
      customerPhone: _customerPhone,
      customerAddress: _customerAddress,
      notes: _orderNotes,
      discount: _discount?.toApiPayload(),
      items: _cart.map((line) {
        return PosOrderItemRequest(
          menuItemId: apiIdentifierFromString(line.item.id),
          variantId: line.variant == null
              ? null
              : apiIdentifierFromString(line.variant!.id),
          quantity: line.quantity,
          notes: line.note,
          modifiers: line.modifiers.map((modifier) {
            return modifier.toApiPayload();
          }).toList(),
        );
      }).toList(),
      posRegisterPayment: _registerPaymentFor(payment),
    );
  }

  PosRegisterPayment? _registerPaymentFor(_PaymentSelection payment) {
    if (payment.method == 'pay_later') {
      return null;
    }
    final method = payment.method == 'upi' ? 'phonepe' : payment.method;
    return PosRegisterPayment(
      method: method,
      cashTendered: payment.method == 'cash' ? payment.cashTendered : null,
      tip: payment.tip,
    );
  }

  void _debugUpiQr(String message) {
    debugPrint('[UPI_QR][POS] $message');
  }

  void _clearOrderState() {
    _cart.clear();
    _customerName = null;
    _customerPhone = null;
    _customerAddress = null;
    _orderNotes = null;
    _expandedCartLineKey = null;
    _orderNoteController.clear();
    _orderNoteEditorVisible = false;
    _discount = null;
    _isCharging = false;
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : colors.inverseSurface,
      ),
    );
  }

  void _showNotice(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }
    final colors = Theme.of(context).colorScheme;
    _noticeTimer?.cancel();
    _noticeEntry?.remove();
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.paddingOf(context).top + 86,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 330,
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(
                color: isError
                    ? colors.error.withValues(alpha: 0.32)
                    : const Color(0xFF86EFAC),
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isError
                      ? colors.errorContainer
                      : const Color(0xFFDCFCE7),
                  child: Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: isError ? colors.error : const Color(0xFF059669),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () {
                    _noticeTimer?.cancel();
                    _noticeEntry?.remove();
                    _noticeEntry = null;
                  },
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    _noticeEntry = entry;
    _noticeTimer = Timer(const Duration(seconds: 4), () {
      _noticeEntry?.remove();
      _noticeEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categories;
    final visibleItems = _visibleItems;
    final searchQuery = _searchController.text.trim();
    final activeCategoryName = categories
        .where((category) => category.id == _activeCategoryId)
        .map((category) => category.name)
        .firstOrNull;
    final showPopular =
        searchQuery.isEmpty &&
        (categories.isEmpty || _activeCategoryId == categories.first.id);
    final printerConfig = ref.watch(printerConfigProvider).asData?.value;
    final session = ref.watch(authControllerProvider).asData?.value;
    final staffName = _activeStaffName(
      _currentShift,
      fallback: session?.user.name,
    );

    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 1050;
          const cartWidth = 440.0;
          final ticketItemCount = _cart.fold<int>(
            0,
            (sum, line) => sum + line.quantity,
          );
          final selectedItemIds = _selectedProductId == null
              ? const <String>{}
              : <String>{_selectedProductId!};
          final catalog = _CatalogPanel(
            searchController: _searchController,
            items: visibleItems,
            popularItems: _popularItems,
            money: _money,
            viewMode: _viewMode,
            searchQuery: searchQuery,
            activeCategoryName: activeCategoryName,
            showPopular: showPopular,
            ticketItemCount: ticketItemCount,
            selectedItemIds: selectedItemIds,
            onAdd: _addItem,
          );
          final cart = _CartPanel(
            lines: _cart,
            money: _money,
            orderType: _orderType,
            subtotal: _subtotal,
            discountAmount: _discountAmount,
            payable: _payable,
            customerName: _customerName,
            orderNotes: _orderNotes,
            orderNoteEditorVisible: _orderNoteEditorVisible,
            orderNoteController: _orderNoteController,
            isCharging: _isCharging,
            customerSearchVisible: _customerSearchVisible,
            orderTypeExpanded: _orderTypeExpanded,
            heldTicketCount: _heldTickets.length,
            onCustomer: () => setState(() => _customerSearchVisible = true),
            onCustomerSubmitted: _setInlineCustomer,
            onToggleOrderType: () =>
                setState(() => _orderTypeExpanded = !_orderTypeExpanded),
            onOpenTickets: _openTicketsDrawer,
            onClearCart: _clearCart,
            onOrderTypeChanged: (value) {
              setState(() {
                _orderType = value;
                _orderTypeExpanded = false;
              });
              _queueDisplaySync();
            },
            onDiscount: _editDiscount,
            onOrderNotes: _editOrderNotes,
            onOrderNotesChanged: _updateOrderNotes,
            expandedLineKey: _expandedCartLineKey,
            onToggleLine: _toggleCartLineExpansion,
            onQuantityChanged: _changeQuantity,
            onLineNote: _editLineNote,
            onRemove: _removeLine,
            onHold: _holdOrder,
            onProceed: _proceedToPayment,
          );

          final shiftStrip = _ShiftStrip(
            currentShift: _currentShift,
            terminalCode: widget.terminal.terminalCode,
            printerConfig: printerConfig,
            shiftBusy: _shiftBusy,
            onOpenShift: _openShift,
            onCloseShift: _closeShift,
            onPrinterTap: _openPrinterSetup,
            onSwitchTerminal: () =>
                context.go(TerminalSelectionScreen.routePath),
          );

          return Theme(
            data: _darkMode ? AppTheme.dark() : Theme.of(context),
            child: Column(
              children: [
                _PosHeader(
                  data: widget.data,
                  terminal: widget.terminal,
                  staffName: staffName,
                  onDisplayLauncher: _openDisplayLauncher,
                  onCustomerDisplay: _openCustomerDisplay,
                  darkMode: _darkMode,
                  onToggleTheme: () => setState(() => _darkMode = !_darkMode),
                  onFullscreen: _toggleFullscreen,
                  onLogout: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) {
                      context.go(LoginScreen.routePath);
                    }
                  },
                ),
                Expanded(
                  child: compact
                      ? Column(
                          children: [
                            SizedBox(
                              height: 112,
                              child: _CategoryRail(
                                categories: categories,
                                activeCategoryId: _activeCategoryId,
                                onSelected: _selectCategory,
                                horizontal: true,
                              ),
                            ),
                            shiftStrip,
                            Expanded(child: ClipRect(child: catalog)),
                            SizedBox(height: 390, child: cart),
                          ],
                        )
                      : Row(
                          children: [
                            _CategoryRail(
                              categories: categories,
                              activeCategoryId: _activeCategoryId,
                              onSelected: _selectCategory,
                            ),
                            Expanded(
                              child: ClipRect(
                                child: Column(
                                  children: [
                                    shiftStrip,
                                    Expanded(child: ClipRect(child: catalog)),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: cartWidth, child: cart),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PosLogoMark extends StatelessWidget {
  const _PosLogoMark();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/images/mainlogo.png',
        width: 48,
        height: 48,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _PosHeader extends StatelessWidget {
  const _PosHeader({
    required this.data,
    required this.terminal,
    required this.staffName,
    required this.onDisplayLauncher,
    required this.onCustomerDisplay,
    required this.darkMode,
    required this.onToggleTheme,
    required this.onFullscreen,
    required this.onLogout,
  });

  final PosBootstrap data;
  final TerminalContext terminal;
  final String staffName;
  final VoidCallback onDisplayLauncher;
  final VoidCallback onCustomerDisplay;
  final bool darkMode;
  final VoidCallback onToggleTheme;
  final VoidCallback onFullscreen;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final branchName = data.branch?.name ?? 'Branch';
    final restaurantName = data.restaurant?.name ?? 'Restaurant';
    final staff = staffName.trim();
    final breadcrumbParts = [
      restaurantName,
      branchName,
      if (staff.isNotEmpty) staff,
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1120;
        final tight = constraints.maxWidth < 820;
        final iconButtonStyle = IconButton.styleFrom(
          fixedSize: const Size(42, 42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        );

        return Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              const _PosLogoMark(),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Flexible(
                          child: Text(
                            'POS Terminal',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _Badge(
                          text: 'POS',
                          color: const Color(0xFFE0E7FF),
                          textColor: const Color(0xFF4F46E5),
                        ),
                      ],
                    ),
                    Text(
                      breadcrumbParts.join(' \u00B7 '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (!tight) ...[
                SizedBox(
                  height: 42,
                  child: compact
                      ? IconButton(
                          style: iconButtonStyle,
                          tooltip: 'Order History',
                          onPressed: onCustomerDisplay,
                          icon: const Icon(
                            Icons.connected_tv_outlined,
                            size: 19,
                            color: Color(0xFF10B981),
                          ),
                        )
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            shadowColor: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.20),
                            foregroundColor: const Color(0xFF111827),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: onCustomerDisplay,
                          icon: const Icon(
                            Icons.connected_tv_outlined,
                            color: Color(0xFF10B981),
                          ),
                          label: const Text('Order History'),
                        ),
                ),
                const SizedBox(width: 8),
              ],
              SizedBox(
                height: 42,
                child: tight
                    ? IconButton(
                        style: iconButtonStyle,
                        tooltip: 'Displays',
                        onPressed: onDisplayLauncher,
                        icon: const Icon(
                          Icons.dashboard_customize_outlined,
                          size: 19,
                          color: Color(0xFF4F46E5),
                        ),
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          shadowColor: const Color(
                            0xFF4F46E5,
                          ).withValues(alpha: 0.20),
                          foregroundColor: const Color(0xFF111827),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onDisplayLauncher,
                        icon: const Icon(
                          Icons.dashboard_customize_outlined,
                          color: Color(0xFF4F46E5),
                        ),
                        label: const Text('Displays'),
                      ),
              ),
              const SizedBox(width: 8),
              if (!tight) ...[
                if (!compact) ...[
                  _HeaderChip(
                    icon: Icons.location_on_outlined,
                    caption: 'Branch',
                    label: branchName,
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  style: compact ? iconButtonStyle : null,
                  tooltip: darkMode ? 'Light mode' : 'Dark mode',
                  onPressed: onToggleTheme,
                  icon: Icon(
                    darkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                ),
                IconButton(
                  style: compact ? iconButtonStyle : null,
                  tooltip: 'Fullscreen',
                  onPressed: onFullscreen,
                  icon: const Icon(Icons.fullscreen),
                ),
                const SizedBox(width: 8),
              ],
              SizedBox(
                width: tight ? 46 : null,
                height: 42,
                child: tight
                    ? FilledButton(
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: const Color(0xFFE11D48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: onLogout,
                        child: const Icon(Icons.logout),
                      )
                    : FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Exit POS'),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _DisplayLaunchAction { kitchen, customer }

class _DisplayLauncherDialog extends StatelessWidget {
  const _DisplayLauncherDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.dashboard_customize_outlined,
                    color: Color(0xFF4F46E5),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Open display',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _DisplayLaunchTile(
                icon: Icons.soup_kitchen_outlined,
                title: 'Kitchen Display',
                subtitle:
                    'Shows live orders and status controls for kitchen staff.',
                onTap: () =>
                    Navigator.of(context).pop(_DisplayLaunchAction.kitchen),
              ),
              const SizedBox(height: 10),
              _DisplayLaunchTile(
                icon: Icons.connected_tv_outlined,
                title: 'Order History',
                subtitle:
                    'Opens the full-screen order history for customer tokens.',
                onTap: () =>
                    Navigator.of(context).pop(_DisplayLaunchAction.customer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisplayLaunchTile extends StatelessWidget {
  const _DisplayLaunchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShiftStrip extends StatelessWidget {
  const _ShiftStrip({
    required this.currentShift,
    required this.terminalCode,
    required this.printerConfig,
    required this.shiftBusy,
    required this.onOpenShift,
    required this.onCloseShift,
    required this.onPrinterTap,
    required this.onSwitchTerminal,
  });

  final Map<String, dynamic>? currentShift;
  final String terminalCode;
  final PrinterConfig? printerConfig;
  final bool shiftBusy;
  final VoidCallback onOpenShift;
  final VoidCallback onCloseShift;
  final VoidCallback onPrinterTap;
  final VoidCallback onSwitchTerminal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final shiftOpen = currentShift != null;
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: shiftOpen ? const Color(0xFF10B981) : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: shiftOpen ? 'Shift' : 'No shift',
                  style: TextStyle(
                    color: shiftOpen ? const Color(0xFF059669) : Colors.orange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (shiftOpen)
                  TextSpan(
                    text: ' - ${_shiftLabel(currentShift)}',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const Spacer(),
          if (shiftOpen)
            SizedBox(
              height: 32,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE11D48),
                  backgroundColor: const Color(0xFFFFF1F2),
                  side: const BorderSide(color: Color(0xFFFECACA)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: shiftBusy ? null : onCloseShift,
                icon: shiftBusy
                    ? const SizedBox.square(
                        dimension: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_outline, size: 16),
                label: const Text('Close shift'),
              ),
            )
          else
            SizedBox(
              height: 32,
              child: FilledButton.tonalIcon(
                onPressed: shiftBusy ? null : onOpenShift,
                icon: shiftBusy
                    ? const SizedBox.square(
                        dimension: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_open, size: 16),
                label: const Text('Open shift'),
              ),
            ),
          const SizedBox(width: 12),
          IconButton(
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: EdgeInsets.zero,
            tooltip: printerConfig?.hasDeviceIdentity == true
                ? printerConfig!.name
                : 'Printer not set',
            onPressed: onPrinterTap,
            icon: const Icon(Icons.monitor_outlined, size: 17),
          ),
          const SizedBox(width: 4),
          SizedBox(
            height: 32,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onSwitchTerminal,
              child: Text(
                terminalCode,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRail extends StatefulWidget {
  const _CategoryRail({
    required this.categories,
    required this.activeCategoryId,
    required this.onSelected,
    this.horizontal = false,
  });

  final List<_CatalogCategory> categories;
  final String? activeCategoryId;
  final ValueChanged<String> onSelected;
  final bool horizontal;

  @override
  State<_CategoryRail> createState() => _CategoryRailState();
}

class _CategoryRailState extends State<_CategoryRail> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollActiveCategoryIntoView();
  }

  @override
  void didUpdateWidget(covariant _CategoryRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeCategoryId != widget.activeCategoryId ||
        oldWidget.categories.length != widget.categories.length ||
        oldWidget.horizontal != widget.horizontal) {
      _scrollActiveCategoryIntoView();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollActiveCategoryIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_scrollController.hasClients ||
          widget.activeCategoryId == null) {
        return;
      }
      final index = widget.categories.indexWhere(
        (category) => category.id == widget.activeCategoryId,
      );
      if (index < 0) {
        return;
      }

      final itemExtent = (widget.horizontal ? 100.0 : 104.0) + 14.0;
      final itemStart = index * itemExtent;
      final itemEnd = itemStart + (widget.horizontal ? 100.0 : 104.0);
      final position = _scrollController.position;
      final currentStart = position.pixels;
      final currentEnd = currentStart + position.viewportDimension;

      double? target;
      if (itemStart < currentStart) {
        target = itemStart;
      } else if (itemEnd > currentEnd) {
        target = itemEnd - position.viewportDimension;
      }
      if (target == null) {
        return;
      }
      _scrollController.animateTo(
        target
            .clamp(position.minScrollExtent, position.maxScrollExtent)
            .toDouble(),
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = ListView.separated(
      key: PageStorageKey<String>(
        widget.horizontal
            ? 'pos-category-rail-horizontal'
            : 'pos-category-rail',
      ),
      controller: _scrollController,
      primary: false,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: widget.horizontal ? 8 : 14,
      ),
      scrollDirection: widget.horizontal ? Axis.horizontal : Axis.vertical,
      itemCount: widget.categories.length,
      separatorBuilder: (context, index) => SizedBox(
        width: widget.horizontal ? 14 : 0,
        height: widget.horizontal ? 0 : 14,
      ),
      itemBuilder: (context, index) {
        final category = widget.categories[index];
        return SizedBox(
          width: 100,
          height: widget.horizontal ? 104 : 104,
          child: KeyedSubtree(
            key: ValueKey(category.id),
            child: _CategoryButton(
              category: category,
              active: category.id == widget.activeCategoryId,
              compact: widget.horizontal,
              onTap: () => widget.onSelected(category.id),
            ),
          ),
        );
      },
    );

    if (widget.horizontal) {
      return list;
    }

    return Container(
      width: 112,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Scrollbar(
        controller: _scrollController,
        thickness: 4,
        child: list,
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.category,
    required this.active,
    required this.compact,
    required this.onTap,
  });

  final _CatalogCategory category;
  final bool active;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final activeTextColor = Colors.white;
    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          canRequestFocus: false,
          splashColor: active
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFF071126).withValues(alpha: 0.04),
          hoverColor: active
              ? Colors.white.withValues(alpha: 0.04)
              : const Color(0xFF071126).withValues(alpha: 0.03),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 96,
            padding: EdgeInsets.fromLTRB(6, compact ? 6 : 7, 6, 6),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF071126) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active ? const Color(0xFF111C33) : Colors.transparent,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CategoryThumb(
                  imageUrl: category.imageUrl,
                  active: active,
                  compact: compact,
                  iconColor: active
                      ? const Color(0xFFE2E8F0)
                      : colors.onSurfaceVariant,
                ),
                SizedBox(height: compact ? 5 : 6),
                Text(
                  category.name.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active ? activeTextColor : const Color(0xFF334155),
                    fontSize: compact ? 11 : 11.5,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryThumb extends StatelessWidget {
  const _CategoryThumb({
    required this.imageUrl,
    required this.active,
    required this.compact,
    required this.iconColor,
  });

  final String? imageUrl;
  final bool active;
  final bool compact;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final hasImage = url != null && url.isNotEmpty;
    final fallback = Icon(
      Icons.restaurant_menu,
      color: iconColor,
      size: compact ? 23 : 24,
    );
    final image = hasImage
        ? _CategoryImage(url: url, fallback: fallback)
        : fallback;

    return Container(
      width: compact ? 50 : 52,
      height: compact ? 50 : 52,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF111C33) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active
              ? Colors.white.withValues(alpha: hasImage ? 0.32 : 0.10)
              : const Color(0xFFE5E7EB),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: active && hasImage
          ? ColorFiltered(
              colorFilter: ColorFilter.mode(
                const Color(0xFF071126).withValues(alpha: 0.08),
                BlendMode.darken,
              ),
              child: image,
            )
          : image,
    );
  }
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({required this.url, required this.fallback});

  final String url;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}

class _CatalogPanel extends StatelessWidget {
  const _CatalogPanel({
    required this.searchController,
    required this.items,
    required this.popularItems,
    required this.money,
    required this.viewMode,
    required this.searchQuery,
    required this.activeCategoryName,
    required this.showPopular,
    required this.ticketItemCount,
    required this.selectedItemIds,
    required this.onAdd,
  });

  final TextEditingController searchController;
  final List<_CatalogItem> items;
  final List<_CatalogItem> popularItems;
  final NumberFormat money;
  final String viewMode;
  final String searchQuery;
  final String? activeCategoryName;
  final bool showPopular;
  final int ticketItemCount;
  final Set<String> selectedItemIds;
  final ValueChanged<_CatalogItem> onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 8, 18, 8),
            child: Row(
              children: [
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF94A3B8),
                        ),
                        hintText: 'Search menu or barcode... (/)',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        suffixIcon: searchQuery.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                onPressed: searchController.clear,
                                icon: const Icon(
                                  Icons.close,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                if (ticketItemCount > 0) ...[
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$ticketItemCount in ticket',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                if (showPopular && popularItems.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Popular items',
                    subtitle: 'Fast picks from recent orders',
                    icon: Icons.trending_up,
                  ),
                  _PopularItemsStrip(
                    items: popularItems,
                    money: money,
                    selectedItemIds: selectedItemIds,
                    onAdd: onAdd,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
                if (!showPopular)
                  _SectionHeader(
                    title: searchQuery.isNotEmpty
                        ? 'Results for "$searchQuery"'
                        : activeCategoryName ?? 'Menu items',
                  ),
                if (items.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text('No items found.')),
                  )
                else if (viewMode == 'list')
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                    sliver: SliverList.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) => _ProductListTile(
                        item: items[index],
                        money: money,
                        selected: selectedItemIds.contains(items[index].id),
                        onTap: () => onAdd(items[index]),
                      ),
                    ),
                  )
                else
                  _ProductGridSliver(
                    items: items,
                    money: money,
                    selectedItemIds: selectedItemIds,
                    onAdd: onAdd,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularItemsStrip extends StatelessWidget {
  const _PopularItemsStrip({
    required this.items,
    required this.money,
    required this.selectedItemIds,
    required this.onAdd,
  });

  final List<_CatalogItem> items;
  final NumberFormat money;
  final Set<String> selectedItemIds;
  final ValueChanged<_CatalogItem> onAdd;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 178,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(width: 14),
          itemBuilder: (context, index) => SizedBox(
            width: 146,
            child: _ProductCard(
              item: items[index],
              money: money,
              compact: true,
              selected: selectedItemIds.contains(items[index].id),
              onTap: () => onAdd(items[index]),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle, this.icon});

  final String title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductGridSliver extends StatelessWidget {
  const _ProductGridSliver({
    required this.items,
    required this.money,
    required this.selectedItemIds,
    required this.onAdd,
  });

  static const _horizontalPadding = 28.0;
  static const _gap = 18.0;
  static const _minCardWidth = 180.0;
  static const _maxCardWidth = 210.0;
  static const _cardHeight = 252.0;

  final List<_CatalogItem> items;
  final NumberFormat money;
  final Set<String> selectedItemIds;
  final ValueChanged<_CatalogItem> onAdd;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = math.max(
          0.0,
          constraints.crossAxisExtent - (_horizontalPadding * 2),
        );
        var columnCount = math.max(
          1,
          ((availableWidth + _gap) / (_maxCardWidth + _gap)).ceil(),
        );
        if (availableWidth >= (_minCardWidth * 5) + (_gap * 4)) {
          columnCount = math.max(columnCount, 5);
        }
        columnCount = math.min(columnCount, 6);

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            _horizontalPadding,
            0,
            _horizontalPadding,
            24,
          ),
          sliver: SliverGrid.builder(
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnCount,
              mainAxisSpacing: _gap,
              crossAxisSpacing: _gap,
              mainAxisExtent: _cardHeight,
            ),
            itemBuilder: (context, index) => _ProductCard(
              item: items[index],
              money: money,
              selected: selectedItemIds.contains(items[index].id),
              onTap: () => onAdd(items[index]),
            ),
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatefulWidget {
  const _ProductCard({
    required this.item,
    required this.money,
    required this.onTap,
    this.compact = false,
    this.selected = false,
  });

  final _CatalogItem item;
  final NumberFormat money;
  final VoidCallback onTap;
  final bool compact;
  final bool selected;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hovered;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: active ? 3 : 1,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: active ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
            width: active ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _MenuImage(imageUrl: widget.item.imageUrl),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: _VegBadge(item: widget.item),
                    ),
                    if (widget.item.hasChoices)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: _PriceChip(
                        label: widget.money.format(widget.item.displayPrice),
                        compact: widget.compact,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  minHeight: widget.compact ? 68 : 72,
                ),
                padding: EdgeInsets.fromLTRB(
                  14,
                  widget.compact ? 10 : 12,
                  12,
                  10,
                ),
                color: const Color(0xFFFFFFFF),
                child: Text(
                  widget.item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: active
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFF0F172A),
                    fontSize: widget.compact ? 13 : 15,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  const _ProductListTile({
    required this.item,
    required this.money,
    required this.selected,
    required this.onTap,
  });

  final _CatalogItem item;
  final NumberFormat money;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: selected ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
          width: selected ? 1.4 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox.square(
            dimension: 52,
            child: _MenuImage(imageUrl: item.imageUrl),
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            color: selected ? const Color(0xFF4F46E5) : const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(item.categoryName),
        trailing: Text(
          money.format(item.displayPrice),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _MenuImage extends StatelessWidget {
  const _MenuImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return const _ImageFallback();
    }
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
        ),
      ),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
        loadingBuilder: (context, child, loadingProgress) {
          return loadingProgress == null ? child : const _ImageFallback();
        },
        errorBuilder: (context, error, stackTrace) => const _ImageFallback(),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
        ),
      ),
      child: Center(
        child: Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.restaurant,
            color: Color(0xFF8B8378),
            size: 34,
          ),
        ),
      ),
    );
  }
}

class _VegBadge extends StatelessWidget {
  const _VegBadge({required this.item});

  final _CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final isVeg = item.isVeg;
    final color = isVeg ? const Color(0xFF22C55E) : const Color(0xFFDC2626);
    return Semantics(
      label: isVeg ? 'Vegetarian' : 'Non vegetarian',
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FFFB),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: color, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isVeg
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                )
              : Icon(Icons.change_history, size: 12, color: color),
        ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.label, required this.compact});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 10,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF4F46E5),
          fontSize: compact ? 12 : 13,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _CartPanel extends StatelessWidget {
  const _CartPanel({
    required this.lines,
    required this.money,
    required this.orderType,
    required this.subtotal,
    required this.discountAmount,
    required this.payable,
    required this.customerName,
    required this.orderNotes,
    required this.orderNoteEditorVisible,
    required this.orderNoteController,
    required this.isCharging,
    required this.customerSearchVisible,
    required this.orderTypeExpanded,
    required this.heldTicketCount,
    required this.onCustomer,
    required this.onCustomerSubmitted,
    required this.onToggleOrderType,
    required this.onOpenTickets,
    required this.onClearCart,
    required this.onOrderTypeChanged,
    required this.onDiscount,
    required this.onOrderNotes,
    required this.onOrderNotesChanged,
    required this.expandedLineKey,
    required this.onToggleLine,
    required this.onQuantityChanged,
    required this.onLineNote,
    required this.onRemove,
    required this.onHold,
    required this.onProceed,
  });

  final List<_CartLine> lines;
  final NumberFormat money;
  final String orderType;
  final double subtotal;
  final double discountAmount;
  final double payable;
  final String? customerName;
  final String? orderNotes;
  final bool orderNoteEditorVisible;
  final TextEditingController orderNoteController;
  final bool isCharging;
  final bool customerSearchVisible;
  final bool orderTypeExpanded;
  final int heldTicketCount;
  final VoidCallback onCustomer;
  final ValueChanged<String> onCustomerSubmitted;
  final VoidCallback onToggleOrderType;
  final VoidCallback onOpenTickets;
  final VoidCallback onClearCart;
  final ValueChanged<String> onOrderTypeChanged;
  final VoidCallback onDiscount;
  final VoidCallback onOrderNotes;
  final ValueChanged<String> onOrderNotesChanged;
  final String? expandedLineKey;
  final ValueChanged<_CartLine> onToggleLine;
  final void Function(_CartLine line, int delta) onQuantityChanged;
  final ValueChanged<_CartLine> onLineNote;
  final ValueChanged<_CartLine> onRemove;
  final VoidCallback onHold;
  final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    final hasLines = lines.isNotEmpty;
    final displayLines = lines.toList(growable: false);
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(left: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: customerSearchVisible
                        ? TextField(
                            autofocus: true,
                            onSubmitted: onCustomerSubmitted,
                            decoration: const InputDecoration(
                              hintText: 'Search or add customer...',
                              prefixIcon: Icon(Icons.person_search_outlined),
                            ),
                          )
                        : OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0F172A),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: onCustomer,
                            icon: const Icon(Icons.person_add_alt_1_outlined),
                            label: Text(customerName ?? 'Add customer'),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                _CartToolButton(
                  tooltip: 'Grid view',
                  icon: Icons.grid_view,
                  onPressed: onToggleOrderType,
                ),
                const SizedBox(width: 10),
                Badge(
                  isLabelVisible: heldTicketCount > 0,
                  label: Text('$heldTicketCount'),
                  child: _CartToolButton(
                    tooltip: 'Open tickets (F4)',
                    icon: Icons.format_list_numbered,
                    onPressed: onOpenTickets,
                  ),
                ),
                const SizedBox(width: 10),
                _CartToolButton(
                  tooltip: 'Clear cart',
                  icon: Icons.refresh,
                  onPressed: hasLines ? onClearCart : null,
                ),
              ],
            ),
          ),
          if (orderTypeExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 16, 10),
              child: SegmentedButton<String>(
                selected: {orderType},
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'dine_in', label: Text('Dine in')),
                  ButtonSegment(value: 'takeaway', label: Text('Takeaway')),
                  ButtonSegment(value: 'delivery', label: Text('Delivery')),
                ],
                onSelectionChanged: (value) => onOrderTypeChanged(value.first),
              ),
            )
          else
            InkWell(
              onTap: onToggleOrderType,
              child: SizedBox(
                height: 38,
                child: Center(
                  child: Text(
                    _orderTypeLabel(orderType).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          if (orderNoteEditorVisible && hasLines) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
              child: TextField(
                controller: orderNoteController,
                autofocus: true,
                minLines: 2,
                maxLines: 3,
                onChanged: onOrderNotesChanged,
                decoration: InputDecoration(
                  hintText: 'Ticket note...',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF6366F1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF4F46E5),
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
          ],
          Expanded(
            child: hasLines
                ? ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: displayLines.length,
                    itemBuilder: (context, index) {
                      final line = displayLines[index];
                      return _CartLineTile(
                        line: line,
                        money: money,
                        expanded: _cartLineIdentity(line) == expandedLineKey,
                        onToggle: onToggleLine,
                        onQuantityChanged: onQuantityChanged,
                        onLineNote: onLineNote,
                        onRemove: onRemove,
                      );
                    },
                  )
                : const _EmptyCartView(),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasLines)
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFBEB),
                      border: Border(
                        top: BorderSide(color: Color(0xFFFDE68A)),
                        bottom: BorderSide(color: Color(0xFFFDE68A)),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Adjust',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Color(0xFFB45309),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          onPressed: onDiscount,
                          icon: const Icon(Icons.percent, size: 17),
                          label: const Text('Discount'),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Color(0xFFB45309),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          onPressed: onOrderNotes,
                          icon: const Icon(Icons.note_alt_outlined, size: 17),
                          label: const Text('Note'),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TotalRow(
                        label: 'Subtotal',
                        value: money.format(subtotal),
                      ),
                      if (discountAmount > 0)
                        _TotalRow(
                          label: 'Discount',
                          value: '-${money.format(discountAmount)}',
                          danger: true,
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Payable amount',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            money.format(payable),
                            style: const TextStyle(
                              color: Color(0xFF4F46E5),
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFF59E0B),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(
                                    0xFFD1D5DB,
                                  ),
                                  disabledForegroundColor: const Color(
                                    0xFF9CA3AF,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: hasLines && !isCharging
                                    ? onHold
                                    : null,
                                icon: const Icon(Icons.pause),
                                label: const Text('Hold order'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 58,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(
                                    0xFFD1D5DB,
                                  ),
                                  disabledForegroundColor: const Color(
                                    0xFF9CA3AF,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: hasLines && !isCharging
                                    ? onProceed
                                    : null,
                                icon: isCharging
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.play_arrow),
                                label: const Text('Proceed'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFF1F5F9),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFFCBD5E1),
              size: 42,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Cart is empty',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select items from the menu to start',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({
    required this.line,
    required this.money,
    required this.expanded,
    required this.onToggle,
    required this.onQuantityChanged,
    required this.onLineNote,
    required this.onRemove,
  });

  final _CartLine line;
  final NumberFormat money;
  final bool expanded;
  final ValueChanged<_CartLine> onToggle;
  final void Function(_CartLine line, int delta) onQuantityChanged;
  final ValueChanged<_CartLine> onLineNote;
  final ValueChanged<_CartLine> onRemove;

  @override
  Widget build(BuildContext context) {
    final optionTags = line.optionTags;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: expanded ? (optionTags.isEmpty ? 228 : 258) : 72,
            color: expanded ? const Color(0xFF10B981) : Colors.transparent,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 72,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 16, 0),
                    child: Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => onToggle(line),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: expanded
                                  ? const Color(0xFFF1F5F9)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              expanded
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_right,
                              size: 20,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 26,
                          child: Text(
                            '${line.quantity}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                line.item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 16,
                                  height: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (line.optionSummary.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  line.optionSummary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                    height: 1.2,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          money.format(line.total),
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkResponse(
                          radius: 22,
                          onTap: () => onRemove(line),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFECACA),
                              ),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFFE11D48),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (expanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (optionTags.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: optionTags
                                .map((tag) => _CartOptionChip(label: tag))
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: _CartFieldBlock(
                                label: 'Quantity',
                                child: Row(
                                  children: [
                                    _CartQuantityButton(
                                      icon: Icons.remove,
                                      onPressed: () =>
                                          onQuantityChanged(line, -1),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          '${line.quantity}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    _CartQuantityButton(
                                      icon: Icons.add,
                                      onPressed: () =>
                                          onQuantityChanged(line, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _CartFieldBlock(
                                label: 'Unit price',
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      money.format(line.unitPrice),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => onLineNote(line),
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.chat_bubble_outline,
                                  size: 18,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    line.note?.isNotEmpty == true
                                        ? line.note!
                                        : 'Add line note',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartOptionChip extends StatelessWidget {
  const _CartOptionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CartFieldBlock extends StatelessWidget {
  const _CartFieldBlock({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _CartQuantityButton extends StatelessWidget {
  const _CartQuantityButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 50,
      child: IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        icon: Icon(icon, size: 21, color: const Color(0xFF475569)),
      ),
    );
  }
}

class _CartToolButton extends StatelessWidget {
  const _CartToolButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: IconButton.outlined(
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFFFFFFF),
          foregroundColor: const Color(0xFF334155),
          disabledForegroundColor: const Color(0xFFCBD5E1),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 23),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.danger = false,
  });

  final String label;
  final String value;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: danger ? const Color(0xFFE11D48) : const Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSelection {
  const _PaymentSelection({
    required this.method,
    required this.cashTendered,
    required this.tip,
  });

  final String method;
  final double cashTendered;
  final double tip;
}

class _UpiQrPaymentDialog extends StatefulWidget {
  const _UpiQrPaymentDialog({
    required this.qr,
    required this.orderNumber,
    required this.amount,
    required this.money,
    required this.paymentFuture,
    this.payeeName,
    this.upiId,
  });

  final String qr;
  final String orderNumber;
  final double amount;
  final NumberFormat money;
  final Future<PosOrderPaymentResult> paymentFuture;
  final String? payeeName;
  final String? upiId;

  @override
  State<_UpiQrPaymentDialog> createState() => _UpiQrPaymentDialogState();
}

class _UpiQrPaymentDialogState extends State<_UpiQrPaymentDialog> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    widget.paymentFuture
        .then((_) {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        })
        .catchError((Object error) {
          if (mounted) {
            setState(() => _error = error);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.qr_code_2, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Scan UPI QR',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Order ${widget.orderNumber}',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: QrImageView(
                      data: widget.qr,
                      version: QrVersions.auto,
                      size: 270,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.money.format(widget.amount),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF022C22),
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (widget.payeeName?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  widget.payeeName!.trim(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
              if (widget.upiId?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  widget.upiId!.trim(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ],
              const SizedBox(height: 18),
              if (_error == null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Waiting for payment...',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                )
              else
                Text(
                  _error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(_error == null ? 'Cancel waiting' : 'Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.total, required this.money});

  final double total;
  final NumberFormat money;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _receivedController = TextEditingController();
  final _tipController = TextEditingController(text: '0.00');
  final _bodyScrollController = ScrollController();
  String _method = 'cash';
  String _tipPreset = 'none';

  @override
  void initState() {
    super.initState();
    _receivedController.text = widget.total.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _receivedController.dispose();
    _tipController.dispose();
    _bodyScrollController.dispose();
    super.dispose();
  }

  double get _received => _parseAmount(_receivedController.text);
  double get _tip => _parseAmount(_tipController.text);
  double get _amountDue => widget.total + _tip;
  double get _change => (_received - _amountDue).clamp(0, double.infinity);

  void _setTipAmount(double amount, String preset) {
    _tipController.text = amount.toStringAsFixed(2);
    setState(() => _tipPreset = preset);
  }

  void _setTipPercent(int percent) {
    _setTipAmount(widget.total * percent / 100, '$percent');
  }

  void _setReceived(double amount) {
    _receivedController.text = amount.toStringAsFixed(2);
    setState(() {});
  }

  void _complete() {
    Navigator.of(context).pop(
      _PaymentSelection(
        method: _method,
        cashTendered: _method == 'cash' ? _received : _amountDue,
        tip: _tip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 900;
    final dialogWidth = compact ? size.width : math.min(size.width - 48, 976.0);
    final dialogHeight = compact
        ? math.min(size.height - 20, 860.0)
        : math.min(size.height - 48, 820.0);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 24,
        vertical: compact ? 10 : 24,
      ),
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.white,
            child: Column(
              children: [
                _buildHeader(context),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                Expanded(
                  child: compact
                      ? _buildCompactBody(context)
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(child: _buildPaymentSummary(context)),
                            const VerticalDivider(
                              width: 1,
                              thickness: 1,
                              color: Color(0xFFE5E7EB),
                            ),
                            Expanded(child: _buildPaymentMethods(context)),
                          ],
                        ),
                ),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 88,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Take payment',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 20,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Select method and complete',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 15,
                      height: 1.2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFFE11D48),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 16 : 24,
        compact ? 16 : 24,
        compact ? 16 : 24,
        compact ? 12 : 24,
      ),
      child: Column(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: compact ? 116 : 132,
            decoration: BoxDecoration(
              color: const Color(0xFF071126),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'AMOUNT DUE',
                  style: TextStyle(
                    color: Color(0xFFBFDBFE),
                    fontSize: 12,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.money.format(_amountDue),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 38 : 58,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.volunteer_activism_outlined,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'TIP',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TipButton(
                      label: 'None',
                      selected: _tipPreset == 'none',
                      onTap: () => _setTipAmount(0, 'none'),
                    ),
                    _TipButton(
                      label: '10%',
                      selected: _tipPreset == '10',
                      onTap: () => _setTipPercent(10),
                    ),
                    _TipButton(
                      label: '15%',
                      selected: _tipPreset == '15',
                      onTap: () => _setTipPercent(15),
                    ),
                    _TipButton(
                      label: '18%',
                      selected: _tipPreset == '18',
                      onTap: () => _setTipPercent(18),
                    ),
                    _TipButton(
                      label: '20%',
                      selected: _tipPreset == '20',
                      onTap: () => _setTipPercent(20),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      const Text(
                        'CUSTOM',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _tipController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) =>
                              setState(() => _tipPreset = 'custom'),
                          decoration: _paymentInputDecoration('0.00'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!compact) const Spacer() else const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _method = 'pay_later'),
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _method == 'pay_later'
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFFCBD5E1),
                  width: _method == 'pay_later' ? 2 : 1.4,
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.schedule_outlined, color: Color(0xFFD97706)),
                  SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pay later',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Open tab - charge when ready',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    return Scrollbar(
      controller: _bodyScrollController,
      thumbVisibility: !compact,
      child: SingleChildScrollView(
        controller: _bodyScrollController,
        padding: EdgeInsets.fromLTRB(
          compact ? 16 : 22,
          compact ? 4 : 22,
          compact ? 16 : 22,
          compact ? 16 : 22,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'PAYMENT METHOD',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: compact ? 1 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: compact ? 3.35 : 1.86,
              children: [
                _MethodButton(
                  selected: _method == 'cash',
                  icon: Icons.payments_outlined,
                  title: 'Cash',
                  subtitle: 'Tender & change',
                  onTap: () => setState(() => _method = 'cash'),
                ),
                _MethodButton(
                  selected: _method == 'card',
                  icon: Icons.credit_card,
                  title: 'Card',
                  subtitle: 'Terminal',
                  onTap: () => setState(() => _method = 'card'),
                ),
                _MethodButton(
                  selected: _method == 'upi',
                  icon: Icons.qr_code_2,
                  title: 'UPI',
                  subtitle: 'Dynamic QR',
                  onTap: () => setState(() => _method = 'upi'),
                ),
                _MethodButton(
                  selected: _method == 'other',
                  icon: Icons.adjust,
                  title: 'Other',
                  subtitle: 'Voucher, etc.',
                  onTap: () => setState(() => _method = 'other'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_method == 'cash') _buildCashTenderPanel(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPaymentSummary(context),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          _buildPaymentMethods(context),
        ],
      ),
    );
  }

  Widget _buildCashTenderPanel(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'CASH TENDER',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: compact ? 2 : 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: compact ? 3.2 : 3.1,
            children: [
              _CashTenderButton(
                label: 'Exact',
                onTap: () => _setReceived(_amountDue),
              ),
              _CashTenderButton(
                label: '+5',
                onTap: () => _setReceived(_amountDue + 5),
              ),
              _CashTenderButton(
                label: '+10',
                onTap: () => _setReceived(_amountDue + 10),
              ),
              _CashTenderButton(
                label: '+20',
                onTap: () => _setReceived(_amountDue + 20),
              ),
              _CashTenderButton(
                label: '+50',
                onTap: () => _setReceived(_amountDue + 50),
              ),
              _CashTenderButton(label: 'Clear', onTap: () => _setReceived(0)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'RECEIVED',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _receivedController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            decoration: _paymentInputDecoration('0.00'),
          ),
          const SizedBox(height: 12),
          Container(
            height: compact ? 58 : 58,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text(
                  'CHANGE',
                  style: TextStyle(
                    color: Color(0xFF064E3B),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  widget.money.format(_change),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF022C22),
                    fontSize: compact ? 28 : 32,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final canComplete = _method != 'cash' || _received >= _amountDue;
    final compact = MediaQuery.sizeOf(context).width < 720;
    final primaryLabel = _method == 'upi' ? 'Show QR' : 'Complete payment';
    final primaryIcon = _method == 'upi'
        ? Icons.qr_code_2
        : Icons.check_circle_outline;
    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 14 : 20,
        14,
        compact ? 14 : 20,
        14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: compact
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: _CompletePaymentButton(
                    enabled: canComplete,
                    label: primaryLabel,
                    icon: primaryIcon,
                    onPressed: _complete,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: _CancelPaymentButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                SizedBox(
                  width: 190,
                  height: 54,
                  child: _CancelPaymentButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: _CompletePaymentButton(
                      enabled: canComplete,
                      label: primaryLabel,
                      icon: primaryIcon,
                      onPressed: _complete,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  InputDecoration _paymentInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.4),
      ),
    );
  }
}

class _TipButton extends StatelessWidget {
  const _TipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 42,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: selected ? Colors.white : const Color(0xFF475569),
          backgroundColor: selected ? const Color(0xFF071126) : Colors.white,
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}

class _MethodButton extends StatelessWidget {
  const _MethodButton({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: selected
            ? const Color(0xFF4F46E5)
            : const Color(0xFF0F172A),
        backgroundColor: selected ? const Color(0xFFEEF2FF) : Colors.white,
        side: BorderSide(
          color: selected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
          width: selected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onTap,
      child: compact
          ? Row(
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: selected
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 30,
                  color: selected
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFF94A3B8),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    );
  }
}

class _CompletePaymentButton extends StatelessWidget {
  const _CompletePaymentButton({
    required this.enabled,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final bool enabled;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF4F46E5),
        disabledBackgroundColor: const Color(0xFFA5A4F2),
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 22),
      label: Text(label),
    );
  }
}

class _CancelPaymentButton extends StatelessWidget {
  const _CancelPaymentButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: const Text('Cancel'),
    );
  }
}

class _CashTenderButton extends StatelessWidget {
  const _CashTenderButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: const Color(0xFFFFFFFF),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}

class _PrinterSetupDialog extends ConsumerStatefulWidget {
  const _PrinterSetupDialog({required this.initial});

  final PrinterConfig? initial;

  @override
  ConsumerState<_PrinterSetupDialog> createState() =>
      _PrinterSetupDialogState();
}

class _PrinterSetupDialogState extends ConsumerState<_PrinterSetupDialog> {
  final _nameController = TextEditingController();
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '9100');
  String _connectionType = 'lan';
  bool _enabled = true;
  bool _printReceipts = true;
  bool _scanning = false;
  List<PrinterDeviceInfo> _devices = const [];
  PrinterDeviceInfo? _selectedDevice;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController.text = initial?.name ?? 'Receipt printer';
    _connectionType = initial?.connectionType ?? 'lan';
    _hostController.text = initial?.host ?? '';
    _portController.text = '${initial?.port ?? 9100}';
    _enabled = initial?.enabled ?? true;
    _printReceipts = initial?.printReceipts ?? true;
    if (initial != null && initial.connectionType == 'smartpos') {
      _nameController.text = initial.name.isEmpty
          ? 'SmartPOS built-in printer'
          : initial.name;
      _selectedDevice = const PrinterDeviceInfo(
        name: 'SmartPOS built-in printer',
        connectionType: 'smartpos',
        isConnected: true,
      );
    } else if (initial != null && (initial.isUsb || initial.isBluetooth)) {
      _selectedDevice = PrinterDeviceInfo(
        name: initial.name,
        connectionType: initial.connectionType,
        address: initial.address,
        vendorId: initial.vendorId,
        productId: initial.productId,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    if (_connectionType == 'smartpos') {
      setState(() {
        _devices = const [
          PrinterDeviceInfo(
            name: 'SmartPOS built-in printer',
            connectionType: 'smartpos',
            isConnected: true,
          ),
        ];
        _selectedDevice = _devices.first;
        _nameController.text = _devices.first.name;
      });
      return;
    }
    setState(() => _scanning = true);
    try {
      final devices = await ref
          .read(printerRepositoryProvider)
          .discoverPrinters(_connectionType);
      if (!mounted) {
        return;
      }
      setState(() => _devices = devices);
      if (devices.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No printers found.')));
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
      }
    } finally {
      if (mounted) {
        setState(() => _scanning = false);
      }
    }
  }

  Future<void> _save() async {
    final selected = _selectedDevice;
    final config = PrinterConfig(
      name: _nameController.text.trim().isEmpty
          ? _connectionType == 'smartpos'
                ? 'SmartPOS built-in printer'
                : 'Receipt printer'
          : _nameController.text.trim(),
      connectionType: _connectionType,
      host: _connectionType == 'lan' ? _hostController.text.trim() : null,
      port: int.tryParse(_portController.text) ?? 9100,
      address: _connectionType == 'lan' || _connectionType == 'smartpos'
          ? null
          : selected?.address,
      vendorId: _connectionType == 'lan' || _connectionType == 'smartpos'
          ? null
          : selected?.vendorId,
      productId: _connectionType == 'lan' || _connectionType == 'smartpos'
          ? null
          : selected?.productId,
      enabled: _enabled,
      printReceipts: _printReceipts,
    );
    await ref.read(printerRepositoryProvider).saveConfig(config);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 12, 12),
              child: Row(
                children: [
                  Text(
                    'Receipt printer',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Printer name',
                      prefixIcon: Icon(Icons.print),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SegmentedButton<String>(
                    selected: {_connectionType},
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: 'lan',
                        label: Text('LAN'),
                        icon: Icon(Icons.lan),
                      ),
                      ButtonSegment(
                        value: 'usb',
                        label: Text('USB'),
                        icon: Icon(Icons.usb),
                      ),
                      ButtonSegment(
                        value: 'bluetooth',
                        label: Text('Bluetooth'),
                        icon: Icon(Icons.bluetooth),
                      ),
                      ButtonSegment(
                        value: 'smartpos',
                        label: Text('Built-in'),
                        icon: Icon(Icons.receipt_long),
                      ),
                    ],
                    onSelectionChanged: (value) {
                      setState(() {
                        _connectionType = value.first;
                        _devices = const [];
                        _selectedDevice = null;
                        if (_connectionType == 'smartpos') {
                          _devices = const [
                            PrinterDeviceInfo(
                              name: 'SmartPOS built-in printer',
                              connectionType: 'smartpos',
                              isConnected: true,
                            ),
                          ];
                          _selectedDevice = _devices.first;
                          _nameController.text = _devices.first.name;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  if (_connectionType == 'lan') ...[
                    TextField(
                      controller: _hostController,
                      decoration: const InputDecoration(
                        labelText: 'Printer IP address',
                        hintText: '192.168.1.50',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _portController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Port'),
                    ),
                  ] else if (_connectionType == 'smartpos') ...[
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.check_circle,
                        color: Color(0xFF10B981),
                      ),
                      title: Text('SmartPOS built-in printer'),
                      subtitle: Text(
                        'Prints through the Android SmartPOS SDK.',
                      ),
                    ),
                  ] else ...[
                    FilledButton.icon(
                      onPressed: _scanning ? null : _scan,
                      icon: _scanning
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: const Text('Scan printers'),
                    ),
                    const SizedBox(height: 10),
                    for (final device in _devices) ...[
                      ListTile(
                        selected: _samePrinterDevice(device, _selectedDevice),
                        leading: Icon(
                          _samePrinterDevice(device, _selectedDevice)
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                        ),
                        title: Text(device.name),
                        subtitle: Text(
                          device.address ??
                              device.vendorId ??
                              device.productId ??
                              _connectionType.toUpperCase(),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedDevice = device;
                            _nameController.text = device.name;
                          });
                        },
                      ),
                    ],
                    if (_selectedDevice == null && _devices.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('Scan and select a USB/Bluetooth printer.'),
                      ),
                  ],
                  const SizedBox(height: 14),
                  SwitchListTile(
                    value: _enabled,
                    onChanged: (value) => setState(() => _enabled = value),
                    title: const Text('Active'),
                  ),
                  SwitchListTile(
                    value: _printReceipts,
                    onChanged: (value) =>
                        setState(() => _printReceipts = value),
                    title: const Text('POS customer receipts'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenShiftRequest {
  const _OpenShiftRequest({required this.openingCashFloat, this.notes});

  final double openingCashFloat;
  final String? notes;
}

class _OpenShiftDialog extends StatefulWidget {
  const _OpenShiftDialog();

  @override
  State<_OpenShiftDialog> createState() => _OpenShiftDialogState();
}

class _OpenShiftDialogState extends State<_OpenShiftDialog> {
  final _cashController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _cashController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(
      _OpenShiftRequest(
        openingCashFloat: _parseAmount(_cashController.text),
        notes: _nullableString(_notesController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ShiftDialogFrame(
      width: 560,
      title: 'Open shift',
      body: Padding(
        padding: const EdgeInsets.fromLTRB(26, 26, 26, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ShiftFieldLabel('Opening cash float'),
            const SizedBox(height: 6),
            TextField(
              controller: _cashController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
              decoration: _shiftInputDecoration('0'),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            _ShiftFieldLabel('Notes (optional)'),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
              decoration: _shiftInputDecoration('Handover, drawer ID, etc.'),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _ShiftFooterButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          _ShiftFooterButton(
            label: 'Open shift',
            primary: true,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _CloseShiftRequest {
  const _CloseShiftRequest({required this.countedCash, this.notes});

  final double countedCash;
  final String? notes;
}

class _CloseShiftDialog extends StatefulWidget {
  const _CloseShiftDialog({required this.summary, required this.money});

  final Map<String, dynamic> summary;
  final NumberFormat money;

  @override
  State<_CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends State<_CloseShiftDialog> {
  late final TextEditingController _cashController;
  final _notesController = TextEditingController();
  final _scrollController = ScrollController();

  double get _sales => _summaryAmount(widget.summary, const [
    'sales_this_shift',
    'sales_total',
    'orders_total',
    'paid_total',
    'paid_sales',
    'total_sales',
    'totals.sales',
    'summary.sales_total',
  ]);

  int get _paidOrders => _summaryInt(widget.summary, const [
    'paid_orders',
    'paid_orders_count',
    'paid_count',
    'orders_count',
    'count',
    'orders.paid',
  ]);

  int get _unpaidOrders => _summaryInt(widget.summary, const [
    'unpaid_orders',
    'unpaid_orders_count',
    'unpaid_count',
    'orders.unpaid',
  ]);

  double get _unpaidAmount => _summaryAmount(widget.summary, const [
    'unpaid_total',
    'unpaid_amount',
    'unpaid_orders_total',
    'orders.unpaid_amount',
  ]);

  double get _openingFloat => _summaryAmount(widget.summary, const [
    'opening_cash_float',
    'opening_float',
    'opening_cash',
    'cash_drawer.opening_float',
    'drawer.opening_float',
  ]);

  double get _cashSales {
    final direct = _summaryAmount(widget.summary, const [
      'cash_sales',
      'cash_total',
      'cash_payments_total',
      'cash_from_sales',
      'cash_tendered_total',
      'cash.sales',
      'cash_drawer.cash_sales',
      'drawer.cash_sales',
    ]);
    if (direct > 0) {
      return direct;
    }
    final cashRow = _paymentRows.where((row) {
      return row.label.toLowerCase().contains('cash');
    }).firstOrNull;
    return cashRow?.amount ?? 0;
  }

  double get _changeGiven => _summaryAmount(widget.summary, const [
    'change_given',
    'change_given_total',
    'cash_change_given',
    'cash.change_given',
    'cash_drawer.change_given',
    'drawer.change_given',
  ]);

  double get _expected => _closeShiftExpected(widget.summary);

  List<_ShiftPaymentMethodLine> get _paymentRows {
    final parsed = _shiftPaymentMethodLines(widget.summary);
    if (parsed.isNotEmpty) {
      return parsed;
    }
    final cashSales = _summaryAmount(widget.summary, const [
      'cash_sales',
      'cash_total',
      'cash_payments_total',
    ]);
    if (cashSales > 0 || _sales > 0) {
      return [
        _ShiftPaymentMethodLine(
          label: 'Cash',
          count: _paidOrders,
          amount: cashSales > 0 ? cashSales : _sales,
        ),
      ];
    }
    return const [];
  }

  @override
  void initState() {
    super.initState();
    _cashController = TextEditingController(text: _expected.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _cashController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(
      _CloseShiftRequest(
        countedCash: _parseAmount(_cashController.text),
        notes: _nullableString(_notesController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final counted = _parseAmount(_cashController.text);
    final variance = counted - _expected;
    final maxHeight = math.min(MediaQuery.sizeOf(context).height - 64, 800.0);

    return _ShiftDialogFrame(
      width: 640,
      maxHeight: maxHeight,
      title: 'Close shift',
      subtitle: 'Count the drawer and confirm against expected cash.',
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(26, 26, 34, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ShiftSummaryCard(
                money: widget.money,
                sales: _sales,
                paidOrders: _paidOrders,
                unpaidOrders: _unpaidOrders,
                unpaidAmount: _unpaidAmount,
                paymentRows: _paymentRows,
                openingFloat: _openingFloat,
                cashSales: _cashSales,
                changeGiven: _changeGiven,
                expected: _expected,
                counted: counted,
                variance: variance,
              ),
              if (_unpaidOrders > 0) ...[
                const SizedBox(height: 16),
                _CloseShiftWarning(
                  message:
                      '$_unpaidOrders unpaid orders totaling ${widget.money.format(_unpaidAmount)} are still open.',
                ),
              ],
              const SizedBox(height: 24),
              _ShiftFieldLabel('Cash counted in drawer'),
              const SizedBox(height: 6),
              TextField(
                controller: _cashController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
                decoration: _shiftInputDecoration('0.00'),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 20),
              _ShiftFieldLabel('Notes (optional)'),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
                decoration: _shiftInputDecoration(
                  'Explain variance, payouts, etc.',
                ),
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _ShiftFooterButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 14),
          _ShiftFooterButton(
            label: 'Close shift',
            primary: true,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _CloseShiftWarning extends StatelessWidget {
  const _CloseShiftWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFC2410C),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF7C2D12),
                fontSize: 14,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiftDialogFrame extends StatelessWidget {
  const _ShiftDialogFrame({
    required this.title,
    required this.body,
    required this.footer,
    this.subtitle,
    this.width = 560,
    this.maxHeight,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget footer;
  final double width;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final effectiveMaxHeight =
        maxHeight ?? math.min(MediaQuery.sizeOf(context).height - 48, 800.0);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width,
          maxHeight: effectiveMaxHeight,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 20, 20, 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 24,
                                height: 1.08,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                subtitle!,
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 17,
                                  height: 1.25,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      _DialogCloseButton(
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                Flexible(fit: FlexFit.loose, child: body),
                Container(
                  padding: const EdgeInsets.fromLTRB(26, 20, 26, 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                  ),
                  child: footer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShiftSummaryCard extends StatelessWidget {
  const _ShiftSummaryCard({
    required this.money,
    required this.sales,
    required this.paidOrders,
    required this.unpaidOrders,
    required this.unpaidAmount,
    required this.paymentRows,
    required this.openingFloat,
    required this.cashSales,
    required this.changeGiven,
    required this.expected,
    required this.counted,
    required this.variance,
  });

  final NumberFormat money;
  final double sales;
  final int paidOrders;
  final int unpaidOrders;
  final double unpaidAmount;
  final List<_ShiftPaymentMethodLine> paymentRows;
  final double openingFloat;
  final double cashSales;
  final double changeGiven;
  final double expected;
  final double counted;
  final double variance;

  @override
  Widget build(BuildContext context) {
    final paidText = paidOrders == 1
        ? '1 paid order'
        : '$paidOrders paid orders';
    final unpaidText = unpaidOrders > 0
        ? ' - $unpaidOrders unpaid (${money.format(unpaidAmount)})'
        : '';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ShiftSectionLabel('SALES THIS SHIFT'),
          const SizedBox(height: 6),
          Text(
            money.format(sales),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 30,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$paidText$unpaidText',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          if (paymentRows.isNotEmpty) ...[
            const SizedBox(height: 24),
            const _ShiftSectionLabel('BY PAYMENT METHOD'),
            const SizedBox(height: 10),
            for (final row in paymentRows)
              _ShiftAmountRow(
                label: row.count > 0
                    ? '${row.label} (${row.count})'
                    : row.label,
                value: money.format(row.amount),
              ),
          ],
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 18),
          const _ShiftSectionLabel('CASH DRAWER'),
          const SizedBox(height: 10),
          _ShiftAmountRow(
            label: 'Opening float',
            value: money.format(openingFloat),
          ),
          _ShiftAmountRow(
            label: '+ Cash sales',
            value: money.format(cashSales),
          ),
          if (changeGiven > 0)
            _ShiftAmountRow(
              label: 'Change given (info)',
              value: money.format(changeGiven),
              muted: true,
            ),
          const Divider(height: 16, color: Color(0xFFE2E8F0)),
          _ShiftAmountRow(
            label: 'Expected in drawer',
            value: money.format(expected),
            strong: true,
            valueColor: const Color(0xFF047857),
            valueSize: 22,
          ),
          const SizedBox(height: 8),
          _ShiftAmountRow(label: 'Counted', value: money.format(counted)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _ShiftAmountRow(
              label: 'Variance',
              value: _varianceLabel(variance),
              strong: true,
              compact: true,
            ),
          ),
        ],
      ),
    );
  }

  String _varianceLabel(double value) {
    final amount = money.format(value.abs());
    if (value.abs() < 0.005) {
      return '$amount balanced';
    }
    return value < 0 ? '$amount short' : '$amount over';
  }
}

class _ShiftAmountRow extends StatelessWidget {
  const _ShiftAmountRow({
    required this.label,
    required this.value,
    this.strong = false,
    this.muted = false,
    this.valueColor,
    this.valueSize = 16,
    this.compact = false,
  });

  final String label;
  final String value;
  final bool strong;
  final bool muted;
  final Color? valueColor;
  final double valueSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 0 : 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: muted
                    ? const Color(0xFF64748B)
                    : const Color(0xFF334155),
                fontSize: compact ? 15 : 16,
                height: 1.1,
                fontWeight: strong ? FontWeight.w800 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color:
                  valueColor ??
                  (muted ? const Color(0xFF64748B) : const Color(0xFF0F172A)),
              fontSize: valueSize,
              height: 1.1,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiftSectionLabel extends StatelessWidget {
  const _ShiftSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ShiftFieldLabel extends StatelessWidget {
  const _ShiftFieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 16,
        height: 1.2,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ShiftFooterButton extends StatelessWidget {
  const _ShiftFooterButton({
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: primary
          ? FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onPressed,
              child: Text(label),
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onPressed,
              child: Text(label),
            ),
    );
  }
}

InputDecoration _shiftInputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 16),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.6),
    ),
  );
}

class _ShiftPaymentMethodLine {
  const _ShiftPaymentMethodLine({
    required this.label,
    required this.amount,
    this.count = 0,
  });

  final String label;
  final double amount;
  final int count;
}

List<_ShiftPaymentMethodLine> _shiftPaymentMethodLines(
  Map<String, dynamic> source,
) {
  final value = _firstDeepValue(source, const [
    'by_payment_method',
    'byPaymentMethod',
    'payment_methods',
    'paymentMethods',
    'payments_by_method',
    'paymentsByMethod',
    'payments',
    'tenders',
  ]);
  if (value is Map) {
    return value.entries
        .map(
          (entry) => _ShiftPaymentMethodLine(
            label: _humanizePaymentLabel(entry.key.toString()),
            amount: _amountFromSummaryValue(entry.value),
            count: _countFromSummaryValue(entry.value),
          ),
        )
        .where((line) => line.amount > 0 || line.count > 0)
        .toList();
  }
  if (value is List) {
    return value
        .whereType<Map>()
        .map((raw) {
          final map = Map<String, dynamic>.from(raw);
          return _ShiftPaymentMethodLine(
            label: _humanizePaymentLabel(
              _firstText(map, const [
                'label',
                'name',
                'method',
                'payment_method',
                'type',
              ]),
            ),
            amount: _amountFromSummaryValue(map),
            count: _countFromSummaryValue(map),
          );
        })
        .where(
          (line) =>
              line.label.isNotEmpty && (line.amount > 0 || line.count > 0),
        )
        .toList();
  }
  return const [];
}

double _closeShiftExpected(Map<String, dynamic> summary) {
  final direct = _summaryAmount(summary, const [
    'expected_cash',
    'expected_in_drawer',
    'expected_drawer',
    'cash.expected',
    'cash_drawer.expected',
    'drawer.expected',
  ]);
  if (direct > 0) {
    return direct;
  }
  final opening = _summaryAmount(summary, const [
    'opening_cash_float',
    'opening_float',
    'opening_cash',
    'cash_drawer.opening_float',
    'drawer.opening_float',
  ]);
  final cashSales = _summaryAmount(summary, const [
    'cash_sales',
    'cash_total',
    'cash_payments_total',
    'cash_from_sales',
    'cash_tendered_total',
    'cash.sales',
    'cash_drawer.cash_sales',
    'drawer.cash_sales',
  ]);
  final changeGiven = _summaryAmount(summary, const [
    'change_given',
    'change_given_total',
    'cash_change_given',
    'cash.change_given',
    'cash_drawer.change_given',
    'drawer.change_given',
  ]);
  return opening + cashSales - changeGiven;
}

Object? _firstDeepValue(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = _deepValue(source, key);
    if (value != null) {
      return value;
    }
  }
  return null;
}

double _amountFromSummaryValue(Object? value) {
  if (value is num || value is String) {
    return _doubleValue(value);
  }
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    return _summaryAmount(map, const [
      'amount',
      'total',
      'value',
      'paid',
      'sales',
      'total_amount',
      'amount_total',
      'net_amount',
    ]);
  }
  return 0;
}

int _countFromSummaryValue(Object? value) {
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    return _summaryInt(map, const [
      'count',
      'orders',
      'orders_count',
      'paid_orders',
    ]);
  }
  return 0;
}

String _humanizePaymentLabel(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  return trimmed
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
      .join(' ');
}

class _CustomerDetails {
  const _CustomerDetails({this.name, this.phone, this.address});

  final String? name;
  final String? phone;
  final String? address;
}

class _CustomerDialog extends StatefulWidget {
  const _CustomerDialog({
    required this.initialName,
    required this.initialPhone,
    required this.initialAddress,
  });

  final String? initialName;
  final String? initialPhone;
  final String? initialAddress;

  @override
  State<_CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<_CustomerDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _addressController = TextEditingController(
      text: widget.initialAddress ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Customer'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_add_alt),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              _CustomerDetails(
                name: _nullableString(_nameController.text),
                phone: _nullableString(_phoneController.text),
                address: _nullableString(_addressController.text),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _DiscountDialog extends StatefulWidget {
  const _DiscountDialog({
    required this.initial,
    required this.subtotal,
    required this.money,
  });

  final _Discount? initial;
  final double subtotal;
  final NumberFormat money;

  @override
  State<_DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<_DiscountDialog> {
  late String _type;
  late final TextEditingController _valueController;
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _type = widget.initial?.type ?? 'percent';
    final initialValue = widget.initial?.value;
    _valueController = TextEditingController(
      text: initialValue == null || initialValue == 0
          ? ''
          : _cleanNumber(initialValue),
    );
    _reasonController = TextEditingController(
      text: widget.initial?.reason ?? '',
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  double get _enteredValue {
    final raw = _parseAmount(_valueController.text);
    if (_type == 'percent') {
      return raw.clamp(0, 100).toDouble();
    }
    return raw.clamp(0, widget.subtotal).toDouble();
  }

  double get _discountAmount {
    final amount = _type == 'percent'
        ? widget.subtotal * _enteredValue / 100
        : _enteredValue;
    return amount.clamp(0, widget.subtotal).toDouble();
  }

  double get _taxableBase =>
      (widget.subtotal - _discountAmount).clamp(0, double.infinity).toDouble();

  void _selectType(String type) {
    setState(() {
      _type = type;
    });
  }

  void _selectPercent(double value) {
    setState(() {
      _type = 'percent';
      _valueController.text = _cleanNumber(value);
      _valueController.selection = TextSelection.collapsed(
        offset: _valueController.text.length,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 22, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Apply discount',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Applied to the subtotal before tax.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 18,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF1F2),
                      foregroundColor: const Color(0xFFE11D48),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Flexible(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _DiscountSummaryLine(
                              label: 'Subtotal',
                              value: widget.money.format(widget.subtotal),
                            ),
                            const SizedBox(height: 4),
                            _DiscountSummaryLine(
                              label: 'Discount',
                              value:
                                  '- ${widget.money.format(_discountAmount)}',
                              danger: true,
                            ),
                            const Divider(height: 22, color: Color(0xFFE2E8F0)),
                            _DiscountSummaryLine(
                              label: 'New taxable base',
                              value: widget.money.format(_taxableBase),
                              strong: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      const Text(
                        'TYPE',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _DiscountTypeCard(
                              selected: _type == 'percent',
                              icon: Icons.percent,
                              title: 'Percent',
                              subtitle: 'e.g 10%',
                              onTap: () => _selectType('percent'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DiscountTypeCard(
                              selected: _type == 'amount',
                              icon: Icons.attach_money,
                              title: 'Amount',
                              subtitle: 'fixed off',
                              onTap: () => _selectType('amount'),
                            ),
                          ),
                        ],
                      ),
                      if (_type == 'percent') ...[
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [5, 10, 15, 20]
                              .map(
                                (value) => _QuickPercentChip(
                                  label: '$value%',
                                  onTap: () => _selectPercent(value.toDouble()),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 26),
                      TextField(
                        controller: _valueController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: _type == 'percent'
                              ? 'Percent (0-100)'
                              : 'Amount',
                          hintText: _type == 'percent' ? '0' : '0.00',
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Reason (optional)',
                          hintText: 'Manager comp, loyalty, staff meal...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 18, 26, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF9F95EC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(
                        _Discount(
                          type: _type,
                          value: _enteredValue,
                          reason: _reasonController.text.trim(),
                        ),
                      );
                    },
                    child: const Text('Apply discount'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscountSummaryLine extends StatelessWidget {
  const _DiscountSummaryLine({
    required this.label,
    required this.value,
    this.danger = false,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool danger;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFE11D48) : const Color(0xFF0F172A);
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: danger ? const Color(0xFFE11D48) : const Color(0xFF475569),
            fontSize: 16,
            fontWeight: strong ? FontWeight.w900 : FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: strong ? FontWeight.w900 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DiscountTypeCard extends StatelessWidget {
  const _DiscountTypeCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: const Color(0xFF64748B)),
            const SizedBox(width: 14),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickPercentChip extends StatelessWidget {
  const _QuickPercentChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      labelStyle: const TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w700,
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onPressed: onTap,
    );
  }
}

String _cleanNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}

class _ItemOptionsDialog extends StatefulWidget {
  const _ItemOptionsDialog({required this.item, required this.money});

  final _CatalogItem item;
  final NumberFormat money;

  @override
  State<_ItemOptionsDialog> createState() => _ItemOptionsDialogState();
}

class _ItemOptionsDialogState extends State<_ItemOptionsDialog> {
  final Map<String, Set<String>> _selectedOptions = {};
  final TextEditingController _noteController = TextEditingController();
  _ItemVariant? _selectedVariant;

  @override
  void initState() {
    super.initState();
    _noteController.addListener(_refreshNoteCounter);
  }

  @override
  void dispose() {
    _noteController
      ..removeListener(_refreshNoteCounter)
      ..dispose();
    super.dispose();
  }

  void _refreshNoteCounter() {
    if (mounted) {
      setState(() {});
    }
  }

  double get _previewPrice {
    final modifierTotal = _selectedModifiers().fold<double>(
      0,
      (sum, modifier) => sum + modifier.priceAdjustment * modifier.quantity,
    );
    return (_selectedVariant?.price ?? widget.item.price) + modifierTotal;
  }

  List<_SelectedModifier> _selectedModifiers() {
    final selections = <_SelectedModifier>[];
    for (final group in widget.item.modifierGroups) {
      final optionIds = _selectedOptions[group.id] ?? const <String>{};
      for (final option in group.options) {
        if (!optionIds.contains(option.id)) {
          continue;
        }
        selections.add(
          _SelectedModifier(
            groupId: group.id,
            groupName: group.name,
            optionId: option.id,
            optionName: option.name,
            priceAdjustment: option.priceAdjustment,
          ),
        );
      }
    }
    return selections;
  }

  void _toggleOption(_ModifierGroup group, _ModifierOption option) {
    final selected = Set<String>.of(
      _selectedOptions[group.id] ?? const <String>{},
    );
    if (group.isSingle) {
      if (selected.contains(option.id) && !group.isRequired) {
        selected.clear();
      } else {
        selected
          ..clear()
          ..add(option.id);
      }
    } else if (selected.contains(option.id)) {
      selected.remove(option.id);
    } else {
      if (selected.length >= group.maxSelections) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Choose up to ${group.maxSelections} for ${group.name}.',
            ),
          ),
        );
        return;
      }
      selected.add(option.id);
    }

    setState(() {
      if (selected.isEmpty) {
        _selectedOptions.remove(group.id);
      } else {
        _selectedOptions[group.id] = selected;
      }
    });
  }

  String? _validationMessage() {
    for (final group in widget.item.modifierGroups) {
      final count = _selectedOptions[group.id]?.length ?? 0;
      if (count < group.minSelections) {
        return 'Choose at least ${group.minSelections} for ${group.name}.';
      }
      if (count > group.maxSelections) {
        return 'Choose up to ${group.maxSelections} for ${group.name}.';
      }
    }
    return null;
  }

  String _signedMoney(double value) {
    if (value == 0) {
      return '';
    }
    return value > 0
        ? '+${widget.money.format(value)}'
        : '-${widget.money.format(value.abs())}';
  }

  void _submit() {
    final message = _validationMessage();
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    final note = _nullableString(_noteController.text);
    Navigator.of(context).pop(
      _ItemChoiceSelection(
        variant: _selectedVariant,
        modifiers: _selectedModifiers(),
        note: note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var sectionNumber = 1;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840, maxHeight: 664),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 24, 20, 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox.square(
                      dimension: 108,
                      child: _MenuImage(imageUrl: widget.item.imageUrl),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 25,
                            height: 1.12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.money.format(widget.item.price),
                          style: const TextStyle(
                            color: Color(0xFF4F46E5),
                            fontSize: 25,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _DialogCloseButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(26, 24, 26, 30),
                children: [
                  if (widget.item.variants.isNotEmpty) ...[
                    _DialogOptionSection(
                      number: sectionNumber++,
                      title: 'Size',
                      meta: 'Optional',
                      child: _OptionChoiceGrid(
                        children: widget.item.variants.map((variant) {
                          final delta = variant.price - widget.item.price;
                          return _OptionChoiceTile(
                            label: variant.name,
                            priceLabel: _signedMoney(delta),
                            selected: _selectedVariant?.id == variant.id,
                            multiple: false,
                            onTap: () {
                              setState(() {
                                _selectedVariant =
                                    _selectedVariant?.id == variant.id
                                    ? null
                                    : variant;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                  ...widget.item.modifierGroups.map((group) {
                    final selected =
                        _selectedOptions[group.id] ?? const <String>{};
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: _DialogOptionSection(
                        number: sectionNumber++,
                        title: group.name,
                        meta: group.isRequired ? 'Required' : 'Optional',
                        helper: group.isSingle
                            ? 'Choose one'
                            : 'Choose up to ${group.maxSelections}',
                        isRequired: group.isRequired,
                        child: _OptionChoiceGrid(
                          children: group.options.map((option) {
                            return _OptionChoiceTile(
                              label: option.name,
                              priceLabel: _signedMoney(option.priceAdjustment),
                              selected: selected.contains(option.id),
                              multiple: !group.isSingle,
                              onTap: () => _toggleOption(group, option),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }),
                  _DialogOptionSection(
                    number: sectionNumber,
                    title: 'Special Instructions',
                    meta: 'Optional',
                    child: _SpecialInstructionsBox(controller: _noteController),
                  ),
                ],
              ),
            ),
            Container(
              height: 100,
              padding: const EdgeInsets.fromLTRB(26, 18, 26, 20),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 230,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.money.format(_previewPrice),
                          style: const TextStyle(
                            color: Color(0xFF4F46E5),
                            fontSize: 30,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFA5A4F2),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submit,
                        child: const Text('Add to ticket'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogCloseButton extends StatelessWidget {
  const _DialogCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: const Icon(Icons.close, color: Color(0xFFE11D48), size: 22),
      ),
    );
  }
}

class _DialogOptionSection extends StatelessWidget {
  const _DialogOptionSection({
    required this.number,
    required this.title,
    required this.meta,
    required this.child,
    this.helper,
    this.isRequired = false,
  });

  final int number;
  final String title;
  final String meta;
  final String? helper;
  final Widget child;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF4F46E5),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '($meta)',
              style: TextStyle(
                color: isRequired
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 46),
            child: Text(
              helper!,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _OptionChoiceGrid extends StatelessWidget {
  const _OptionChoiceGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumn = constraints.maxWidth >= 600;
        final itemWidth = twoColumn
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}

class _OptionChoiceTile extends StatelessWidget {
  const _OptionChoiceTile({
    required this.label,
    required this.priceLabel,
    required this.selected,
    required this.multiple,
    required this.onTap,
  });

  final String label;
  final String priceLabel;
  final bool selected;
  final bool multiple;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF5F3FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            _SelectionMark(selected: selected, multiple: multiple),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (priceLabel.isNotEmpty) ...[
              const SizedBox(width: 12),
              Text(
                priceLabel,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.selected, required this.multiple});

  final bool selected;
  final bool multiple;

  @override
  Widget build(BuildContext context) {
    if (multiple) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
            width: 2,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      );
    }
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
          width: 2,
        ),
      ),
      child: selected
          ? Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF4F46E5),
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

class _SpecialInstructionsBox extends StatelessWidget {
  const _SpecialInstructionsBox({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextField(
          controller: controller,
          minLines: 4,
          maxLines: 4,
          maxLength: 120,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Add a note or special request...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F46E5)),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 12,
          child: Text(
            '${controller.text.length}/120',
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeldTicketsOverlay extends StatelessWidget {
  const _HeldTicketsOverlay({required this.tickets, required this.money});

  final List<_HeldTicket> tickets;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.34)),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: _HeldTicketsSheet(tickets: tickets, money: money),
        ),
      ],
    );
  }
}

class _HeldTicketsSheet extends StatelessWidget {
  const _HeldTicketsSheet({required this.tickets, required this.money});

  final List<_HeldTicket> tickets;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 18,
      child: SizedBox(
        width: 560,
        height: double.infinity,
        child: Column(
          children: [
            Container(
              height: 70,
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Open tickets',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 22,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Held drafts \u00B7 today',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 15,
                            height: 1.1,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: tickets.isEmpty
                  ? const Center(
                      child: Text(
                        'No held tickets. Use Park to save a draft for later.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 16,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                      itemCount: tickets.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        return _HeldTicketCard(ticket: ticket, money: money);
                      },
                    ),
            ),
            Container(
              height: 48,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: const Text(
                'F4 open \u00B7 F2 park \u00B7 Shift+Enter charge',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeldTicketCard extends StatelessWidget {
  const _HeldTicketCard({required this.ticket, required this.money});

  final _HeldTicket ticket;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    final customer = ticket.customerName?.trim();
    final note = ticket.orderNotes?.trim();
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).pop(ticket),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFF475569),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Ticket ${ticket.token}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        money.format(ticket.total),
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${ticket.itemCount} items \u00B7 ${_orderTypeLabel(ticket.orderType)}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (customer != null && customer.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      customer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 14,
                      ),
                    ),
                  ],
                  if (note != null && note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(ticket),
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text('Resume'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.icon,
    required this.caption,
    required this.label,
  });

  final IconData icon;
  final String caption;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                caption.toUpperCase(),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.color,
    this.textColor = const Color(0xFF111827),
  });

  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _CatalogCategory {
  const _CatalogCategory({
    required this.id,
    required this.name,
    required this.items,
    this.imageUrl,
  });

  final String id;
  final String name;
  final List<_CatalogItem> items;
  final String? imageUrl;

  factory _CatalogCategory.fromJson(Map<String, dynamic> json) {
    final id = _stringValue(json['id'] ?? json['uuid'] ?? json['slug']);
    final name = _stringValue(
      json['name'] ?? json['title'],
      fallback: 'Category',
    );
    final rawItems = _firstMapList(json, const [
      'items',
      'menu_items',
      'menuItems',
      'products',
    ]);
    return _CatalogCategory(
      id: id.isEmpty ? name : id,
      name: name,
      imageUrl: _imageUrlFromJson(json),
      items: rawItems
          .map(
            (item) => _CatalogItem.fromJson(
              item,
              categoryName: name,
              categoryId: id.isEmpty ? name : id,
            ),
          )
          .where((item) => item.id.isNotEmpty)
          .toList(),
    );
  }
}

class _ItemVariant {
  const _ItemVariant({
    required this.id,
    required this.name,
    required this.price,
  });

  final String id;
  final String name;
  final double price;

  factory _ItemVariant.fromJson(
    Map<String, dynamic> json, {
    required double basePrice,
  }) {
    final priceSource =
        json['price'] ??
        json['selling_price'] ??
        json['base_price'] ??
        json['amount'] ??
        json['final_price'];
    final adjustment = _doubleValue(
      json['price_adjustment'] ??
          json['priceAdjustment'] ??
          json['adjustment'] ??
          json['additional_price'] ??
          json['additionalPrice'] ??
          json['extra_price'] ??
          json['extraPrice'] ??
          _deepValue(json, 'pivot.price_adjustment') ??
          _deepValue(json, 'pivot.additional_price'),
    );
    return _ItemVariant(
      id: _stringValue(
        json['id'] ??
            json['variant_id'] ??
            json['variantId'] ??
            json['variation_id'] ??
            json['variationId'] ??
            json['item_variant_id'] ??
            json['itemVariantId'] ??
            json['uuid'],
      ),
      name: _stringValue(
        json['name'] ??
            json['title'] ??
            json['label'] ??
            json['value'] ??
            json['option_name'] ??
            json['optionName'],
        fallback: 'Variant',
      ),
      price: priceSource == null
          ? basePrice + adjustment
          : _doubleValue(priceSource, fallback: basePrice),
    );
  }
}

class _ModifierGroup {
  const _ModifierGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.minSelections,
    required this.maxSelections,
    required this.options,
  });

  final String id;
  final String name;
  final String type;
  final int minSelections;
  final int maxSelections;
  final List<_ModifierOption> options;

  bool get isSingle =>
      type.toLowerCase().contains('single') || maxSelections == 1;
  bool get isRequired => minSelections > 0;

  factory _ModifierGroup.fromJson(Map<String, dynamic> json) {
    final rawOptions = _firstMapList(json, const [
      'options',
      'modifier_options',
      'modifierOptions',
      'modifier_items',
      'modifierItems',
      'values',
      'choices',
      'items',
    ]);
    final options = rawOptions
        .map(_ModifierOption.fromJson)
        .where((option) => option.id.isNotEmpty)
        .toList();
    final type = _stringValue(
      json['type'] ?? json['selection_type'] ?? json['selectionType'],
      fallback: 'multiple',
    );
    final max = _intValue(
      json['max_selections'] ??
          json['maxSelections'] ??
          json['maximum'] ??
          json['max'] ??
          _deepValue(json, 'pivot.max_selections'),
      fallback: type.toLowerCase().contains('single') ? 1 : options.length,
    );
    final name = _stringValue(
      json['name'] ?? json['title'] ?? json['label'],
      fallback: 'Options',
    );
    final id = _stringValue(
      json['id'] ??
          json['modifier_id'] ??
          json['modifierId'] ??
          json['modifier_group_id'] ??
          json['modifierGroupId'] ??
          json['uuid'],
      fallback: name,
    );
    return _ModifierGroup(
      id: id,
      name: name,
      type: type,
      minSelections: _intValue(
        json['min_selections'] ??
            json['minSelections'] ??
            json['minimum'] ??
            json['min'] ??
            _deepValue(json, 'pivot.min_selections'),
      ),
      maxSelections: max <= 0 ? options.length : max,
      options: options,
    );
  }
}

class _ModifierOption {
  const _ModifierOption({
    required this.id,
    required this.name,
    required this.priceAdjustment,
  });

  final String id;
  final String name;
  final double priceAdjustment;

  factory _ModifierOption.fromJson(Map<String, dynamic> json) {
    return _ModifierOption(
      id: _stringValue(
        json['id'] ??
            json['option_id'] ??
            json['optionId'] ??
            json['modifier_option_id'] ??
            json['modifierOptionId'] ??
            json['uuid'],
      ),
      name: _stringValue(
        json['name'] ??
            json['title'] ??
            json['label'] ??
            json['value'] ??
            json['option_name'] ??
            json['optionName'],
        fallback: 'Option',
      ),
      priceAdjustment: _doubleValue(
        json['price_adjustment'] ??
            json['priceAdjustment'] ??
            json['additional_price'] ??
            json['additionalPrice'] ??
            json['extra_price'] ??
            json['extraPrice'] ??
            json['price'] ??
            json['amount'] ??
            _deepValue(json, 'pivot.price_adjustment') ??
            _deepValue(json, 'pivot.additional_price'),
      ),
    );
  }
}

class _SelectedModifier {
  const _SelectedModifier({
    required this.groupId,
    required this.groupName,
    required this.optionId,
    required this.optionName,
    required this.priceAdjustment,
  });

  final String groupId;
  final String groupName;
  final String optionId;
  final String optionName;
  final double priceAdjustment;

  int get quantity => 1;
  String get identity => '$groupId:$optionId';
  String get label => priceAdjustment == 0
      ? optionName
      : '$optionName (${priceAdjustment > 0 ? '+' : ''}${priceAdjustment.toStringAsFixed(2)})';

  Map<String, dynamic> toApiPayload() {
    return {
      'modifier_option_id': apiIdentifierFromString(optionId),
      'modifier_name': groupName,
      'option_name': optionName,
      'price_adjustment': _moneyValue(priceAdjustment),
      'quantity': quantity,
    };
  }

  Map<String, dynamic> toDisplayJson() {
    return {
      'modifier_name': groupName,
      'option_name': optionName,
      'price_adjustment': _moneyValue(priceAdjustment),
      'quantity': quantity,
    };
  }
}

class _ItemChoiceSelection {
  const _ItemChoiceSelection({
    this.variant,
    this.modifiers = const [],
    this.note,
  });

  final _ItemVariant? variant;
  final List<_SelectedModifier> modifiers;
  final String? note;
}

class _CatalogItem {
  const _CatalogItem({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    this.imageUrl,
    this.itemType,
    this.barcode,
    this.variants = const [],
    this.modifierGroups = const [],
    this.upsellItems = const [],
    this.upsellItemIds = const [],
  });

  final String id;
  final String name;
  final double price;
  final String categoryId;
  final String categoryName;
  final String? imageUrl;
  final String? itemType;
  final String? barcode;
  final List<_ItemVariant> variants;
  final List<_ModifierGroup> modifierGroups;
  final List<_CatalogItem> upsellItems;
  final List<String> upsellItemIds;

  bool get hasChoices => variants.isNotEmpty || modifierGroups.isNotEmpty;

  double get displayPrice {
    if (variants.isEmpty) {
      return price;
    }
    return variants.fold<double>(
      variants.first.price,
      (lowest, variant) => variant.price < lowest ? variant.price : lowest,
    );
  }

  bool get isVeg {
    final type = (itemType ?? '').toLowerCase();
    return !type.contains('non') && !type.contains('meat');
  }

  factory _CatalogItem.fromJson(
    Map<String, dynamic> json, {
    String categoryId = '',
    String categoryName = '',
    bool includeRelated = true,
  }) {
    final price = _doubleValue(
      json['price'] ?? json['selling_price'] ?? json['base_price'],
    );
    final rawUpsellItems = includeRelated
        ? _firstMapList(json, const [
            'upsell_items',
            'upsellItems',
            'upsells',
            'recommended_items',
            'recommendedItems',
            'suggested_items',
            'suggestedItems',
            'add_ons',
            'addons',
          ])
        : const <Map<String, dynamic>>[];
    final rawUpsellIds = _firstList(json, const [
      'upsell_item_ids',
      'upsellItemIds',
      'recommended_item_ids',
      'recommendedItemIds',
      'suggested_item_ids',
      'suggestedItemIds',
    ]);
    return _CatalogItem(
      id: _stringValue(json['id'] ?? json['menu_item_id'] ?? json['uuid']),
      name: _stringValue(json['name'] ?? json['title'], fallback: 'Menu item'),
      price: price,
      categoryId: _stringValue(
        json['category_id'] ?? json['categoryId'],
        fallback: categoryId,
      ),
      categoryName: _stringValue(
        json['category_name'] ?? json['categoryName'],
        fallback: categoryName,
      ),
      imageUrl: _imageUrlFromJson(json),
      itemType: _nullableString(json['item_type'] ?? json['itemType']),
      barcode: _nullableString(json['barcode'] ?? json['sku']),
      variants:
          _firstMapList(json, const [
                'variants',
                'variations',
                'item_variants',
                'itemVariants',
                'item_variations',
                'itemVariations',
                'variation_options',
                'variationOptions',
              ])
              .map(
                (variant) => _ItemVariant.fromJson(variant, basePrice: price),
              )
              .where((variant) => variant.id.isNotEmpty)
              .toList(),
      modifierGroups:
          _firstMapList(json, const [
                'modifiers',
                'modifier_groups',
                'modifierGroups',
                'modifier_categories',
                'modifierCategories',
                'item_modifiers',
                'itemModifiers',
                'modifier_sets',
                'modifierSets',
                'choice_groups',
                'choiceGroups',
                'option_groups',
                'optionGroups',
                'linked_modifiers',
                'linkedModifiers',
              ])
              .map(_ModifierGroup.fromJson)
              .where((group) => group.options.isNotEmpty)
              .toList(),
      upsellItems: rawUpsellItems
          .map(
            (item) => _CatalogItem.fromJson(
              item,
              categoryId: categoryId,
              categoryName: categoryName,
              includeRelated: false,
            ),
          )
          .where((item) => item.id.isNotEmpty)
          .toList(),
      upsellItemIds: _stringList(rawUpsellIds),
    );
  }
}

class _CartLine {
  const _CartLine({
    required this.item,
    this.quantity = 1,
    this.note,
    this.variant,
    this.modifiers = const [],
  });

  final _CatalogItem item;
  final int quantity;
  final String? note;
  final _ItemVariant? variant;
  final List<_SelectedModifier> modifiers;

  double get unitPrice {
    final modifierTotal = modifiers.fold<double>(
      0,
      (sum, modifier) => sum + modifier.priceAdjustment * modifier.quantity,
    );
    return (variant?.price ?? item.price) + modifierTotal;
  }

  double get total => unitPrice * quantity;

  List<String> get optionTags {
    return [
      if (variant != null) variant!.name,
      ...modifiers.map((modifier) => modifier.optionName),
    ];
  }

  String get optionSummary => optionTags.join(' - ');

  bool matches(_CartLine other) {
    if (item.id != other.item.id ||
        (variant?.id ?? '') != (other.variant?.id ?? '')) {
      return false;
    }
    final own = modifiers.map((modifier) => modifier.identity).toList();
    final incoming = other.modifiers
        .map((modifier) => modifier.identity)
        .toList();
    if (own.length != incoming.length) {
      return false;
    }
    for (var index = 0; index < own.length; index += 1) {
      if (own[index] != incoming[index]) {
        return false;
      }
    }
    return true;
  }

  static const _unchanged = Object();

  _CartLine copyWith({int? quantity, Object? note = _unchanged}) {
    return _CartLine(
      item: item,
      quantity: quantity ?? this.quantity,
      note: identical(note, _unchanged) ? this.note : note as String?,
      variant: variant,
      modifiers: modifiers,
    );
  }

  Map<String, dynamic> toDisplayJson() {
    return {
      'id': item.id,
      'name': item.name,
      if (variant != null) 'variant': variant!.name,
      'quantity': quantity,
      'unit_price': _moneyValue(unitPrice),
      'total': _moneyValue(total),
      if (modifiers.isNotEmpty)
        'modifiers': modifiers
            .map((modifier) => modifier.toDisplayJson())
            .toList(),
      if (note != null) 'note': note,
    };
  }
}

String _cartLineIdentity(_CartLine line) {
  final variantId = line.variant?.id ?? '';
  final modifierIds = line.modifiers
      .map((modifier) => modifier.identity)
      .join('|');
  return '${line.item.id}::$variantId::$modifierIds';
}

class _HeldTicket {
  const _HeldTicket({
    required this.token,
    required this.lines,
    required this.orderType,
    required this.createdAt,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.orderNotes,
    this.discount,
  });

  final int token;
  final List<_CartLine> lines;
  final String orderType;
  final DateTime createdAt;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final String? orderNotes;
  final _Discount? discount;

  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);
  double get total => lines.fold(0, (sum, line) => sum + line.total);
}

class _Discount {
  const _Discount({
    required this.type,
    required this.value,
    required this.reason,
  });

  final String type;
  final double value;
  final String reason;

  Map<String, dynamic> toApiPayload() {
    return {
      'type': type,
      'value': value,
      if (reason.isNotEmpty) 'reason': reason,
    };
  }
}

Map<String, dynamic>? _extractShift(Map<String, dynamic> source) {
  if (source.isEmpty) {
    return null;
  }
  for (final key in const ['shift', 'current_shift', 'currentShift']) {
    final value = source[key];
    if (value is Map) {
      return _extractShift(Map<String, dynamic>.from(value)) ??
          Map<String, dynamic>.from(value);
    }
  }
  final data = source['data'];
  if (data is Map) {
    return _extractShift(Map<String, dynamic>.from(data));
  }
  return source;
}

String _activeStaffName(Map<String, dynamic>? shift, {String? fallback}) {
  final shiftName = shift == null ? '' : _shiftLabel(shift).trim();
  if (shiftName.isNotEmpty && shiftName != 'Open' && shiftName != 'Closed') {
    return shiftName;
  }
  return fallback?.trim() ?? '';
}

String _shiftLabel(Map<String, dynamic>? shift) {
  if (shift == null) {
    return 'Closed';
  }
  final label = _firstText(shift, const [
    'staff_name',
    'staffName',
    'user_name',
    'userName',
    'opened_by_name',
    'openedByName',
    'opened_by.name',
    'openedBy.name',
    'user.name',
    'staff.name',
    'name',
  ]);
  return label.isEmpty ? 'Open' : label;
}

double _summaryAmount(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = _deepValue(source, key);
    if (value != null) {
      return _doubleValue(value);
    }
  }
  return 0;
}

int _summaryInt(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = _deepValue(source, key);
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) {
      return parsed;
    }
  }
  return 0;
}

Object? _deepValue(Map<String, dynamic> source, String key) {
  final parts = key.split('.');
  Object? current = source;
  for (final part in parts) {
    if (current is Map) {
      current = current[part];
    } else {
      return null;
    }
  }
  return current;
}

String _firstText(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = _deepValue(source, key);
    if (value is Map || value is List) {
      continue;
    }
    final text = _stringValue(value).trim();
    if (text.isNotEmpty) {
      return text;
    }
  }
  return '';
}

String _orderKey(Map<String, dynamic> order) {
  return _stringValue(
    order['id'] ??
        order['order_number'] ??
        order['number'] ??
        order['token'] ??
        order['reference'],
  );
}

String _orderTypeLabel(String value) {
  switch (value) {
    case 'takeaway':
      return 'Takeaway';
    case 'delivery':
      return 'Delivery';
    case 'dine_in':
    default:
      return 'Dine in';
  }
}

List<Map<String, dynamic>> _firstMapList(
  Map<String, dynamic> source,
  List<String> keys,
) {
  for (final key in keys) {
    final list = _asMapList(source[key]);
    if (list.isNotEmpty) {
      return list;
    }
  }
  return const [];
}

List<Object?> _firstList(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is List && value.isNotEmpty) {
      return List<Object?>.from(value);
    }
  }
  return const [];
}

List<Map<String, dynamic>> _asMapList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .map((item) {
        if (item is Map) {
          return _stringValue(
            item['id'] ?? item['menu_item_id'] ?? item['uuid'],
          );
        }
        return _stringValue(item);
      })
      .where((item) => item.isNotEmpty)
      .toList();
}

String _stringValue(Object? value, {String fallback = ''}) {
  final text = value?.toString();
  return text == null || text.isEmpty ? fallback : text;
}

String? _nullableString(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int _intValue(Object? value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _doubleValue(Object? value, {double fallback = 0}) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

double _parseAmount(String value) {
  return double.tryParse(value.trim().replaceAll(',', '')) ?? 0;
}

double _moneyValue(double value) {
  return (value * 100).roundToDouble() / 100;
}

bool _samePrinterDevice(PrinterDeviceInfo a, PrinterDeviceInfo? b) {
  return b != null &&
      a.connectionType == b.connectionType &&
      a.name == b.name &&
      (a.address ?? '') == (b.address ?? '') &&
      (a.vendorId ?? '') == (b.vendorId ?? '') &&
      (a.productId ?? '') == (b.productId ?? '');
}

String _errorMessage(Object error) {
  return error is AppException ? error.message : error.toString();
}

String? _imageUrlFromJson(Map<String, dynamic> json) {
  for (final key in const [
    'image_url',
    'imageUrl',
    'image_path',
    'imagePath',
    'thumbnail_url',
    'thumbnailUrl',
    'photo_url',
    'photoUrl',
    'picture_url',
    'pictureUrl',
    'cover_image',
    'coverImage',
    'image',
    'thumbnail',
    'photo',
    'picture',
    'media',
    'images',
    'photos',
  ]) {
    final value = _imageUrlFromValue(json[key]);
    if (value != null) {
      return value;
    }
  }
  return null;
}

String? _imageUrlFromValue(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is String || value is num) {
    return _normalizeImageUrl(_nullableString(value));
  }
  if (value is List) {
    for (final item in value) {
      final nested = _imageUrlFromValue(item);
      if (nested != null) {
        return nested;
      }
    }
  }
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    for (final key in const [
      'url',
      'original_url',
      'originalUrl',
      'preview_url',
      'previewUrl',
      'path',
      'src',
      'file',
      'image_url',
      'imageUrl',
      'thumbnail_url',
      'thumbnailUrl',
    ]) {
      final nested = _imageUrlFromValue(map[key]);
      if (nested != null) {
        return nested;
      }
    }
  }
  return null;
}

String? _normalizeImageUrl(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  final uri = Uri.tryParse(raw);
  if (uri != null && uri.hasScheme) {
    return raw;
  }
  final base = AppConfig.baseUrl.endsWith('/')
      ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
      : AppConfig.baseUrl;
  final path = raw.startsWith('/') ? raw : '/$raw';
  return '$base$path';
}
