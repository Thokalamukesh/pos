import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../data/customer_display_repository.dart';
import '../domain/customer_display_models.dart';

final customerDisplayControllerProvider =
    NotifierProvider<CustomerDisplayController, CustomerDisplayState>(
      CustomerDisplayController.new,
    );

class CustomerDisplayState {
  const CustomerDisplayState({
    this.isLoading = true,
    this.isSavingSetup = false,
    this.errorMessage,
    this.restaurantName = 'Kumar Bistro',
    this.restaurantSlug = 'kumar-bistro',
    this.branchName = 'Kumar Bistro - Main',
    this.branchId = 1,
    this.terminalCode = 'T1',
    this.syncToken = '',
    this.showPrices = true,
    this.preparing = const [],
    this.ready = const [],
    this.history = const [],
    this.cart = const CustomerCart(active: false),
    this.lastUpdated,
  });

  final bool isLoading;
  final bool isSavingSetup;
  final String? errorMessage;
  final String restaurantName;
  final String restaurantSlug;
  final String branchName;
  final int branchId;
  final String terminalCode;
  final String syncToken;
  final bool showPrices;
  final List<CustomerDisplayOrder> preparing;
  final List<CustomerDisplayOrder> ready;
  final List<CustomerDisplayOrder> history;
  final CustomerCart cart;
  final DateTime? lastUpdated;

  bool get hasSyncToken => syncToken.trim().isNotEmpty;
  bool get needsSetup => restaurantSlug.trim().isEmpty || branchId <= 0;
  List<CustomerDisplayOrder> get orderHistory {
    final orders = history.isNotEmpty
        ? <CustomerDisplayOrder>[...history]
        : <CustomerDisplayOrder>[...ready, ...preparing];
    orders.sort((a, b) {
      final left = a.updatedAt;
      final right = b.updatedAt;
      if (left == null && right == null) {
        return a.token.compareTo(b.token);
      }
      if (left == null) {
        return 1;
      }
      if (right == null) {
        return -1;
      }
      return right.compareTo(left);
    });
    return orders;
  }

  CustomerDisplayState copyWith({
    bool? isLoading,
    bool? isSavingSetup,
    String? errorMessage,
    bool clearError = false,
    String? restaurantName,
    String? restaurantSlug,
    String? branchName,
    int? branchId,
    String? terminalCode,
    String? syncToken,
    bool? showPrices,
    List<CustomerDisplayOrder>? preparing,
    List<CustomerDisplayOrder>? ready,
    List<CustomerDisplayOrder>? history,
    CustomerCart? cart,
    DateTime? lastUpdated,
  }) {
    return CustomerDisplayState(
      isLoading: isLoading ?? this.isLoading,
      isSavingSetup: isSavingSetup ?? this.isSavingSetup,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantSlug: restaurantSlug ?? this.restaurantSlug,
      branchName: branchName ?? this.branchName,
      branchId: branchId ?? this.branchId,
      terminalCode: terminalCode ?? this.terminalCode,
      syncToken: syncToken ?? this.syncToken,
      showPrices: showPrices ?? this.showPrices,
      preparing: preparing ?? this.preparing,
      ready: ready ?? this.ready,
      history: history ?? this.history,
      cart: cart ?? this.cart,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class CustomerDisplayController extends Notifier<CustomerDisplayState> {
  Timer? _pollTimer;

  @override
  CustomerDisplayState build() {
    ref.onDispose(() => _pollTimer?.cancel());
    Future.microtask(_load);
    return const CustomerDisplayState();
  }

  Future<void> saveSetup({
    required String restaurantSlug,
    required int branchId,
    required String terminalCode,
    required String syncToken,
  }) async {
    state = state.copyWith(isSavingSetup: true, clearError: true);
    final normalizedSlug = _slugFrom(restaurantSlug);
    final normalizedTerminal = terminalCode.trim().isEmpty
        ? 'T1'
        : terminalCode.trim();

    await ref
        .read(customerDisplayBoardRepositoryProvider)
        .saveSetup(
          restaurantSlug: normalizedSlug,
          branchId: branchId <= 0 ? 1 : branchId,
          terminalCode: normalizedTerminal,
          syncToken: syncToken,
        );

    state = state.copyWith(
      isSavingSetup: false,
      restaurantSlug: normalizedSlug,
      branchId: branchId <= 0 ? 1 : branchId,
      terminalCode: normalizedTerminal,
      syncToken: syncToken.trim(),
      clearError: true,
    );
    await refresh();
  }

  Future<void> refresh() => _poll();

  Future<void> _load() async {
    final setup = await ref
        .read(customerDisplayBoardRepositoryProvider)
        .readSetup();
    state = state.copyWith(
      restaurantName: setup.restaurantName,
      restaurantSlug: setup.restaurantSlug,
      branchName: setup.branchName,
      branchId: setup.branchId,
      terminalCode: setup.terminalCode,
      syncToken: setup.syncToken,
      showPrices: setup.showPrices,
    );
    await _poll();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  Future<void> _poll() async {
    try {
      final repository = ref.read(customerDisplayBoardRepositoryProvider);
      final board = await repository.pollBoard(
        restaurantSlug: state.restaurantSlug,
        branchId: state.branchId,
      );

      state = state.copyWith(
        isLoading: false,
        preparing: board.preparing,
        ready: board.ready,
        history: board.history,
        cart: const CustomerCart(active: false),
        lastUpdated: DateTime.now(),
        clearError: true,
      );
    } on Object catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _messageFor(error),
      );
    }
  }

  String _messageFor(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Customer display is waiting for the server.';
  }
}

String _slugFrom(String value) {
  final slug = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return slug.isEmpty ? 'kumar-bistro' : slug;
}
