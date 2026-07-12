import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum OrderPreviewResult {
  sentToKitchen,
  printBill,
  saveOrder,
  cancelOrder,
  editOrder,
}

enum OrderItemPreviewStatus { pending, preparing, ready }

class OrderPreviewData {
  const OrderPreviewData({
    required this.orderNumber,
    required this.tableName,
    required this.customerName,
    required this.tokenNumber,
    required this.orderTime,
    required this.currencyCode,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.items,
  });

  final String orderNumber;
  final String tableName;
  final String customerName;
  final String tokenNumber;
  final DateTime orderTime;
  final String currencyCode;
  final double subtotal;
  final double discount;
  final double total;
  final List<OrderPreviewItem> items;

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}

class OrderPreviewItem {
  const OrderPreviewItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.isVeg,
    this.notes,
    this.status = OrderItemPreviewStatus.pending,
  });

  final String name;
  final int quantity;
  final double price;
  final bool isVeg;
  final String? notes;
  final OrderItemPreviewStatus status;
}

class OrderPreviewScreen extends StatefulWidget {
  const OrderPreviewScreen({super.key, required this.data});

  static const routePath = '/order-preview';

  final OrderPreviewData data;

  @override
  State<OrderPreviewScreen> createState() => _OrderPreviewScreenState();
}

class _OrderPreviewScreenState extends State<OrderPreviewScreen>
    with TickerProviderStateMixin {
  static const _primary = Color(0xFF4CAF50);
  late final AnimationController _entryController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.035), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.simpleCurrency(name: widget.data.currencyCode);
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primary,
          primary: _primary,
          surface: Colors.white,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 980;
                  return Column(
                    children: [
                      _OrderPreviewAppBar(
                        orderNumber: widget.data.orderNumber,
                        online: true,
                        onBack: () => context.pop(OrderPreviewResult.editOrder),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            wide ? 28 : 16,
                            18,
                            wide ? 28 : 16,
                            18,
                          ),
                          child: wide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: _OrderedItemsCard(
                                        items: widget.data.items,
                                        money: money,
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    SizedBox(
                                      width: 390,
                                      child: _SideSummary(
                                        data: widget.data,
                                        money: money,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _SideSummary(
                                      data: widget.data,
                                      money: money,
                                    ),
                                    const SizedBox(height: 16),
                                    _OrderedItemsCard(
                                      items: widget.data.items,
                                      money: money,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      _BottomActions(
                        sending: _sending,
                        onSendToKitchen: _sendToKitchen,
                        onPrintBill: () =>
                            context.pop(OrderPreviewResult.printBill),
                        onSaveOrder: () =>
                            context.pop(OrderPreviewResult.saveOrder),
                        onCancel: _confirmCancel,
                        onEdit: () => context.pop(OrderPreviewResult.editOrder),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendToKitchen() async {
    if (widget.data.items.isEmpty || _sending) {
      return;
    }
    setState(() => _sending = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 850));
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _SuccessDialog(),
      );
      if (mounted) {
        context.pop(OrderPreviewResult.sentToKitchen);
      }
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFFE53935),
          content: Text('Could not send this order. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel order?'),
        content: const Text('This will clear the current billing cart.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.pop(OrderPreviewResult.cancelOrder);
    }
  }
}

class _OrderPreviewAppBar extends StatelessWidget {
  const _OrderPreviewAppBar({
    required this.orderNumber,
    required this.online,
    required this.onBack,
  });

  final String orderNumber;
  final bool online;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final now = DateFormat('hh:mm a').format(DateTime.now());
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          IconButton.filledTonal(
            tooltip: 'Back',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Display',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                Text(
                  orderNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _ConnectionPill(online: online),
          const SizedBox(width: 12),
          Text(
            now,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: online ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 9,
            color: online ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
          ),
          const SizedBox(width: 7),
          Text(
            online ? 'Online' : 'Offline',
            style: TextStyle(
              color: online ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SideSummary extends StatelessWidget {
  const _SideSummary({required this.data, required this.money});

  final OrderPreviewData data;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.receipt_long,
                title: 'Order Summary',
              ),
              const SizedBox(height: 16),
              _InfoRow(label: 'Order Number', value: data.orderNumber),
              _InfoRow(label: 'Table Name', value: data.tableName),
              _InfoRow(label: 'Customer', value: data.customerName),
              _InfoRow(label: 'Token Number', value: data.tokenNumber),
              _InfoRow(
                label: 'Order Time',
                value: DateFormat('dd MMM, hh:mm a').format(data.orderTime),
              ),
              _InfoRow(label: 'Total Items', value: '${data.totalItems}'),
              const Divider(height: 28),
              _MoneyRow(label: 'Subtotal', value: money.format(data.subtotal)),
              if (data.discount > 0)
                _MoneyRow(
                  label: 'Discount',
                  value: '-${money.format(data.discount)}',
                ),
              const SizedBox(height: 8),
              _MoneyRow(
                label: 'Total',
                value: money.format(data.total),
                large: true,
              ),
            ],
          ),
        ),
        if (data.items.isEmpty) ...[
          const SizedBox(height: 16),
          const _EmptyOrderState(),
        ],
      ],
    );
  }
}

