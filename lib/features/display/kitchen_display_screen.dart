import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../theme/app_theme.dart';

final _kitchenDisplayRepositoryProvider = Provider<_KitchenDisplayRepository>(
  (ref) => _KitchenDisplayRepository(ref.watch(dioProvider)),
);

final _kitchenDisplayControllerProvider =
    AsyncNotifierProvider<_KitchenDisplayController, _KitchenDisplayState>(
      _KitchenDisplayController.new,
    );

class KitchenDisplayScreen extends ConsumerStatefulWidget {
  const KitchenDisplayScreen({super.key});

  static const routePath = '/kitchen-display';

  @override
  ConsumerState<KitchenDisplayScreen> createState() =>
      _KitchenDisplayScreenState();
}

class _KitchenDisplayScreenState extends ConsumerState<KitchenDisplayScreen> {
  Timer? _clock;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_kitchenDisplayControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _KitchenGridPainter()),
          ),
          SafeArea(
            child: state.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.orange),
              ),
              error: (error, _) => _KitchenErrorView(
                message: _errorMessage(error),
                onBack: () => context.go('/pos'),
                onRetry: () =>
                    ref.invalidate(_kitchenDisplayControllerProvider),
              ),
              data: (data) => _KitchenDisplayBody(
                state: data,
                now: _now,
                onBack: () => context.go('/pos'),
                onCustomerBoard: () => context.go('/customer-display'),
                onRefresh: () => ref
                    .read(_kitchenDisplayControllerProvider.notifier)
                    .refresh(),
                onStatusChanged: (order, status) => ref
                    .read(_kitchenDisplayControllerProvider.notifier)
                    .updateStatus(order, status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KitchenDisplayController extends AsyncNotifier<_KitchenDisplayState> {
  Timer? _pollingTimer;
  int? _selectedKitchenId;

  @override
  Future<_KitchenDisplayState> build() async {
    ref.onDispose(() => _pollingTimer?.cancel());
    final loaded = await _loadBootstrap();
    _startPolling();
    return loaded;
  }

  Future<void> refresh() async {
    state = const AsyncLoading<_KitchenDisplayState>().copyWithPrevious(state);
    state = await AsyncValue.guard(_loadOrders);
  }

  Future<void> updateStatus(_KitchenOrder order, _KitchenStatus status) async {
    final current = state.asData?.value;
    if (current == null) {
      return;
    }

    state = AsyncData(
      current.copyWith(
        orders: current.orders
            .map(
              (item) =>
                  item.id == order.id ? item.copyWith(status: status) : item,
            )
            .toList(),
      ),
    );

    state = await AsyncValue.guard(() async {
      await ref
          .read(_kitchenDisplayRepositoryProvider)
          .updateStatus(order.id, status);
      return _loadOrders();
    });
  }

  Future<_KitchenDisplayState> _loadBootstrap() async {
    final response = await ref
        .read(_kitchenDisplayRepositoryProvider)
        .bootstrap();
    _selectedKitchenId ??= response.selectedKitchen?.id;
    final selectedKitchen = _selectedKitchen(response.kitchens);
    final orders = await ref
        .read(_kitchenDisplayRepositoryProvider)
        .orders(kitchenId: selectedKitchen?.id);

    return response.copyWith(
      selectedKitchen: selectedKitchen,
      orders: orders,
      lastUpdated: DateTime.now(),
    );
  }

  Future<_KitchenDisplayState> _loadOrders() async {
    final current = state.asData?.value;
    if (current == null) {
      return _loadBootstrap();
    }

    final selectedKitchen = _selectedKitchen(current.kitchens);
    final orders = await ref
        .read(_kitchenDisplayRepositoryProvider)
        .orders(kitchenId: selectedKitchen?.id);

    return current.copyWith(
      selectedKitchen: selectedKitchen,
      orders: orders,
      lastUpdated: DateTime.now(),
    );
  }

  _Kitchen? _selectedKitchen(List<_Kitchen> kitchens) {
    if (kitchens.isEmpty) {
      return null;
    }
    if (_selectedKitchenId != null) {
      return _firstWhereOrNull(
            kitchens,
            (kitchen) => kitchen.id == _selectedKitchenId,
          ) ??
          kitchens.first;
    }
    return _firstWhereOrNull(kitchens, (kitchen) => kitchen.isSelected) ??
        kitchens.first;
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      if (!state.isLoading) {
        state = await AsyncValue.guard(_loadOrders);
      }
    });
  }
}

