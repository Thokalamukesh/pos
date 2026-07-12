import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/errors/app_exception.dart';
import '../../widgets/selfx_mark.dart';
import '../auth/login_screen.dart';
import 'pairing_controller.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  static const routePath = '/pairing';

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  Timer? _pollTimer;

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) async {
      await ref.read(pairingControllerProvider.notifier).poll();
      final status = ref.read(pairingControllerProvider).asData?.value;
      final expiresAt = status?.expiresAt;
      if (status?.status == 'paired') {
        ref.invalidate(pairedDeviceProvider);
        final pairedDevice = await ref.read(pairedDeviceProvider.future);
        if (pairedDevice == null) {
          return;
        }
        _pollTimer?.cancel();
        if (mounted) {
          context.go(LoginScreen.routePath);
        }
      } else if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        _pollTimer?.cancel();
      }
    });
  }

  Future<void> _startPairing() async {
    _pollTimer?.cancel();
    try {
      await ref.read(pairingControllerProvider.notifier).startPairing();
      _startPolling();
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      _showError(error);
    }
  }

  void _showError(Object error) {
    final message = error is AppException ? error.message : error.toString();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pairingControllerProvider);
    final status = state.asData?.value;
    final pairingCode = status?.pairingCode;
    final expiresAt = status?.expiresAt;
    final isPaired = status?.status == 'paired';

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: wide
                      ? Row(
                          children: [
                            Expanded(
                              child: _PairingIntro(
                                isPaired: isPaired,
                                onLogin: () =>
                                    context.go(LoginScreen.routePath),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _PairingCodePanel(
                                state: state,
                                pairingCode: pairingCode,
                                expiresAt: expiresAt,
                                isPaired: isPaired,
                                onStart: _startPairing,
                                onLogin: () =>
                                    context.go(LoginScreen.routePath),
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          children: [
                            _PairingIntro(
                              isPaired: isPaired,
                              onLogin: () => context.go(LoginScreen.routePath),
                            ),
                            const SizedBox(height: 18),
                            _PairingCodePanel(
                              state: state,
                              pairingCode: pairingCode,
                              expiresAt: expiresAt,
                              isPaired: isPaired,
                              onStart: _startPairing,
                              onLogin: () => context.go(LoginScreen.routePath),
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PairingIntro extends StatelessWidget {
  const _PairingIntro({required this.isPaired, required this.onLogin});

  final bool isPaired;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 560),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SelfxMark(),
          const SizedBox(height: 48),
          Text(
            'Connect this register',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pairing binds this device to a SELFX POS terminal. Staff login still happens after the device is approved.',
            style: TextStyle(color: Color(0xFFCBD5E1), height: 1.45),
          ),
          const SizedBox(height: 30),
          _StepRow(
            number: '1',
            title: 'Start pairing',
            subtitle: 'Generate a six digit code on this device.',
            active: true,
          ),
          _StepRow(
            number: '2',
            title: 'Approve in admin',
            subtitle: 'Open POS terminals and enter the code.',
            active: true,
          ),
          _StepRow(
            number: '3',
            title: 'Login and print',
            subtitle: 'Use the assigned register with direct receipt printing.',
            active: isPaired,
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: onLogin,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: colors.primaryContainer),
            ),
            icon: const Icon(Icons.login),
            label: const Text('Staff login'),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.active,
  });

  final String number;
  final String title;
  final String subtitle;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: active ? const Color(0xFF4F46E5) : Colors.white12,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    height: 1.35,
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

class _PairingCodePanel extends StatelessWidget {
  const _PairingCodePanel({
    required this.state,
    required this.pairingCode,
    required this.expiresAt,
    required this.isPaired,
    required this.onStart,
    required this.onLogin,
  });

  final AsyncValue<Object?> state;
  final String? pairingCode;
  final DateTime? expiresAt;
  final bool isPaired;
  final VoidCallback onStart;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 560),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.primaryContainer,
                child: Icon(Icons.phonelink_setup, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'POS device pairing',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      isPaired
                          ? 'Device approved'
                          : 'Waiting for admin approval',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPaired
                    ? colors.secondary
                    : Theme.of(context).dividerColor,
              ),
            ),
            child: Column(
              children: [
                Text(
                  isPaired ? 'PAIRED' : 'PAIRING CODE',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 18),
                SelectableText(
                  pairingCode ?? '------',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    color: pairingCode == null
                        ? colors.outline
                        : colors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                if (expiresAt != null && !isPaired)
                  Text(
                    'Expires ${DateFormat.jm().format(expiresAt!.toLocal())}',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  )
                else if (isPaired)
                  Text(
                    'Device approved. Continue to staff login.',
                    style: TextStyle(
                      color: colors.secondary,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                else
                  Text(
                    'Start pairing to generate a code',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: state.isLoading ? null : onStart,
            icon: state.isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.qr_code_2),
            label: Text(
              pairingCode == null ? 'Start pairing' : 'Restart pairing',
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onLogin,
            icon: const Icon(Icons.login),
            label: const Text('Continue to staff login'),
          ),
          if (state.hasError) ...[
            const SizedBox(height: 14),
            Text(
              state.error.toString(),
              style: TextStyle(color: colors.error),
              textAlign: TextAlign.center,
            ),
          ],
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.admin_panel_settings_outlined),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Admin path: Store setup > POS terminals > Pair device.',
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
