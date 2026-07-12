import '../../models/printer_config.dart';

Future<void> warmUpDirectPrinter({required PrinterConfig config}) async {}

Future<void> sendEscPosBytes({
  required PrinterConfig config,
  required List<int> bytes,
  Duration timeout = const Duration(seconds: 6),
}) {
  throw UnsupportedError(
    'Direct ESC/POS printing is not available in a browser build. '
    'Run the POS app on Android, Windows, macOS, Linux, or iOS for LAN, USB, or Bluetooth printing.',
  );
}

Future<List<PrinterDeviceInfo>> discoverDirectPrinters({
  required String connectionType,
}) {
  throw UnsupportedError(
    'USB/Bluetooth printer discovery is not available in a browser build.',
  );
}
