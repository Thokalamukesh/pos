import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth/auth_controller.dart';
import '../../auth/login_screen.dart';
import '../application/customer_display_controller.dart';
import '../domain/customer_display_models.dart';

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
                  final history = state.orderHistory;
                  return Column(
                    children: [
                      _TopBar(
                        state: state,
                        now: _now,
                        compact: constraints.maxWidth < 900,
                        controlsVisible:
                            _controlsVisible || constraints.maxWidth < 900,
                        fullscreen: _fullscreen,
                        onBackToKitchen: _exitToPos,
                        onSetup: () => _showSetupSheet(context, state),
                        onFullscreen: _toggleFullscreen,
                        onLogout: _confirmLogout,
                      ),
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
                            orders: history,
                            lastUpdated: state.lastUpdated,
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

  void _exitToPos() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/pos');
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

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.state,
    required this.now,
    required this.compact,
    required this.controlsVisible,
    required this.fullscreen,
    required this.onBackToKitchen,
    required this.onSetup,
    required this.onFullscreen,
    required this.onLogout,
  });

  final CustomerDisplayState state;
  final DateTime now;
  final bool compact;
  final bool controlsVisible;
  final bool fullscreen;
  final VoidCallback onBackToKitchen;
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
          _ExitDisplayButton(onPressed: onBackToKitchen),
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

class _ExitDisplayButton extends StatelessWidget {
  const _ExitDisplayButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Exit order board',
      child: SizedBox(
        height: 46,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: _DisplayColors.border),
            backgroundColor: const Color(0xFF17171B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.logout, size: 18),
          label: const Text(
            'Exit',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
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

class _OrderHistoryPanel extends StatelessWidget {
  const _OrderHistoryPanel({required this.orders, required this.lastUpdated});

  final List<CustomerDisplayOrder> orders;
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _DisplayColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _DisplayColors.border),
      ),
      child: Column(
        children: [
          Container(
            height: 96,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF101014),
              border: Border(bottom: BorderSide(color: _DisplayColors.border)),
            ),
            child: Row(
              children: [
                const _HeaderIcon(
                  icon: Icons.history_rounded,
                  color: Color(0xFF60A5FA),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ORDER HISTORY',
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _lastUpdatedLabel(lastUpdated),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: const TextStyle(
                          color: _DisplayColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                _CountBadge(
                  count: orders.length,
                  color: const Color(0xFF60A5FA),
                ),
              ],
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? const _EmptyState(
                    color: Color(0xFF60A5FA),
                    title: 'No recent orders',
                    body:
                        'Orders will appear here as the kitchen updates them.',
                    icon: Icons.receipt_long_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: orders.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _HistoryOrderTile(order: orders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryOrderTile extends StatelessWidget {
  const _HistoryOrderTile({required this.order});

  final CustomerDisplayOrder order;

  @override
  Widget build(BuildContext context) {
    final ready = order.isReady;
    final color = ready ? _DisplayColors.mint : _DisplayColors.orange;
    final money = NumberFormat.simpleCurrency(name: order.currency);
    final itemTotal = order.items.fold<double>(
      0,
      (sum, item) => sum + item.lineTotal,
    );
    final total = order.total > 0 ? order.total : itemTotal;
    final visibleItems = order.items.take(4).toList();
    final hiddenItemCount = order.items.length - visibleItems.length;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _withAlpha(color, ready ? 0.12 : 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _withAlpha(color, 0.28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _withAlpha(color, 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.receipt_long_rounded, color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _shortOrder(order.orderNumber),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _statusLabel(order),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _updatedLabel(order.updatedAt),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: const TextStyle(
                              color: _DisplayColors.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    ready
                        ? Icons.check_circle_rounded
                        : Icons.timelapse_rounded,
                    color: color,
                    size: 24,
                  ),
                  if (total > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      money.format(total),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (visibleItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
              decoration: BoxDecoration(
                color: const Color(0x6608080A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _withAlpha(color, 0.16)),
              ),
              child: Column(
                children: [
                  for (final item in visibleItems)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: _withAlpha(color, 0.14),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${item.quantity}x',
                              maxLines: 1,
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFEDEDF2),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            money.format(item.lineTotal),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _DisplayColors.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (hiddenItemCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '+ $hiddenItemCount more items',
                          style: TextStyle(
                            color: _withAlpha(color, 0.82),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
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

String _shortOrder(String value) {
  if (value.length <= 10) {
    return value;
  }
  return value.substring(value.length - 10);
}

String _statusLabel(CustomerDisplayOrder order) {
  if (order.isReady) {
    return 'READY';
  }
  final status = order.status.trim();
  if (status.isEmpty) {
    return 'PREPARING';
  }
  return status
      .replaceAll('_', ' ')
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part.toUpperCase())
      .join(' ');
}

String _updatedLabel(DateTime? updatedAt) {
  if (updatedAt == null) {
    return 'Just now';
  }
  return DateFormat('HH:mm').format(updatedAt.toLocal());
}

String _lastUpdatedLabel(DateTime? lastUpdated) {
  if (lastUpdated == null) {
    return 'Live board';
  }
  return 'Updated ${DateFormat('HH:mm:ss').format(lastUpdated.toLocal())}';
}
