import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/offline_order_sync_service.dart';
import '../services/pos_beep_sound_service.dart';
import '../services/window_close/window_close_guard.dart';
import '../theme/app_theme.dart';
import '../widgets/exit_confirmation_dialog.dart';
import 'app_settings_controller.dart';
import 'app_router.dart';

class SelfxApp extends ConsumerStatefulWidget {
  const SelfxApp({super.key});

  @override
  ConsumerState<SelfxApp> createState() => _SelfxAppState();
}

class _SelfxAppState extends ConsumerState<SelfxApp> {
  late final WindowCloseGuard _windowCloseGuard;

  @override
  void initState() {
    super.initState();
    _windowCloseGuard = WindowCloseGuard(onCloseRequest: _confirmWindowClose);
    unawaited(_windowCloseGuard.install());
    unawaited(PosBeepSoundService.prepare());
    Future.microtask(() {
      ref.read(offlineOrderSyncServiceProvider).start();
    });
  }

  @override
  void dispose() {
    _windowCloseGuard.dispose();
    super.dispose();
  }

  Future<bool> _confirmWindowClose() async {
    final dialogContext = rootNavigatorKey.currentContext;
    if (!mounted || dialogContext == null) {
      return true;
    }
    return showExitConfirmationDialog(
      dialogContext,
      title: 'Exit SELFX POS?',
      message: 'Are you sure you want to close the POS app?',
      confirmLabel: 'Exit',
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      title: 'SELFX POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
