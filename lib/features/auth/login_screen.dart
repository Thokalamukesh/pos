import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_exception.dart';
import '../../repositories/bootstrap_repository.dart';
import '../../widgets/selfx_mark.dart';
import '../pairing/pairing_controller.dart';
import '../pairing/pairing_screen.dart';
import '../pos/pos_shell_screen.dart';
import '../terminal/terminal_controller.dart';
import '../terminal/terminal_selection_screen.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const routePath = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  Timer? _loginCooldownTimer;
  DateTime? _loginBlockedUntil;
  bool _retryLoginWhenCooldownEnds = false;

  @override
  void dispose() {
    _loginCooldownTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _loginBlocked {
    final blockedUntil = _loginBlockedUntil;
    return blockedUntil != null && DateTime.now().isBefore(blockedUntil);
  }

  int get _loginCooldownSeconds {
    final blockedUntil = _loginBlockedUntil;
    if (blockedUntil == null) {
      return 0;
    }
    final seconds = blockedUntil.difference(DateTime.now()).inSeconds + 1;
    return seconds < 0 ? 0 : seconds;
  }

  void _startLoginCooldown(Duration duration, {bool retryWhenReady = false}) {
    _loginCooldownTimer?.cancel();
    _retryLoginWhenCooldownEnds = retryWhenReady;
    setState(() => _loginBlockedUntil = DateTime.now().add(duration));
    _loginCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!_loginBlocked) {
        timer.cancel();
        final shouldRetry = _retryLoginWhenCooldownEnds;
        setState(() {
          _loginBlockedUntil = null;
          _retryLoginWhenCooldownEnds = false;
        });
        if (shouldRetry && mounted) {
          unawaited(_submit(retryAfterRateLimit: false));
        }
        return;
      }
      setState(() {});
    });
  }

  Duration _rateLimitCooldown(Object error) {
    final retryAfter = error is AppException ? error.retryAfter : null;
    if (retryAfter != null && retryAfter > Duration.zero) {
      return retryAfter + const Duration(seconds: 1);
    }
    return const Duration(seconds: 61);
  }

  bool _isRateLimitError(Object error) {
    if (error is AppException && error.statusCode == 429) {
      return true;
    }
    final text = (error is AppException ? error.message : error.toString())
        .toLowerCase();
    return text.contains('too many attempts') ||
        text.contains('too many requests') ||
        text.contains('429');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit({bool retryAfterRateLimit = true}) async {
    if (_loginBlocked) {
      _showSnack(
        'Too many login attempts. Try again in $_loginCooldownSeconds seconds.',
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      final pairedDevice = await ref.read(pairedDeviceProvider.future);
      final session = await ref
          .read(authControllerProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            restaurantId: pairedDevice?.restaurantId,
            branchId: pairedDevice?.branchId,
          );
      if (!mounted) return;

      await ref.read(terminalContextProvider.notifier).clear();
      final pairedDeviceMatchesSession =
          session.currentRestaurant?.id == pairedDevice?.restaurantId &&
          session.currentBranch?.id == pairedDevice?.branchId;

      if (pairedDevice != null && pairedDeviceMatchesSession) {
        final bootstrap = await ref
            .read(bootstrapRepositoryProvider)
            .loadBootstrap(allowCache: false);
        final pairedTerminal = bootstrap.posTerminals.where((terminal) {
          return terminal.id == pairedDevice.terminal.id ||
              terminal.code == pairedDevice.terminal.code;
        }).firstOrNull;

        if (pairedTerminal != null) {
          await ref
              .read(terminalContextProvider.notifier)
              .select(pairedTerminal);
          if (!mounted) return;
          context.go(PosShellScreen.routePath);
          return;
        }
      }

      if (!mounted) return;
      context.go(TerminalSelectionScreen.routePath);
    } on Object catch (error) {
      if (!mounted) return;
      if (_isRateLimitError(error)) {
        final cooldown = _rateLimitCooldown(error);
        _startLoginCooldown(cooldown, retryWhenReady: retryAfterRateLimit);
        _showSnack(
          retryAfterRateLimit
              ? 'Too many login attempts. Retrying in ${cooldown.inSeconds} seconds.'
              : 'Too many login attempts. Please wait ${cooldown.inSeconds} seconds and try again.',
        );
        return;
      }
      final message = error is AppException ? error.message : error.toString();
      _showSnack(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final pairedDevice = ref.watch(pairedDeviceProvider).asData?.value;
    final loginBlocked = _loginBlocked;
    final loginBusy = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SelfxMark(),
                    const SizedBox(height: 28),
                    Text(
                      'Staff login',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pairing binds this device to a register. Staff login is still required to get the SELFx bearer token.',
                    ),
                    if (pairedDevice != null) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Theme.of(context).colorScheme.secondaryContainer
                            .withValues(alpha: 0.55),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.verified_outlined),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Saved device pairing',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'This pairing is used only when the staff login matches the same restaurant, branch, and register.',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (value) =>
                          value == null || !value.contains('@')
                          ? 'Enter a valid email.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Show password' : 'Hide password',
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter your password.'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: loginBusy || loginBlocked
                          ? null
                          : () => _submit(retryAfterRateLimit: true),
                      icon: loginBusy
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              loginBlocked ? Icons.timer_outlined : Icons.login,
                            ),
                      label: Text(
                        loginBlocked
                            ? (_retryLoginWhenCooldownEnds
                                  ? 'Retrying in $_loginCooldownSeconds s'
                                  : 'Try again in $_loginCooldownSeconds s')
                            : 'Login to POS',
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: authState.isLoading
                          ? null
                          : () async {
                              final router = GoRouter.of(context);
                              await ref
                                  .read(pairingControllerProvider.notifier)
                                  .resetForPairing();
                              if (mounted) {
                                router.go(PairingScreen.routePath);
                              }
                            },
                      icon: const Icon(Icons.phonelink_setup),
                      label: Text(
                        pairedDevice == null
                            ? 'Pair this device'
                            : 'Pair / re-pair device',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
