import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../services/offline_order_sync_service.dart';
import '../theme/app_theme.dart';
import 'app_router.dart';

const _deviceSoundChannel = MethodChannel('selfx_pos/device_sound');

class SelfxApp extends ConsumerStatefulWidget {
  const SelfxApp({super.key});

  @override
  ConsumerState<SelfxApp> createState() => _SelfxAppState();
}

class _SelfxAppState extends ConsumerState<SelfxApp> {
  @override
  void initState() {
    super.initState();
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
      builder: (context, child) {
        return _AppClickSoundScope(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

class _AppClickSoundScope extends StatefulWidget {
  const _AppClickSoundScope({required this.child});

  final Widget child;

  @override
  State<_AppClickSoundScope> createState() => _AppClickSoundScopeState();
}

class _AppClickSoundScopeState extends State<_AppClickSoundScope> {
  final _player = AudioPlayer();
  bool _ready = false;
  DateTime _lastSound = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    unawaited(_prepare());
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _prepare() async {
    try {
      await _player.setPlayerMode(PlayerMode.lowLatency);
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(0.35);
      await _player.setSource(AssetSource('audio/pos-beep.wav'));
      _ready = true;
    } on Object {
      _ready = false;
    }
  }

  void _play() {
    final now = DateTime.now();
    if (now.difference(_lastSound).inMilliseconds < 80) {
      return;
    }
    _lastSound = now;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      unawaited(_playNativeOrAssetSound());
      return;
    }
    unawaited(_playAssetSound());
  }

  Future<void> _playNativeOrAssetSound() async {
    try {
      final played =
          await _deviceSoundChannel.invokeMethod<bool>('playClick') ?? false;
      if (played) {
        return;
      }
    } on Object {
      // Fall back to the bundled click sound below.
    }
    await _playAssetSound();
  }

  Future<void> _playAssetSound() async {
    try {
      if (!_ready) {
        await _player.play(
          AssetSource('audio/pos-beep.wav'),
          volume: 0.35,
          mode: PlayerMode.lowLatency,
        );
        return;
      }
      await _player.seek(Duration.zero);
      await _player.resume();
    } on Object {
      _ready = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _play(),
      child: widget.child,
    );
  }
}