class _KitchenDisplayRepository {
  const _KitchenDisplayRepository(this._dio);

  final Dio _dio;

  Future<_KitchenDisplayState> bootstrap() async {
    final response = await _get('${AppConfig.apiPrefix}/kitchen/bootstrap');
    final data = _dataMap(response);
    final restaurant = _asMap(data['restaurant']);
    final branch = _asMap(data['branch']);
    final kitchens = _listOfMaps(
      data['kitchens'] ?? data['kitchen_list'],
    ).map(_Kitchen.fromJson).toList();
    final selected = _asMap(
      data['selected_kitchen'] ?? data['selectedKitchen'],
    );

    return _KitchenDisplayState(
      restaurantName: _stringValue(
        restaurant['name'] ?? data['restaurant_name'],
        fallback: 'Restaurant',
      ),
      branchName: _stringValue(
        branch['name'] ?? data['branch_name'],
        fallback: 'Main',
      ),
      kitchens: kitchens,
      selectedKitchen: selected.isEmpty
          ? (kitchens.isEmpty ? null : kitchens.first)
          : _Kitchen.fromJson(selected),
      orders: _ordersFrom(data['orders'] ?? data['orders_by_status']),
      lastUpdated: DateTime.now(),
    );
  }

  Future<List<_KitchenOrder>> orders({int? kitchenId}) async {
    final response = await _get(
      '${AppConfig.apiPrefix}/kitchen/orders',
      queryParameters: kitchenId == null ? null : {'kitchen': kitchenId},
    );
    final data = _dataMap(response);
    return _ordersFrom(data['orders'] ?? data['orders_by_status'] ?? data);
  }

  Future<void> updateStatus(int orderId, _KitchenStatus status) async {
    AppException? lastValidationError;

    for (final value in status.apiValues) {
      try {
        await _dio.patch<Map<String, dynamic>>(
          '${AppConfig.apiPrefix}/kitchen/orders/$orderId/status',
          data: {'status': value},
        );
        return;
      } on DioException catch (error) {
        final exception = AppException.fromDio(error);
        if (error.response?.statusCode != 422) {
          throw exception;
        }
        lastValidationError = exception;
      }
    }

    throw lastValidationError ??
        const AppException(message: 'This order could not be updated.');
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }
}

class _KitchenDisplayBody extends StatelessWidget {
  const _KitchenDisplayBody({
    required this.state,
    required this.now,
    required this.onBack,
    required this.onCustomerBoard,
    required this.onRefresh,
    required this.onStatusChanged,
  });

  final _KitchenDisplayState state;
  final DateTime now;
  final VoidCallback onBack;
  final VoidCallback onCustomerBoard;
  final VoidCallback onRefresh;
  final void Function(_KitchenOrder order, _KitchenStatus status)
  onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _KitchenTopBar(
          state: state,
          now: now,
          onBack: onBack,
          onCustomerBoard: onCustomerBoard,
          onRefresh: onRefresh,
        ),
        const Divider(height: 1, color: AppColors.border),
        _KitchenSummary(state: state, now: now),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: state.activeOrders.isEmpty
              ? const _EmptyKitchen()
              : _KitchenBoard(
                  state: state,
                  now: now,
                  onStatusChanged: onStatusChanged,
                ),
        ),
      ],
    );
  }
}

class _KitchenTopBar extends StatelessWidget {
  const _KitchenTopBar({
    required this.state,
    required this.now,
    required this.onBack,
    required this.onCustomerBoard,
    required this.onRefresh,
  });

