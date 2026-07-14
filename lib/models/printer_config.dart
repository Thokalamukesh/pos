class PrinterConfig {
  const PrinterConfig({
    required this.name,
    required this.connectionType,
    this.host,
    this.port = 9100,
    this.address,
    this.vendorId,
    this.productId,
    this.paperWidth = '80mm',
    this.enabled = true,
    this.printReceipts = true,
  });

  final String name;
  final String connectionType;
  final String? host;
  final int port;
  final String? address;
  final String? vendorId;
  final String? productId;
  final String paperWidth;
  final bool enabled;
  final bool printReceipts;

  bool get isLan => connectionType == 'lan';
  bool get isUsb => connectionType == 'usb';
  bool get isBluetooth => connectionType == 'bluetooth';

  bool get hasDeviceIdentity {
    if (connectionType == 'smartpos') {
      return true;
    }
    if (isLan) {
      return host?.trim().isNotEmpty == true;
    }
    if (isUsb) {
      return vendorId?.trim().isNotEmpty == true ||
          address?.trim().isNotEmpty == true ||
          name.trim().isNotEmpty;
    }
    if (isBluetooth) {
      return address?.trim().isNotEmpty == true;
    }
    return false;
  }

  PrinterConfig copyWith({
    String? name,
    String? connectionType,
    String? host,
    int? port,
    String? address,
    String? vendorId,
    String? productId,
    String? paperWidth,
    bool? enabled,
    bool? printReceipts,
  }) {
    return PrinterConfig(
      name: name ?? this.name,
      connectionType: connectionType ?? this.connectionType,
      host: host ?? this.host,
      port: port ?? this.port,
      address: address ?? this.address,
      vendorId: vendorId ?? this.vendorId,
      productId: productId ?? this.productId,
      paperWidth: paperWidth ?? this.paperWidth,
      enabled: enabled ?? this.enabled,
      printReceipts: printReceipts ?? this.printReceipts,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'connection_type': connectionType,
      if (host != null && host!.trim().isNotEmpty) 'host': host!.trim(),
      'port': port,
      if (address != null && address!.trim().isNotEmpty)
        'address': address!.trim(),
      if (vendorId != null && vendorId!.trim().isNotEmpty)
        'vendor_id': vendorId!.trim(),
      if (productId != null && productId!.trim().isNotEmpty)
        'product_id': productId!.trim(),
      'paper_width': _normalizePaperWidth(paperWidth),
      'enabled': enabled,
      'print_receipts': printReceipts,
    };
  }

  factory PrinterConfig.fromJson(Map<String, dynamic> json) {
    return PrinterConfig(
      name: _stringValue(json['name'], fallback: 'Receipt printer'),
      connectionType: _stringValue(
        json['connection_type'] ?? json['connectionType'],
        fallback: 'lan',
      ),
      host: _nullableString(json['host']),
      port: _intValue(json['port']) ?? 9100,
      address: _nullableString(json['address']),
      vendorId: _nullableString(json['vendor_id'] ?? json['vendorId']),
      productId: _nullableString(json['product_id'] ?? json['productId']),
      paperWidth: _normalizePaperWidth(
        _stringValue(
          json['paper_width'] ??
              json['paperWidth'] ??
              json['receipt_width'] ??
              json['receiptWidth'],
          fallback: '80mm',
        ),
      ),
      enabled: json['enabled'] != false,
      printReceipts:
          json['print_receipts'] != false && json['printReceipts'] != false,
    );
  }
}

class PrinterDeviceInfo {
  const PrinterDeviceInfo({
    required this.name,
    required this.connectionType,
    this.address,
    this.vendorId,
    this.productId,
    this.isConnected,
  });

  final String name;
  final String connectionType;
  final String? address;
  final String? vendorId;
  final String? productId;
  final bool? isConnected;

  PrinterConfig toConfig() {
    return PrinterConfig(
      name: name.isEmpty ? 'Receipt printer' : name,
      connectionType: connectionType,
      address: address,
      vendorId: vendorId,
      productId: productId,
    );
  }
}

String _normalizePaperWidth(String value) {
  final text = value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  if (text.contains('56') || text.contains('58')) {
    return '58mm';
  }
  if (text.contains('72')) {
    return '72mm';
  }
  if (text.contains('80') || text.contains('88')) {
    return '80mm';
  }
  return '80mm';
}

String _stringValue(Object? value, {String fallback = ''}) {
  final text = value?.toString();
  return text == null || text.isEmpty ? fallback : text;
}

String? _nullableString(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int? _intValue(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}
