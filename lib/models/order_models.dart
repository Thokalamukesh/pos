class CreatePosOrderRequest {
  const CreatePosOrderRequest({
    required this.items,
    required this.type,
    required this.posTerminalCode,
    this.tableId,
    this.customerId,
    this.customerName = 'Guest',
    this.customerPhone,
    this.customerAddress,
    this.notes,
    this.discount,
    this.posRegisterPayment,
  });

  final List<PosOrderItemRequest> items;
  final String type;
  final Object? tableId;
  final Object? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final String? notes;
  final String posTerminalCode;
  final Map<String, dynamic>? discount;
  final PosRegisterPayment? posRegisterPayment;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'items': items.map((item) => item.toJson()).toList(),
      'type': type,
      if (tableId != null) 'table_id': tableId,
      if (customerId != null) 'customer_id': customerId,
      if (customerName != null && customerName!.trim().isNotEmpty)
        'customer_name': customerName!.trim(),
      if (customerPhone != null && customerPhone!.trim().isNotEmpty)
        'customer_phone': customerPhone!.trim(),
      if (customerAddress != null && customerAddress!.trim().isNotEmpty)
        'customer_address': customerAddress!.trim(),
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      'pos_terminal_code': posTerminalCode,
      if (discount != null) 'discount': discount,
      if (posRegisterPayment != null)
        'pos_register_payment': posRegisterPayment!.toJson(),
    };
  }
}

class PosOrderItemRequest {
  const PosOrderItemRequest({
    required this.menuItemId,
    required this.quantity,
    this.variantId,
    this.notes,
    this.modifiers = const <Map<String, dynamic>>[],
  });

  final Object menuItemId;
  final Object? variantId;
  final int quantity;
  final String? notes;
  final List<Map<String, dynamic>> modifiers;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'menu_item_id': menuItemId,
      if (variantId != null) 'variant_id': variantId,
      'quantity': quantity,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
      if (modifiers.isNotEmpty) 'modifiers': modifiers,
    };
  }
}

class PosRegisterPayment {
  const PosRegisterPayment({required this.method, this.cashTendered, this.tip});

  final String method;
  final double? cashTendered;
  final double? tip;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'method': method,
      if (cashTendered != null) 'cash_tendered': _moneyValue(cashTendered!),
      if (tip != null && tip! > 0) 'tip': _moneyValue(tip!),
    };
  }
}

class PosOrderResult {
  const PosOrderResult({required this.raw, required this.order});

  final Map<String, dynamic> raw;
  final Map<String, dynamic> order;

  factory PosOrderResult.fromResponse(Map<String, dynamic> json) {
    final order = _asMap(
      json['order'] ??
          json['pos_order'] ??
          json['posOrder'] ??
          json['ticket'] ??
          json['data'],
    );
    return PosOrderResult(raw: json, order: order ?? json);
  }

  int? get id {
    return _intValue(
      order['id'] ?? raw['order_id'] ?? raw['orderId'] ?? raw['id'],
    );
  }

  String get displayNumber {
    return _stringValue(
      order['order_number'] ??
          order['order_no'] ??
          order['number'] ??
          order['invoice_number'] ??
          order['reference'] ??
          order['token'] ??
          id,
      fallback: 'Order',
    );
  }

  double? get total {
    return _doubleValue(
      order['total'] ??
          order['grand_total'] ??
          order['payable_amount'] ??
          order['amount_due'] ??
          raw['total'],
    );
  }
}

class PosOrderPaymentResult {
  const PosOrderPaymentResult({required this.raw});

  final Map<String, dynamic> raw;

  factory PosOrderPaymentResult.fromResponse(Map<String, dynamic> json) {
    return PosOrderPaymentResult(raw: json);
  }

  Map<String, dynamic>? get order => _asMap(raw['order']);

  Map<String, dynamic>? get payment => _asMap(raw['payment']);

  Map<String, dynamic>? get qrPayload {
    final paymentQr = _asMap(payment?['qr']);
    if (paymentQr != null) {
      return paymentQr;
    }
    return _asMap(raw['qr']);
  }

  String? get qrText {
    return _nullableString(
      raw['qr'] ??
          raw['upi_url'] ??
          raw['qr_url'] ??
          qrPayload?['upi_url'] ??
          qrPayload?['qr_url'] ??
          qrPayload?['url'],
    );
  }

  String? get orderNumber {
    return _nullableString(
      raw['order_number'] ??
          raw['orderNumber'] ??
          order?['order_number'] ??
          order?['order_no'] ??
          order?['number'],
    );
  }

  String? get gateway => _nullableString(raw['gateway'] ?? payment?['gateway']);

  String? get paymentStatus {
    return _nullableString(raw['payment_status'] ?? order?['payment_status']);
  }

  String? get displayUpiId => _nullableString(qrPayload?['display_upi_id']);

  String? get payeeName => _nullableString(qrPayload?['payee_name']);

  double? get total {
    return _doubleValue(
      raw['total'] ?? order?['total'] ?? order?['grand_total'],
    );
  }

  int? get timeoutSeconds {
    return _intValue(
      raw['timeout_seconds'] ??
          raw['timeoutSeconds'] ??
          payment?['timeout_seconds'] ??
          payment?['timeoutSeconds'],
    );
  }
}

class ReceiptPrintObject {
  const ReceiptPrintObject({
    required this.raw,
    required this.order,
    required this.commands,
    this.paper,
    this.fontSize,
  });

  final Map<String, dynamic> raw;
  final Map<String, dynamic> order;
  final List<Map<String, dynamic>> commands;
  final String? paper;
  final String? fontSize;

  factory ReceiptPrintObject.fromResponse(Map<String, dynamic> json) {
    final printObjectValue = json['print_object'] ?? json['printObject'];
    final printObject = _asMap(printObjectValue);
    final commandsValue = printObject == null
        ? printObjectValue
        : printObject['print_object'] ??
              printObject['commands'] ??
              printObject['items'];

    return ReceiptPrintObject(
      raw: json,
      order: _asMap(json['order']) ?? const <String, dynamic>{},
      commands: _asMapList(commandsValue),
      paper: _nullableString(printObject?['paper'] ?? json['paper']),
      fontSize: _nullableString(
        printObject?['font_size'] ??
            printObject?['fontSize'] ??
            json['font_size'] ??
            json['fontSize'],
      ),
    );
  }

  bool get hasCommands => commands.isNotEmpty;
}

Object apiIdentifierFromString(String value) {
  return int.tryParse(value) ?? value;
}

double _moneyValue(double value) {
  return (value * 100).roundToDouble() / 100;
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

List<Map<String, dynamic>> _asMapList(Object? value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
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

double? _doubleValue(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}