  final _KitchenDisplayState state;
  final DateTime now;
  final VoidCallback onBack;
  final VoidCallback onCustomerBoard;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm:ss').format(now);
    final date = DateFormat('EEE d MMM').format(now).toUpperCase();

    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Color(0xCC09090B),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderBright),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/images/mainlogo.png'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'Kitchen Display',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.borderBright),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PulseDot(),
                          SizedBox(width: 6),
                          Text(
                            'POLLING',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${state.restaurantName} - ${state.branchName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _KitchenClock(time: time, date: date),
          const SizedBox(width: 10),
          _KitchenToolbarButton(
            tooltip: 'Order board',
            label: 'Order board',
            icon: Icons.connected_tv_outlined,
            onPressed: onCustomerBoard,
          ),
          const SizedBox(width: 10),
          _KitchenToolbarButton(
            tooltip: 'Update orders',
            label: 'Update',
            icon: Icons.refresh,
            primary: true,
            onPressed: onRefresh,
          ),
          const SizedBox(width: 10),
          _KitchenIconButton(
            tooltip: 'Fullscreen',
            icon: Icons.open_in_full_rounded,
            onPressed: () => SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.immersiveSticky,
            ),
          ),
          const SizedBox(width: 10),
          _KitchenToolbarButton(
            tooltip: 'Exit kitchen',
            label: 'Exit kitchen',
            icon: Icons.logout,
            onPressed: onBack,
          ),
        ],
      ),
    );
  }
}

class _KitchenClock extends StatelessWidget {
  const _KitchenClock({required this.time, required this.date});

  final String time;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderBright),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            date,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _KitchenToolbarButton extends StatelessWidget {
  const _KitchenToolbarButton({
    required this.tooltip,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });

  final String tooltip;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        height: 46,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: primary ? Colors.black : AppColors.text,
            side: BorderSide(
              color: primary ? AppColors.gold : AppColors.borderBright,
            ),
            backgroundColor: primary ? AppColors.gold : AppColors.panel,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(icon, size: 18),
          label: Text(label),
        ),
      ),
    );
  }
}

