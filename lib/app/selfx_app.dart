import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/offline_order_sync_service.dart';
import '../services/pos_beep_sound_service.dart';
import '../theme/app_theme.dart';
import 'app_router.dart';

class SelfxApp extends ConsumerStatefulWidget {
  const SelfxApp({super.key});

  @override
  ConsumerState<SelfxApp> createState() => _SelfxAppState();
}

class _SelfxAppState extends ConsumerState<SelfxApp> {
  @override
  void initState() {
    super.initState();
    unawaited(PosBeepSoundService.prepare());
    Future.microtask(() {
      ref.read(offlineOrderSyncServiceProvider).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'SELFX POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}
