import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

import '../../models/printer_config.dart';

const _smartPosPrinterChannel = MethodChannel('selfx_pos/smartpos_printer');

Future<void> warmUpDirectPrinter({required PrinterConfig config}) async {
  if (config.connectionType != 'smartpos') {
    return;
  }
  if (!Platform.isAndroid) {
    return;
  }
  await _smartPosPrinterChannel
      .invokeMethod<bool>('warmUpPrinter')
      .timeout(const Duration(seconds: 2), onTimeout: () => false);
}

Future<void> sendEscPosBytes({
  required PrinterConfig config,
  required List<int> bytes,
  Duration timeout = const Duration(seconds: 6),
}) async {
  if (config.connectionType == 'smartpos') {
    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'SmartPOS built-in printer is only available on Android.',
      );
    }
    await _smartPosPrinterChannel.invokeMethod<int>(
      'printEscPos',
      Uint8List.fromList(bytes),
    );
    return;
  }

  if (config.isLan) {
    final host = config.host?.trim();
    if (host == null || host.isEmpty) {
      throw ArgumentError('LAN printer host is required.');
    }
    return _sendLanEscPosBytes(
      host: host,
      port: config.port,
      bytes: bytes,
      timeout: timeout,
    );
  }

  if (config.isUsb || config.isBluetooth) {
    final printer = _printerFromConfig(config);
    final service = FlutterThermalPrinter.instance;
    final connected = await service.connect(printer);
    if (!connected) {
      throw StateError('Could not connect to ${config.name}.');
    }
    try {
      await service.printData(printer, bytes, longData: true);
    } finally {
      await service.disconnect(printer);
    }
    return;
  }

  throw UnsupportedError('Unsupported printer type: ${config.connectionType}');
}

Future<List<PrinterDeviceInfo>> discoverDirectPrinters({
  required String connectionType,
}) async {
  if (connectionType == 'smartpos') {
    return const [
      PrinterDeviceInfo(
        name: 'SmartPOS built-in printer',
        connectionType: 'smartpos',
        isConnected: true,
      ),
    ];
  }

  final service = FlutterThermalPrinter.instance;
  final types = switch (connectionType) {
    'usb' => const [ConnectionType.USB],
    'bluetooth' => const [ConnectionType.BLE],
    _ => const [ConnectionType.USB, ConnectionType.BLE],
  };

  final completer = Completer<List<PrinterDeviceInfo>>();
  late final StreamSubscription<List<Printer>> subscription;
  subscription = service.devicesStream.listen((printers) {
    if (!completer.isCompleted) {
      completer.complete(printers.map(_deviceInfoFromPrinter).toList());
    }
  });

  await service.getPrinters(
    connectionTypes: types,
    refreshDuration: const Duration(seconds: 2),
  );

  try {
    return await completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => const <PrinterDeviceInfo>[],
    );
  } finally {
    await subscription.cancel();
    await service.stopScan();
  }
}

Future<void> _sendLanEscPosBytes({
  required String host,
  required int port,
  required List<int> bytes,
  Duration timeout = const Duration(seconds: 6),
}) async {
  Socket? socket;
  try {
    socket = await Socket.connect(host, port, timeout: timeout);
    socket.setOption(SocketOption.tcpNoDelay, true);
    socket.add(bytes);
    await socket.flush();
    await socket.close();
  } finally {
    socket?.destroy();
  }
}

Printer _printerFromConfig(PrinterConfig config) {
  return Printer(
    name: config.name,
    address: config.address,
    vendorId: config.vendorId,
    productId: config.productId,
    connectionType: config.isUsb ? ConnectionType.USB : ConnectionType.BLE,
  );
}

PrinterDeviceInfo _deviceInfoFromPrinter(Printer printer) {
  return PrinterDeviceInfo(
    name: printer.name ?? 'Receipt printer',
    connectionType: printer.connectionType == ConnectionType.USB
        ? 'usb'
        : 'bluetooth',
    address: printer.address,
    vendorId: printer.vendorId,
    productId: printer.productId,
    isConnected: printer.isConnected,
  );
}
