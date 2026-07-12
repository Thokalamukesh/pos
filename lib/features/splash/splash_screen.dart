import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage/secure_storage_service.dart';
import '../../repositories/terminal_repository.dart';
import '../../widgets/selfx_mark.dart';
import '../auth/login_screen.dart';
import '../pairing/pairing_screen.dart';
import '../pos/pos_shell_screen.dart';
import '../terminal/terminal_selection_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const routePath = '/';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  Future<void> _route() async {
    final storage = ref.read(secureStorageServiceProvider);
    final session = await storage.readAuthSession();
    if (!mounted) return;

    if (session == null) {
      final pairedDevice = await storage.readPairedDevice();
      if (!mounted) return;
      context.go(
        pairedDevice == null ? PairingScreen.routePath : LoginScreen.routePath,
      );
      return;
    }

    final terminal = await ref.read(terminalRepositoryProvider).restoreTerminal();
    if (!mounted) return;
    context.go(
      terminal == null
          ? TerminalSelectionScreen.routePath
          : PosShellScreen.routePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelfxMark(),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
