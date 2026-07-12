import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_exception.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/printer_config.dart';
import '../models/order_models.dart';
import '../services/printer_transport/printer_transport.dart';
import '../services/receipt_printer_service.dart';

final printerRepositoryProvider = Provider<PrinterRepository>((ref) {
  return PrinterRepository(
    storage: ref.watch(secureStorageServiceProvider),
    receiptPrinter: ref.watch(receiptPrinterServiceProvider),
  );
});

final printerConfigProvider = FutureProvider<PrinterConfig?>((ref) {
  return ref.watch(printerRepositoryProvider).restoreConfig();
});

class PrinterRepository {
  PrinterRepository({
    required SecureStorageService storage,
    required ReceiptPrinterService receiptPrinter,
  }) : _storage = storage,
       _receiptPrinter = receiptPrinter;

  final SecureStorageService _storage;
  final ReceiptPrinterService _receiptPrinter;

  Future<PrinterConfig?> restoreConfig() {
    return _storage.readPrinterConfig();
  }

  Future<void> saveConfig(PrinterConfig config) {
    return _storage.savePrinterConfig(config);
  }

  Future<void> clearConfig() {
    return _storage.clearPrinterConfig();
  }

  Future<List<PrinterDeviceInfo>> discoverPrinters(String connectionType) {
    return discoverDirectPrinters(connectionType: connectionType);
  }

  Future<void> warmUp(PrinterConfig? config) async {
    if (config == null || !config.enabled || !config.hasDeviceIdentity) {
      return;
    }
    await warmUpDirectPrinter(config: config);
  }

  Future<int> printReceipt(
    ReceiptPrintObject receipt, {
    String? currencyCode,
    PrinterConfig? config,
  }) async {
    final resolvedConfig = config ?? await restoreConfig();
    if (resolvedConfig == null) {
      throw const AppException(
        message: 'Printer is not configured. Add the receipt printer IP first.',
      );
    }
    if (!resolvedConfig.enabled || !resolvedConfig.printReceipts) {
      throw const AppException(message: 'Receipt printer is disabled.');
    }
    if (!resolvedConfig.hasDeviceIdentity) {
      throw const AppException(
        message: 'Select or configure the receipt printer first.',
      );
    }

    final bytes = await _receiptPrinter.buildEscPos(
      receipt,
      currencyCode: currencyCode,
      paperWidth: resolvedConfig.paperWidth,
    );
    if (bytes.isEmpty) {
      throw const AppException(
        message: 'Receipt did not produce printable ESC/POS data.',
      );
    }
    await sendEscPosBytes(config: resolvedConfig, bytes: bytes);
    return bytes.length;
  }

  Future<void> printTestPage(PrinterConfig config) async {
    final receipt = ReceiptPrintObject.fromResponse({
      'order': {'id': 'TEST'},
      'print_object': {
        'paper': config.paperWidth,
        'print_object': [
          {'type': 'init'},
          {'type': 'text', 'text': 'SELFX POS', 'align': 'center'},
          {'type': 'text', 'text': 'Printer test', 'align': 'center'},
          {'type': 'divider'},
          {'type': 'row', 'left': 'Printer', 'right': config.name},
          {
            'type': 'row',
            'left': 'Type',
            'right': config.connectionType.toUpperCase(),
          },
          {
            'type': 'row',
            'left': config.isLan ? 'Host' : 'Device',
            'right': config.isLan
                ? '${config.host}:${config.port}'
                : (config.address ?? config.vendorId ?? config.name),
          },
          {'type': 'feed', 'lines': 2},
          {'type': 'cut'},
        ],
      },
    });
    final bytes = await _receiptPrinter.buildEscPos(
      receipt,
      paperWidth: config.paperWidth,
    );
    if (!config.hasDeviceIdentity) {
      throw const AppException(
        message: 'Select or configure the printer first.',
      );
    }
    await sendEscPosBytes(config: config, bytes: bytes);
  }
}
