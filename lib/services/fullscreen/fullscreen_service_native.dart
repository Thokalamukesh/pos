import 'dart:io';

import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

Future<void> toggleFullscreen() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    final isFullScreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isFullScreen);
    return;
  }

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}