class _KitchenIconButton extends StatelessWidget {
  const _KitchenIconButton({
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
      child: SizedBox(
        width: 46,
        height: 46,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.text,
            side: const BorderSide(color: AppColors.borderBright),
            backgroundColor: AppColors.panel,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: AppColors.muted,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _KitchenSummary extends StatelessWidget {
  const _KitchenSummary({required this.state, required this.now});

  final _KitchenDisplayState state;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _SummaryTile(
        label: 'Active queue',
        value: '${state.activeOrders.length} orders',
        color: AppColors.orange,
        icon: Icons.monitor_heart_outlined,
      ),
      _SummaryTile(
        label: 'Long wait',
        value: '${state.longWaitCount(now)} waiting 10+ min',
        color: AppColors.red,
        icon: Icons.warning_amber_rounded,
      ),
      _SummaryTile(
        label: 'New',
        value: state.count(_KitchenStatus.newest).toString(),
        color: AppColors.gold,
        icon: Icons.access_time,
      ),
      _SummaryTile(
        label: 'Queued',
        value: state.count(_KitchenStatus.queued).toString(),
        color: AppColors.sky,
        icon: Icons.access_time,
      ),
      _SummaryTile(
        label: 'Cooking',
        value: state.count(_KitchenStatus.cooking).toString(),
        color: AppColors.purpleHot,
        icon: Icons.access_time,
      ),
      _SummaryTile(
        label: 'Ready',
        value: state.count(_KitchenStatus.ready).toString(),
        color: AppColors.mint,
        icon: Icons.access_time,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 780) {
            return Column(
              children: [
                for (final tile in tiles) ...[tile, const SizedBox(height: 8)],
              ],
            );
          }

          return Row(
            children: [
              for (var index = 0; index < tiles.length; index++) ...[
                Expanded(child: tiles[index]),
                if (index != tiles.length - 1) const SizedBox(width: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _withAlpha(color, 0.09),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _withAlpha(color, 0.34)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 17,
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
}

class _KitchenBoard extends StatelessWidget {
  const _KitchenBoard({
    required this.state,
    required this.now,
    required this.onStatusChanged,
  });

  final _KitchenDisplayState state;
  final DateTime now;
  final void Function(_KitchenOrder order, _KitchenStatus status)
  onStatusChanged;

  @override
  Widget build(BuildContext context) {
    const statuses = [
      _KitchenStatus.newest,
      _KitchenStatus.queued,
      _KitchenStatus.cooking,
      _KitchenStatus.ready,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = [
          for (final status in statuses)
            _KitchenStatusColumn(
              status: status,
              orders: state.ordersFor(status),
              now: now,
              onStatusChanged: onStatusChanged,
            ),
        ];

        if (constraints.maxWidth < 980) {
          return ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: columns.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) =>
                SizedBox(height: 560, child: columns[index]),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < columns.length; index++) ...[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(index == 0 ? 14 : 0, 14, 0, 14),
                  child: columns[index],
                ),
              ),
              const SizedBox(width: 14),
            ],
          ],
        );
      },
    );
  }
}

class _KitchenStatusColumn extends StatelessWidget {
  const _KitchenStatusColumn({
    required this.status,
    required this.orders,
    required this.now,
    required this.onStatusChanged,
  });

  final _KitchenStatus status;
  final List<_KitchenOrder> orders;
  final DateTime now;
  final void Function(_KitchenOrder order, _KitchenStatus status)
  onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final color = status.boardColor;
    final itemCount = orders.fold<int>(
      0,
      (total, order) => total + order.items.length,
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _withAlpha(AppColors.column, 0.94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _withAlpha(color, 0.42)),
        boxShadow: [
          BoxShadow(
            color: _withAlpha(color, 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 78,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: _withAlpha(color, 0.14),
              border: Border(
                bottom: BorderSide(color: _withAlpha(color, 0.24)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _withAlpha(color, 0.16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _withAlpha(color, 0.24)),
                  ),
                  child: Icon(status.icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$itemCount ITEMS',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _withAlpha(color, 0.38),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    orders.length.toString(),
                    style: TextStyle(
                      color: status.countTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? _KitchenColumnEmpty(status: status)
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: orders.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _KitchenOrderCard(
                        order: order,
                        now: now,
                        priorityRank:
                            status == _KitchenStatus.ready && index < 2
                            ? 2 - index
                            : null,
                        onStatusChanged: (nextStatus) =>
                            onStatusChanged(order, nextStatus),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _KitchenOrderCard extends StatelessWidget {
  const _KitchenOrderCard({
    required this.order,
    required this.now,
    required this.onStatusChanged,
    this.priorityRank,
  });

  final _KitchenOrder order;
  final DateTime now;
  final ValueChanged<_KitchenStatus> onStatusChanged;
  final int? priorityRank;

  @override
  Widget build(BuildContext context) {
    final elapsed = order.elapsed(now);
    final longWait = elapsed.inMinutes >= 10;
    final next = order.status.next;
    final color = order.status.boardColor;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _withAlpha(AppColors.surface, 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: longWait ? _withAlpha(AppColors.red, 0.42) : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x77000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (priorityRank != null) _PriorityRibbon(rank: priorityRank!),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
            child: Row(
              children: [
                _OrderTokenBadge(order: order),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${order.items.length} items',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const _OrderTypeChip(),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _ElapsedPill(elapsed: elapsed, longWait: longWait),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF25252A)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Column(
              children: [
                for (final item in order.items.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _KitchenItemRow(item: item, color: color),
                  ),
                if (order.items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '+${order.items.length - 3} more items',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (next != null) ...[
            const Divider(height: 1, color: Color(0xFF25252A)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final stacked = constraints.maxWidth < 270;
                      final bump = _BumpButton(
                        label: priorityRank == null
                            ? 'BUMP'
                            : 'BUMP +$priorityRank',
                        onPressed: () => onStatusChanged(next),
                        expanded: stacked,
                      );
                      final action = SizedBox(
                        height: 64,
                        width: stacked ? double.infinity : null,
                        child: FilledButton.icon(
                          onPressed: () => onStatusChanged(next),
                          style: FilledButton.styleFrom(
                            backgroundColor: order.status.actionColor,
                            foregroundColor: order.status.actionTextColor,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          iconAlignment: IconAlignment.end,
                          icon: const Icon(Icons.arrow_forward, size: 23),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(order.status.actionLabel, maxLines: 1),
                          ),
                        ),
                      );

                      if (stacked) {
                        return Column(
                          children: [bump, const SizedBox(height: 10), action],
                        );
                      }

                      return Row(
                        children: [
                          bump,
                          const SizedBox(width: 10),
                          Expanded(child: action),
                        ],
                      );
                    },
                  ),
                  if (order.status == _KitchenStatus.newest) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: FilledButton(
                        onPressed: () =>
                            onStatusChanged(_KitchenStatus.cooking),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE94E05),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('START COOKING NOW', maxLines: 1),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PriorityRibbon extends StatelessWidget {
  const _PriorityRibbon({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _withAlpha(AppColors.orange, 0.16),
        border: Border(
          bottom: BorderSide(color: _withAlpha(AppColors.orange, 0.28)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.upload_rounded, color: Color(0xFFFDE68A), size: 15),
          const SizedBox(width: 6),
          Text(
            'PRIORITY +$rank',
            style: const TextStyle(
              color: Color(0xFFFDE68A),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BumpButton extends StatelessWidget {
  const _BumpButton({
    required this.label,
    required this.onPressed,
    this.expanded = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.infinity : 96,
      height: 64,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.borderBright),
          backgroundColor: AppColors.panel,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: const TextStyle(
            fontSize: 15,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.upload_rounded, size: 22),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, maxLines: 1, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _OrderTokenBadge extends StatelessWidget {
  const _OrderTokenBadge({required this.order});

  final _KitchenOrder order;

  @override
  Widget build(BuildContext context) {
    final color = order.status.boardColor;

    return Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _withAlpha(color, 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'TOKEN',
            style: TextStyle(
              color: _withAlpha(order.status.countTextColor, 0.82),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            order.token,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: order.status.countTextColor,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ElapsedPill extends StatelessWidget {
  const _ElapsedPill({required this.elapsed, required this.longWait});

  final Duration elapsed;
  final bool longWait;

  @override
  Widget build(BuildContext context) {
    final color = longWait ? AppColors.red : AppColors.muted;
    final minutes = elapsed.inMinutes;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _withAlpha(color, longWait ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _withAlpha(color, 0.34)),
      ),
      child: Text(
        '${minutes}m',
        style: TextStyle(
          color: longWait ? const Color(0xFFFECACA) : AppColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _OrderTypeChip extends StatelessWidget {
  const _OrderTypeChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _withAlpha(AppColors.purple, 0.26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _withAlpha(AppColors.purpleHot, 0.28)),
      ),
      child: const Text(
        'DINE IN',
        style: TextStyle(
          color: Color(0xFFD8CCFF),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _KitchenItemRow extends StatelessWidget {
  const _KitchenItemRow({required this.item, required this.color});

  final _KitchenOrderItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.ticketBlack,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _withAlpha(color, 0.20),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _withAlpha(color, 0.24)),
            ),
            child: Text(
              '${item.quantity}',
              style: TextStyle(
                color: color.computeLuminance() > 0.5
                    ? AppColors.ticketBlack
                    : AppColors.text,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KitchenColumnEmpty extends StatelessWidget {
  const _KitchenColumnEmpty({required this.status});

  final _KitchenStatus status;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              status.icon,
              size: 44,
              color: _withAlpha(status.boardColor, 0.62),
            ),
            const SizedBox(height: 12),
            Text(
              'No ${status.label.toLowerCase()} orders',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Orders will appear here automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _KitchenGridPainter extends CustomPainter {
  const _KitchenGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.background);
    final paint = Paint()
      ..color = _withAlpha(AppColors.border, 0.28)
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

class _KitchenErrorView extends StatelessWidget {
  const _KitchenErrorView({
    required this.message,
    required this.onBack,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 52, color: AppColors.red),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('POS'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
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

class _EmptyKitchen extends StatelessWidget {
  const _EmptyKitchen();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.room_service_outlined,
            size: 64,
            color: AppColors.borderBright,
          ),
          SizedBox(height: 12),
          Text(
            'No active kitchen orders',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'New POS orders will appear here automatically.',
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _KitchenDisplayState {
  const _KitchenDisplayState({
    required this.restaurantName,
    required this.branchName,
    required this.kitchens,
    required this.selectedKitchen,
    required this.orders,
    required this.lastUpdated,
  });

  final String restaurantName;
  final String branchName;
  final List<_Kitchen> kitchens;
  final _Kitchen? selectedKitchen;
  final List<_KitchenOrder> orders;
  final DateTime? lastUpdated;

  List<_KitchenOrder> get activeOrders => orders
      .where((order) => order.status != _KitchenStatus.completed)
      .toList();

  int count(_KitchenStatus status) =>
      activeOrders.where((order) => order.status == status).length;

  int longWaitCount(DateTime now) =>
      activeOrders.where((order) => order.elapsed(now).inMinutes >= 10).length;

  List<_KitchenOrder> ordersFor(_KitchenStatus status) =>
      activeOrders.where((order) => order.status == status).toList();

  _KitchenDisplayState copyWith({
    String? restaurantName,
    String? branchName,
    List<_Kitchen>? kitchens,
    _Kitchen? selectedKitchen,
    List<_KitchenOrder>? orders,
    DateTime? lastUpdated,
  }) {
    return _KitchenDisplayState(
      restaurantName: restaurantName ?? this.restaurantName,
      branchName: branchName ?? this.branchName,
      kitchens: kitchens ?? this.kitchens,
      selectedKitchen: selectedKitchen ?? this.selectedKitchen,
      orders: orders ?? this.orders,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class _Kitchen {
  const _Kitchen({
    required this.id,
    required this.name,
    required this.isSelected,
  });

  final int id;
  final String name;
  final bool isSelected;

  factory _Kitchen.fromJson(Map<String, dynamic> json) {
    return _Kitchen(
      id: _intValue(json['id']),
      name: _stringValue(json['name'] ?? json['title'], fallback: 'Kitchen'),
      isSelected: json['is_selected'] == true || json['selected'] == true,
    );
  }
}

class _KitchenOrder {
  const _KitchenOrder({
    required this.id,
    required this.token,
    required this.orderNumber,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  final int id;
  final String token;
  final String orderNumber;
  final _KitchenStatus status;
  final DateTime createdAt;
  final List<_KitchenOrderItem> items;

  Duration elapsed(DateTime now) {
    final duration = now.difference(createdAt);
    return duration.isNegative ? Duration.zero : duration;
  }

  _KitchenOrder copyWith({_KitchenStatus? status}) {
    return _KitchenOrder(
      id: id,
      token: token,
      orderNumber: orderNumber,
      status: status ?? this.status,
      createdAt: createdAt,
      items: items,
    );
  }

  factory _KitchenOrder.fromJson(Map<String, dynamic> json) {
    final items = _listOfMaps(
      json['items'] ?? json['order_items'],
    ).map(_KitchenOrderItem.fromJson).toList();

    return _KitchenOrder(
      id: _intValue(json['id']),
      token: _stringValue(
        json['token'] ?? json['token_no'] ?? json['display_token'],
        fallback: '-',
      ),
      orderNumber: _stringValue(
        json['order_number'] ?? json['orderNumber'] ?? json['number'],
        fallback: '-',
      ),
      status: _KitchenStatus.fromApi(json['status']),
      createdAt:
          DateTime.tryParse(
            _stringValue(
              json['created_at'] ?? json['createdAt'] ?? json['ordered_at'],
            ),
          ) ??
          DateTime.now(),
      items: items,
    );
  }
}

class _KitchenOrderItem {
  const _KitchenOrderItem({required this.name, required this.quantity});

  final String name;
  final int quantity;

  factory _KitchenOrderItem.fromJson(Map<String, dynamic> json) {
    final itemName = _stringValue(
      json['name'] ??
          json['item_name'] ??
          json['menu_item_name'] ??
          json['title'],
      fallback: 'Item',
    );
    final variant = _stringValue(json['variant_name']);

    return _KitchenOrderItem(
      name: variant.isEmpty ? itemName : '$itemName - $variant',
      quantity: _intValue(json['quantity'] ?? json['qty'], fallback: 1),
    );
  }
}

enum _KitchenStatus {
  newest('pending', 'NEW', AppColors.gold),
  queued('confirmed', 'QUEUED', AppColors.sky, ['accepted', 'queued']),
  cooking('preparing', 'COOKING', AppColors.purpleHot, [
    'cooking',
    'in_progress',
  ]),
  ready('ready', 'READY', AppColors.mint, ['ready_for_pickup']),
  completed('delivered', 'PICKED UP', AppColors.muted, [
    'picked_up',
    'pickedup',
    'served',
    'completed',
  ]);

  const _KitchenStatus(
    this.apiValue,
    this.label,
    this.color, [
    this.fallbackApiValues = const [],
  ]);

  final String apiValue;
  final String label;
  final Color color;
  final List<String> fallbackApiValues;

  Color get boardColor => color;

  Color get countTextColor {
    return switch (this) {
      _KitchenStatus.newest || _KitchenStatus.queued => Colors.black,
      _ => Colors.white,
    };
  }

  IconData get icon {
    return switch (this) {
      _KitchenStatus.newest => Icons.notifications_none_rounded,
      _KitchenStatus.queued => Icons.check_rounded,
      _KitchenStatus.cooking => Icons.local_fire_department_outlined,
      _KitchenStatus.ready => Icons.room_service_outlined,
      _KitchenStatus.completed => Icons.done_all_rounded,
    };
  }

  String get actionLabel {
    return switch (this) {
      _KitchenStatus.newest => 'Accept order',
      _KitchenStatus.queued => 'Start cooking',
      _KitchenStatus.cooking => 'Ready for pickup',
      _KitchenStatus.ready => 'Picked up / served',
      _KitchenStatus.completed => 'Done',
    };
  }

  Color get actionColor {
    return switch (this) {
      _KitchenStatus.newest => AppColors.orange,
      _KitchenStatus.queued => AppColors.sky,
      _KitchenStatus.cooking => AppColors.purpleHot,
      _KitchenStatus.ready => const Color(0xFF5B5B66),
      _KitchenStatus.completed => AppColors.muted,
    };
  }

  Color get actionTextColor {
    return switch (this) {
      _KitchenStatus.newest || _KitchenStatus.queued => Colors.black,
      _ => Colors.white,
    };
  }

  List<String> get apiValues => [apiValue, ...fallbackApiValues];

  _KitchenStatus? get next {
    return switch (this) {
      _KitchenStatus.newest => _KitchenStatus.queued,
      _KitchenStatus.queued => _KitchenStatus.cooking,
      _KitchenStatus.cooking => _KitchenStatus.ready,
      _KitchenStatus.ready => _KitchenStatus.completed,
      _KitchenStatus.completed => null,
    };
  }

  static _KitchenStatus fromApi(Object? value) {
    final normalized = value?.toString().toLowerCase().trim();
    return switch (normalized) {
      'new' || 'pending' => _KitchenStatus.newest,
      'queued' || 'accepted' || 'confirmed' => _KitchenStatus.queued,
      'cooking' || 'preparing' || 'in_progress' => _KitchenStatus.cooking,
      'ready' || 'ready_for_pickup' => _KitchenStatus.ready,
      'picked_up' ||
      'pickedup' ||
      'delivered' ||
      'completed' ||
      'served' => _KitchenStatus.completed,
      _ => _KitchenStatus.newest,
    };
  }
}

Map<String, dynamic> _dataMap(Map<String, dynamic> json) {
  final data = json['data'];
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return json;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return const <String, dynamic>{};
}

List<Map<String, dynamic>> _listOfMaps(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

List<_KitchenOrder> _ordersFrom(Object? value) {
  if (value is List) {
    return _listOfMaps(value).map(_KitchenOrder.fromJson).toList();
  }
  if (value is Map) {
    return value.values
        .whereType<List>()
        .expand(_listOfMaps)
        .map(_KitchenOrder.fromJson)
        .toList();
  }
  return const [];
}

T? _firstWhereOrNull<T>(Iterable<T> values, bool Function(T value) test) {
  for (final value in values) {
    if (test(value)) {
      return value;
    }
  }
  return null;
}

Color _withAlpha(Color color, double alpha) {
  final normalized = alpha.clamp(0.0, 1.0);
  return color.withAlpha((normalized * 255).round());
}

String _stringValue(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? fallback : text;
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

String _errorMessage(Object error) {
  if (error is AppException) {
    return error.message;
  }
  return error.toString();
}
