import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth/auth_controller.dart';
import '../../auth/login_screen.dart';
import '../../display/kitchen_display_screen.dart';
import '../../pos/pos_shell_screen.dart';
import '../application/customer_display_controller.dart';
import '../domain/customer_display_models.dart';
import '../../../widgets/exit_confirmation_dialog.dart';

class CustomerDisplayPage extends ConsumerStatefulWidget {
  const CustomerDisplayPage({super.key});

  static const routePath = '/customer-display';

  @override
  ConsumerState<CustomerDisplayPage> createState() =>
      _CustomerDisplayPageState();
}

class _CustomerDisplayPageState extends ConsumerState<CustomerDisplayPage> {
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  bool _fullscreen = true;
  bool _controlsVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(customerDisplayControllerProvider.notifier).showOrderBoard();
      }
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerDisplayControllerProvider);

    return MouseRegion(
      onEnter: (_) => setState(() => _controlsVisible = true),
      onExit: (_) => setState(() => _controlsVisible = false),
      child: Scaffold(
        backgroundColor: _DisplayColors.background,
        body: Stack(
          children: [
            const _GridBackdrop(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      _TopBar(
                        state: state,
                        now: _now,
                        compact: constraints.maxWidth < 900,
                        controlsVisible:
                            _controlsVisible || constraints.maxWidth < 900,
                        fullscreen: _fullscreen,
                        onKitchenDisplay: () =>
                            context.go(KitchenDisplayScreen.routePath),
                        onSetup: () => _showSetupSheet(context, state),
                        onFullscreen: _toggleFullscreen,
                        onLogout: _confirmLogout,
                      ),
                      const _InstructionBand(),
                      if (state.errorMessage != null)
                        _ErrorBand(
                          message: state.errorMessage!,
                          onRetry: () => ref
                              .read(customerDisplayControllerProvider.notifier)
                              .refresh(),
                        ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(
                            constraints.maxWidth < 900 ? 12 : 18,
                          ),
                          child: _OrderHistoryPanel(
                            preparing: state.preparing,
                            ready: state.ready,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (state.isLoading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x99000000),
                  child: Center(
                    child: SizedBox(
                      width: 54,
                      height: 54,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        color: _DisplayColors.mint,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFullscreen() async {
    setState(() => _fullscreen = !_fullscreen);
    await SystemChrome.setEnabledSystemUIMode(
      _fullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Logout?',
          style: TextStyle(color: Color(0xFF111827)),
        ),
        content: const Text(
          'Exit the order board and sign out from this device?',
          style: TextStyle(color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout != true || !mounted) {
      return;
    }
    await ref.read(authControllerProvider.notifier).logout();
    if (mounted) {
      context.go(LoginScreen.routePath);
    }
  }

  Future<void> _showSetupSheet(
    BuildContext context,
    CustomerDisplayState state,
  ) async {
    final slugController = TextEditingController(text: state.restaurantSlug);
    final branchController = TextEditingController(
      text: state.branchId.toString(),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SetupSheet(
          slugController: slugController,
          branchController: branchController,
          isSaving: state.isSavingSetup,
          onSave: () async {
            await ref
                .read(customerDisplayControllerProvider.notifier)
                .saveSetup(
                  restaurantSlug: slugController.text,
                  branchId: int.tryParse(branchController.text.trim()) ?? 1,
                  terminalCode: state.terminalCode,
                  syncToken: state.syncToken,
                );
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        );
      },
    );
  }
}

class CustomerCartDisplayPage extends ConsumerStatefulWidget {
  const CustomerCartDisplayPage({super.key, this.branchId, this.terminalCode});

  static const routePath = '/customer-cart-display';

  static String routeFor({
    required int branchId,
    required String terminalCode,
  }) {
    return '/order/oneness/display/$branchId/${Uri.encodeComponent(terminalCode)}';
  }

  final int? branchId;
  final String? terminalCode;

  @override
  ConsumerState<CustomerCartDisplayPage> createState() =>
      _CustomerCartDisplayPageState();
}

class _CustomerCartDisplayPageState
    extends ConsumerState<CustomerCartDisplayPage> {
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  bool _fullscreen = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(customerDisplayControllerProvider.notifier)
            .showCartDisplay(
              branchId: widget.branchId,
              terminalCode: widget.terminalCode,
            );
      }
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void didUpdateWidget(covariant CustomerCartDisplayPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.branchId != widget.branchId ||
        oldWidget.terminalCode != widget.terminalCode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(customerDisplayControllerProvider.notifier)
              .showCartDisplay(
                branchId: widget.branchId,
                terminalCode: widget.terminalCode,
              );
        }
      });
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerDisplayControllerProvider);
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 760;

    return Scaffold(
      backgroundColor: _CartDisplayColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _CartDisplayBackdrop()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 18 : 28,
                    vertical: compact ? 18 : 34,
                  ),
                  child: Column(
                    children: [
                      _CartDisplayTopBar(
                        state: state,
                        now: _now,
                        fullscreen: _fullscreen,
                        onFullscreen: _toggleFullscreen,
                        onExitToPos: _exitToPos,
                      ),
                      SizedBox(height: compact ? 26 : 42),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: _CartDisplayContent(
                            state: state,
                            compact: compact,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (state.isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33FFFFFF),
                child: Center(
                  child: CircularProgressIndicator(
                    color: _CartDisplayColors.purple,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _toggleFullscreen() async {
    setState(() => _fullscreen = !_fullscreen);
    await SystemChrome.setEnabledSystemUIMode(
      _fullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  Future<void> _exitToPos() async {
    final shouldExit = await showExitConfirmationDialog(
      context,
      title: 'Exit customer display?',
      message: 'Return to the POS screen?',
      confirmLabel: 'Go to POS',
    );
    if (!shouldExit || !mounted) {
      return;
    }
    context.go(PosShellScreen.routePath);
  }
}

class _CartDisplayTopBar extends StatelessWidget {
  const _CartDisplayTopBar({
    required this.state,
    required this.now,
    required this.fullscreen,
    required this.onFullscreen,
    required this.onExitToPos,
  });

  final CustomerDisplayState state;
  final DateTime now;
  final bool fullscreen;
  final VoidCallback onFullscreen;
  final VoidCallback onExitToPos;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(now);
    final date = DateFormat('EEEE d MMMM').format(now);
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE9E4F8)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset('assets/images/mainlogo.png'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.restaurantName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _CartDisplayColors.purple,
                  fontSize: 28,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${state.branchName} · ${state.terminalCode}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              date,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(width: 18),
        Tooltip(
          message: fullscreen ? 'Exit fullscreen' : 'Fullscreen',
          child: SizedBox.square(
            dimension: 48,
            child: IconButton(
              onPressed: onFullscreen,
              style: IconButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFBFDBFE), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(fullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Tooltip(
          message: 'Back to POS',
          child: SizedBox.square(
            dimension: 48,
            child: IconButton(
              onPressed: onExitToPos,
              style: IconButton.styleFrom(
                foregroundColor: const Color(0xFF0F172A),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.logout),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartDisplayContent extends StatelessWidget {
  const _CartDisplayContent({required this.state, required this.compact});

  final CustomerDisplayState state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cart = state.cart;
    final items = cart.items;
    final money = NumberFormat.simpleCurrency(name: cart.currency);
    final total = cart.total > 0
        ? cart.total
        : items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    final subtotal = cart.subtotal > 0 ? cart.subtotal : total;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CartItemsCard(items: items, money: money, compact: compact),
        const SizedBox(height: 20),
        _CartTotalsCard(subtotal: subtotal, total: total, money: money),
        const SizedBox(height: 44),
        const Text(
          'Thank you for dining with us!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          items.isEmpty
              ? 'Your order will appear here once items are added.'
              : 'Please proceed to payment to finalize your order.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 18),
          Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFDC2626),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _CartItemsCard extends StatelessWidget {
  const _CartItemsCard({
    required this.items,
    required this.money,
    required this.compact,
  });

  final List<CustomerCartItem> items;
  final NumberFormat money;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 18 : 34,
              compact ? 20 : 28,
              compact ? 18 : 34,
              compact ? 18 : 26,
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: _CartDisplayColors.purple,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Text(
                    'Review Your Order',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF030712),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _CartDisplayColors.purple,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x558B5CF6),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Text(
                    '${items.length} item${items.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 56,
            color: const Color(0xFFF8FAFC),
            padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 34),
            child: const Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text('QTY', style: _cartHeaderStyle),
                ),
                Expanded(child: Text('ITEM NAME', style: _cartHeaderStyle)),
                SizedBox(
                  width: 132,
                  child: Text(
                    'AMOUNT',
                    textAlign: TextAlign.right,
                    style: _cartHeaderStyle,
                  ),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 44),
              child: Text(
                'No items in the cart',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            for (var index = 0; index < items.length; index += 1)
              _CartItemRow(
                item: items[index],
                money: money,
                compact: compact,
                showDivider: index != items.length - 1,
              ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({
    required this.item,
    required this.money,
    required this.compact,
    required this.showDivider,
  });

  final CustomerCartItem item;
  final NumberFormat money;
  final bool compact;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 82 : 96,
      padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 34),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F0FF),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFFE9D5FF)),
                ),
                child: Text(
                  item.quantity.toString(),
                  style: const TextStyle(
                    color: _CartDisplayColors.purple,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 21,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(
            width: 132,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                money.format(item.lineTotal),
                style: const TextStyle(
                  color: Color(0xFF030712),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartTotalsCard extends StatelessWidget {
  const _CartTotalsCard({
    required this.subtotal,
    required this.total,
    required this.money,
  });

  final double subtotal;
  final double total;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(34, 26, 34, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Subtotal',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                money.format(subtotal),
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 26),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'Grand Total',
                  style: TextStyle(
                    color: Color(0xFF030712),
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  money.format(total),
                  style: const TextStyle(
                    color: _CartDisplayColors.purple,
                    fontSize: 44,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartDisplayBackdrop extends StatelessWidget {
  const _CartDisplayBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.25, -0.25),
          radius: 0.78,
          colors: [
            _CartDisplayColors.purple.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

const _cartHeaderStyle = TextStyle(
  color: Color(0xFF64748B),
  fontSize: 14,
  letterSpacing: 1.8,
  fontWeight: FontWeight.w900,
);

class _CartDisplayColors {
  const _CartDisplayColors._();

  static const background = Color(0xFFFEFEFF);
  static const purple = Color(0xFF8B5CF6);
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.state,
    required this.now,
    required this.compact,
    required this.controlsVisible,
    required this.fullscreen,
    required this.onKitchenDisplay,
    required this.onSetup,
    required this.onFullscreen,
    required this.onLogout,
  });

  final CustomerDisplayState state;
  final DateTime now;
  final bool compact;
  final bool controlsVisible;
  final bool fullscreen;
  final VoidCallback onKitchenDisplay;
  final VoidCallback onSetup;
  final VoidCallback onFullscreen;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm:ss').format(now);
    final date = DateFormat('EEE d MMM').format(now).toUpperCase();

    return Container(
      height: compact ? 108 : 126,
      padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 28),
      decoration: const BoxDecoration(
        color: _DisplayColors.background,
        border: Border(bottom: BorderSide(color: _DisplayColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 48 : 58,
            height: compact ? 48 : 58,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF17171B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2E2E35)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x6634D399),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset('assets/images/mainlogo.png'),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.restaurantName,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 26 : 34,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.branchName,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                    color: _DisplayColors.muted,
                    fontSize: compact ? 15 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (!compact) _ConnectionPill(online: state.errorMessage == null),
          if (!compact) const SizedBox(width: 12),
          _ClockCard(time: time, date: date, compact: compact),
          const SizedBox(width: 10),
          _KitchenDisplayButton(onPressed: onKitchenDisplay),
          const SizedBox(width: 10),
          _HoverControls(
            visible: controlsVisible,
            fullscreen: fullscreen,
            onSetup: onSetup,
            onFullscreen: onFullscreen,
            onLogout: onLogout,
          ),
        ],
      ),
    );
  }
}

class _ClockCard extends StatelessWidget {
  const _ClockCard({
    required this.time,
    required this.date,
    required this.compact,
  });

  final String time;
  final String date;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 62 : 78,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 18),
      decoration: BoxDecoration(
        color: _DisplayColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _DisplayColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 20 : 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            date,
            style: const TextStyle(
              color: _DisplayColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionPill extends StatelessWidget {
  const _ConnectionPill({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    final color = online ? _DisplayColors.mint : _DisplayColors.orange;
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _withAlpha(color, 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _withAlpha(color, 0.34)),
      ),
      child: Row(
        children: [
          Icon(
            online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            online ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverControls extends StatelessWidget {
  const _HoverControls({
    required this.visible,
    required this.fullscreen,
    required this.onSetup,
    required this.onFullscreen,
    required this.onLogout,
  });

  final bool visible;
  final bool fullscreen;
  final VoidCallback onSetup;
  final VoidCallback onFullscreen;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: visible ? 1 : 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xEE17171B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2E2E35)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x88000000),
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HoverIconButton(
                  tooltip: fullscreen ? 'Exit fullscreen' : 'Fullscreen',
                  icon: fullscreen ? Icons.fullscreen_exit : Icons.open_in_full,
                  onPressed: onFullscreen,
                ),
                _HoverIconButton(
                  tooltip: 'Display setup',
                  icon: Icons.tune,
                  onPressed: onSetup,
                ),
                _HoverIconButton(
                  tooltip: 'Logout',
                  icon: Icons.logout,
                  onPressed: onLogout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KitchenDisplayButton extends StatelessWidget {
  const _KitchenDisplayButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Kitchen display',
      child: SizedBox(
        height: 46,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: _DisplayColors.border),
            backgroundColor: const Color(0xFF17171B),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w900),
          ),
          icon: const Icon(Icons.soup_kitchen_outlined, size: 18),
          label: const Text('Kitchen display'),
        ),
      ),
    );
  }
}

class _HoverIconButton extends StatelessWidget {
  const _HoverIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 350),
      child: SizedBox(
        width: 44,
        height: 44,
        child: IconButton(
          onPressed: onPressed,
          color: const Color(0xFFEDEDF2),
          icon: Icon(icon, size: 21),
        ),
      ),
    );
  }
}

class _ErrorBand extends StatelessWidget {
  const _ErrorBand({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2B1717),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Color(0xFFFFA7A7)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFFD6D6),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _InstructionBand extends StatelessWidget {
  const _InstructionBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: _DisplayColors.background,
        border: Border(bottom: BorderSide(color: _DisplayColors.border)),
      ),
      child: const Text(
        'Watch for your token number. When it appears under Ready, please collect your order at the counter.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFFB7B4BE),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OrderHistoryPanel extends StatelessWidget {
  const _OrderHistoryPanel({required this.preparing, required this.ready});

  final List<CustomerDisplayOrder> preparing;
  final List<CustomerDisplayOrder> ready;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;
        final children = [
          Expanded(
            child: _TokenColumnPanel(
              title: 'PREPARING',
              subtitle: 'Your order is being made',
              orders: preparing,
              color: _DisplayColors.orange,
              icon: Icons.bakery_dining_outlined,
              ready: false,
            ),
          ),
          Expanded(
            child: _TokenColumnPanel(
              title: 'READY TO COLLECT',
              subtitle: 'Please pick up at the counter',
              orders: ready,
              color: _DisplayColors.mint,
              icon: Icons.check_circle_outline_rounded,
              ready: true,
            ),
          ),
        ];
        if (compact) {
          return Column(
            children: [children[1], const SizedBox(height: 12), children[0]],
          );
        }
        return Row(
          children: [children[0], const SizedBox(width: 28), children[1]],
        );
      },
    );
  }
}

class _TokenColumnPanel extends StatelessWidget {
  const _TokenColumnPanel({
    required this.title,
    required this.subtitle,
    required this.orders,
    required this.color,
    required this.icon,
    required this.ready,
  });

  final String title;
  final String subtitle;
  final List<CustomerDisplayOrder> orders;
  final Color color;
  final IconData icon;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xF20C0C0F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _withAlpha(color, ready ? 0.34 : 0.28)),
        boxShadow: [
          BoxShadow(
            color: _withAlpha(color, 0.10),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 112,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: _withAlpha(color, ready ? 0.12 : 0.16),
              border: Border(
                bottom: BorderSide(color: _withAlpha(color, 0.24)),
              ),
            ),
            child: Row(
              children: [
                _HeaderIcon(icon: icon, color: color),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: const TextStyle(
                          color: Color(0xFFF6F1E8),
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: const TextStyle(
                          color: _DisplayColors.muted,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _CountBadge(count: orders.length, color: color),
              ],
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? _EmptyState(
                    color: color,
                    title: ready ? 'No ready tokens' : 'No preparing tokens',
                    body: ready
                        ? 'Ready orders will appear here.'
                        : 'Preparing orders will appear here.',
                    icon: icon,
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = ready
                          ? (constraints.maxWidth / 220).floor().clamp(2, 4)
                          : (constraints.maxWidth / 190).floor().clamp(2, 5);
                      return GridView.builder(
                        padding: const EdgeInsets.all(24),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 18,
                          crossAxisSpacing: 18,
                          childAspectRatio: ready ? 1.08 : 1.32,
                        ),
                        itemCount: orders.length,
                        itemBuilder: (context, index) => _TokenTile(
                          order: orders[index],
                          color: color,
                          ready: ready,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TokenTile extends StatelessWidget {
  const _TokenTile({
    required this.order,
    required this.color,
    required this.ready,
  });

  final CustomerDisplayOrder order;
  final Color color;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _withAlpha(color, ready ? 0.56 : 0.22)),
        boxShadow: [
          BoxShadow(
            color: _withAlpha(color, ready ? 0.14 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TOKEN',
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                order.token,
                maxLines: 1,
                style: const TextStyle(
                  color: Color(0xFFF6F1E8),
                  fontSize: 78,
                  height: 0.95,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _withAlpha(color, 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _withAlpha(color, 0.32)),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: _withAlpha(color, 0.36),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.color,
    required this.title,
    required this.body,
    required this.icon,
  });

  final Color color;
  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: _withAlpha(color, 0.11),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _withAlpha(color, 0.28)),
              ),
              child: Icon(icon, color: _withAlpha(color, 0.72), size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFB8B6BF),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _DisplayColors.muted,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupSheet extends StatelessWidget {
  const _SetupSheet({
    required this.slugController,
    required this.branchController,
    required this.isSaving,
    required this.onSave,
  });

  final TextEditingController slugController;
  final TextEditingController branchController;
  final bool isSaving;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: bottom + 16),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune, color: _DisplayColors.mint),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Order Board Setup',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        color: const Color(0xFF111827),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SetupField(
                    controller: slugController,
                    label: 'Restaurant slug',
                    hint: 'kumar-bistro',
                  ),
                  const SizedBox(height: 12),
                  _SetupField(
                    controller: branchController,
                    label: 'Branch ID',
                    hint: '1',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: isSaving ? null : onSave,
                      style: FilledButton.styleFrom(
                        backgroundColor: _DisplayColors.mint,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(isSaving ? 'Saving setup' : 'Save setup'),
                    ),
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

class _SetupField extends StatelessWidget {
  const _SetupField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Color(0xFF111827),
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _DisplayColors.mint, width: 2),
        ),
      ),
    );
  }
}

class _GridBackdrop extends StatelessWidget {
  const _GridBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter(), child: const SizedBox.expand());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = _DisplayColors.background,
    );
    final paint = Paint()
      ..color = _withAlpha(const Color(0xFF1D1D20), 0.36)
      ..strokeWidth = 1;
    const step = 48.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DisplayColors {
  const _DisplayColors._();

  static const background = Color(0xFF08080A);
  static const surface = Color(0xFF17171B);
  static const border = Color(0xFF202024);
  static const muted = Color(0xFF8F8B98);
  static const orange = Color(0xFFFFB020);
  static const mint = Color(0xFF34D399);
}

Color _withAlpha(Color color, double alpha) {
  final normalized = alpha.clamp(0.0, 1.0);
  return color.withAlpha((normalized * 255).round());
}
