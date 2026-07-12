import 'dart:js_interop';

import 'package:web/web.dart';

Future<void> toggleFullscreen() async {
  if (document.fullscreenElement == null) {
    final element = document.documentElement;
    if (element != null) {
      await element.requestFullscreen().toDart;
    }
  } else {
    await document.exitFullscreen().toDart;
  }
}