class _OrderedItemsCard extends StatelessWidget {
  const _OrderedItemsCard({required this.items, required this.money});

  final List<OrderPreviewItem> items;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.restaurant_menu,
            title: 'Ordered Items',
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const _EmptyOrderState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _OrderItemTile(item: items[index], money: money);
              },
            ),
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item, required this.money});

  final OrderPreviewItem item;
  final NumberFormat money;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VegMark(isVeg: item.isVeg),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _MiniChip(label: 'Qty ${item.quantity}'),
                    _StatusChip(status: item.status),
                    if (item.notes?.trim().isNotEmpty == true)
                      _MiniChip(label: item.notes!.trim(), icon: Icons.notes),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            money.format(item.price),
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.sending,
    required this.onSendToKitchen,
    required this.onPrintBill,
    required this.onSaveOrder,
    required this.onCancel,
    required this.onEdit,
  });

  final bool sending;
  final VoidCallback onSendToKitchen;
  final VoidCallback onPrintBill;
  final VoidCallback onSaveOrder;
  final VoidCallback onCancel;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 820;
          final buttons = [
            _ActionButton(
              label: 'Send to Kitchen',
              icon: Icons.soup_kitchen_outlined,
              filled: true,
              loading: sending,
              onPressed: sending ? null : onSendToKitchen,
            ),
            _ActionButton(
              label: 'Print Bill',
              icon: Icons.print_outlined,
              onPressed: sending ? null : onPrintBill,
            ),
            _ActionButton(
              label: 'Save Order',
              icon: Icons.bookmark_add_outlined,
              onPressed: sending ? null : onSaveOrder,
            ),
            _ActionButton(
              label: 'Cancel',
              icon: Icons.close,
              danger: true,
              onPressed: sending ? null : onCancel,
            ),
            _ActionButton(
              label: 'Edit Order',
              icon: Icons.edit_outlined,
              onPressed: sending ? null : onEdit,
            ),
          ];
          if (compact) {
            return Wrap(spacing: 10, runSpacing: 10, children: buttons);
          }
          return Row(
            children: buttons
                .map(
                  (button) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: button,
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = false,
    this.danger = false,
    this.loading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;
  final bool danger;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon), const SizedBox(width: 8), Text(label)],
          );
    final style = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );
    return SizedBox(
      height: 58,
      child: filled
          ? FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: style,
              ),
              onPressed: onPressed,
              child: child,
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: danger
                    ? const Color(0xFFE53935)
                    : const Color(0xFF111827),
                side: BorderSide(
                  color: danger
                      ? const Color(0xFFFFCDD2)
                      : const Color(0xFFE5E7EB),
                ),
                shape: style,
              ),
              onPressed: onPressed,
              child: child,
            ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4CAF50)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.value,
    this.large = false,
  });

  final String label;
  final String value;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: large ? 18 : 14,
                fontWeight: large ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: large ? const Color(0xFF4CAF50) : const Color(0xFF111827),
              fontSize: large ? 26 : 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _VegMark extends StatelessWidget {
  const _VegMark({required this.isVeg});

  final bool isVeg;

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Center(
        child: isVeg
            ? Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              )
            : Icon(Icons.change_history, size: 14, color: color),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14), const SizedBox(width: 5)],
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OrderItemPreviewStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      OrderItemPreviewStatus.pending => ('Pending', const Color(0xFFF59E0B)),
      OrderItemPreviewStatus.preparing => (
        'Preparing',
        const Color(0xFF4CAF50),
      ),
      OrderItemPreviewStatus.ready => ('Ready', const Color(0xFF2563EB)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyOrderState extends StatelessWidget {
  const _EmptyOrderState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.shopping_bag_outlined, size: 54, color: Color(0xFFCBD5E1)),
          SizedBox(height: 12),
          Text('No items added', style: TextStyle(fontWeight: FontWeight.w900)),
          SizedBox(height: 4),
          Text(
            'Add menu items in POS to preview the order here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog();

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
    Timer(const Duration(milliseconds: 900), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: Curves.elasticOut,
              ),
              child: const CircleAvatar(
                radius: 42,
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.check, size: 48, color: Color(0xFF4CAF50)),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Sent to Kitchen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
