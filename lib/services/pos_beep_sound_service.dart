import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _deviceSoundChannel = MethodChannel('selfx_pos/device_sound');

class PosBeepSoundService {
  PosBeepSoundService._();

  static final _player = AudioPlayer();
  static bool _ready = false;
  static DateTime _lastSound = DateTime.fromMillisecondsSinceEpoch(0);

  static Future<void> prepare() async {
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

  static void playAddToCart() {
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

  static Future<void> _playNativeOrAssetSound() async {
    try {
      final played =
          await _deviceSoundChannel.invokeMethod<bool>('playClick') ?? false;
      if (played) {
        return;
      }
    } on Object {
      // Fall back to the bundled sound below.
    }
    await _playAssetSound();
  }

  static Future<void> _playAssetSound() async {
    try {
      if (!_ready) {
        await prepare();
      }
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
}
