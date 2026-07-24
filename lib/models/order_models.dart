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
    final order = _asMap(json['order']) ?? const <String, dynamic>{};
    final commands = _asMapList(commandsValue);
    final document = _asMap(json['document']) ?? const <String, dynamic>{};
    final documentCommands = _itemWiseReportCommandsFromDocument(document);

    return ReceiptPrintObject(
      raw: json,
      order: order,
      commands: documentCommands.isNotEmpty
          ? documentCommands
          : (commands.isEmpty ? _receiptCommandsFromOrder(order) : commands),
      paper: _nullableString(
        printObject?['paper'] ?? json['paper'] ?? document['paper_width'],
      ),
      fontSize: _nullableString(
        printObject?['font_size'] ??
            printObject?['fontSize'] ??
            json['font_size'] ??
            json['fontSize'] ??
            document['font_size'] ??
            document['fontSize'],
      ),
    );
  }

  bool get hasCommands => commands.isNotEmpty;
}

List<Map<String, dynamic>> _itemWiseReportCommandsFromDocument(
  Map<String, dynamic> document,
) {
  final layout = _stringValue(
    document['layout'] ?? document['type'] ?? document['report_type'],
  ).toLowerCase();
  if (layout != 'item' && layout != 'item_wise' && layout != 'itemwise') {
    return const <Map<String, dynamic>>[];
  }
  final rows = _asMapList(document['rows']);
  if (rows.isEmpty) {
    return const <Map<String, dynamic>>[];
  }

  final columns = _asMap(document['columns']) ?? const <String, dynamic>{};
  final commands = <Map<String, dynamic>>[
    {'type': 'init'},
    {
      'type': 'text',
      'text': _stringValue(
        document['restaurant_name'] ?? document['restaurantName'],
        fallback: 'RESTAURANT',
      ).toUpperCase(),
      'align': 'center',
      'style': 'bold',
    },
    {
      'type': 'text',
      'text': _stringValue(
        document['title'],
        fallback: 'ITEM WISE REPORT',
      ).toUpperCase(),
      'align': 'center',
      'style': 'bold',
    },
    {'type': 'feed', 'lines': 1},
    {
      'type': 'text',
      'text':
          'Report From Date : ${_stringValue(document['date_from_label'] ?? document['dateFromLabel'])}',
      'align': 'left',
    },
    {
      'type': 'text',
      'text':
          'To Date : ${_stringValue(document['date_to_label'] ?? document['dateToLabel'])}',
      'align': 'left',
    },
    {
      'type': 'text',
      'text':
          'PrintDate : ${_stringValue(document['print_date'] ?? document['printDate'])}',
      'align': 'left',
    },
    {'type': 'divider'},
    {
      'type': 'table',
      'columns': [
        {
          'key': 'code',
          'label': _stringValue(columns['code'], fallback: 'Code'),
        },
        {
          'key': 'description',
          'label': _stringValue(
            columns['description'],
            fallback: 'Description',
          ),
        },
        {'key': 'qty', 'label': _stringValue(columns['qty'], fallback: 'Qty')},
        {
          'key': 'amount',
          'label': _stringValue(columns['amount'], fallback: 'Amount'),
          'align': 'right',
        },
      ],
      'rows': rows.map((row) {
        return <String, dynamic>{
          'code': _stringValue(row['code']),
          'description': _stringValue(
            row['description'] ?? row['name'] ?? row['item'],
          ).toUpperCase(),
          'qty': _stringValue(row['qty'] ?? row['quantity']),
          'amount': _reportAmount(row['amount'] ?? row['total']),
        };
      }).toList(),
    },
    {'type': 'divider'},
    for (final total in _asMapList(document['totals']))
      {
        'type': 'row',
        'left': _stringValue(total['label'], fallback: 'Total Amount'),
        'right': _reportAmount(total['amount'] ?? total['total']),
        'style': 'bold',
      },
    {'type': 'divider'},
    {'type': 'feed', 'lines': 2},
    {'type': 'cut', 'mode': 'full'},
  ];
  return commands;
}

String _reportAmount(Object? value) {
  final amount = _doubleValue(value);
  return amount == null ? _stringValue(value) : amount.toStringAsFixed(2);
}

List<Map<String, dynamic>> _receiptCommandsFromOrder(
  Map<String, dynamic> order,
) {
  if (order.isEmpty) {
    return const <Map<String, dynamic>>[];
  }
  final commands = <Map<String, dynamic>>[
    {'type': 'init'},
    {'type': 'text', 'text': 'RECEIPT', 'align': 'center', 'style': 'bold'},
  ];
  final token = _nullableString(order['token']);
  if (token != null) {
    commands.add({
      'type': 'text',
      'text': 'TOKEN #$token',
      'align': 'center',
      'style': 'bold_large',
    });
  }
  final orderNumber = _nullableString(
    order['order_number'] ??
        order['order_no'] ??
        order['number'] ??
        order['id'],
  );
  if (orderNumber != null) {
    commands.add({
      'type': 'text',
      'text': 'Order: $orderNumber',
      'align': 'center',
      'style': 'bold',
    });
  }
  final createdAt = _nullableString(order['created_at']);
  if (createdAt != null) {
    commands.add({'type': 'text', 'text': createdAt, 'align': 'center'});
  }
  commands.add({'type': 'divider'});

  _addTextCommand(commands, 'Type', order['type']);
  _addTextCommand(commands, 'Table', order['table_name']);
  _addTextCommand(commands, 'Customer', order['customer_name']);
  _addTextCommand(commands, 'Payment', order['payment_status']);
  _addTextCommand(commands, 'Method', order['payment_method']);
  _addTextCommand(commands, 'Txn', order['transaction_id']);
  _addNoteCommand(commands, order['notes']);

  final items = _asMapList(order['items']);
  if (items.isNotEmpty) {
    commands.add({'type': 'divider'});
    for (final item in items) {
      final quantity = _intValue(item['quantity']) ?? 1;
      final name = _receiptItemName(item);
      commands.add({
        'type': 'row',
        'left': '${quantity}x $name',
        'right': _receiptAmount(item['total'] ?? item['line_total']),
        'style': 'bold',
      });
      final unitPrice = _receiptAmount(item['unit_price']);
      if (unitPrice.isNotEmpty) {
        commands.add({'type': 'text', 'text': '@ $unitPrice each'});
      }
      for (final modifier in _asMapList(item['modifiers'])) {
        commands.add({
          'type': 'row',
          'left':
              '+ ${_stringValue(modifier['option_name'], fallback: 'Option')}',
          'right': _receiptAmount(modifier['price_adjustment']),
        });
      }
      _addTextCommand(commands, 'Kitchen', item['kitchen_counter_name']);
    }
  }

  commands.add({'type': 'divider'});
  _addAmountCommand(commands, 'Subtotal', order['subtotal']);
  _addAmountCommand(
    commands,
    'Discount',
    order['discount_total'],
    negative: true,
  );
  _addAmountCommand(commands, 'Extra charges', order['extra_charges_total']);
  for (final charge in _asMapList(order['extra_charges'])) {
    _addAmountCommand(
      commands,
      _stringValue(charge['label'], fallback: 'Charge'),
      charge['amount'],
    );
  }
  final serviceChargeLabel = _stringValue(
    order['service_charge_label'],
    fallback: 'Service charge',
  );
  _addAmountCommand(commands, serviceChargeLabel, order['service_charge']);
  for (final tax in _asMapList(order['tax_breakdown'])) {
    final label = _receiptTaxLabel(tax);
    _addAmountCommand(commands, label, tax['amount']);
  }
  _addAmountCommand(commands, 'TOTAL', order['total'], bold: true);

  final trackingUrl = _nullableString(order['tracking_url']);
  if (trackingUrl != null) {
    commands.addAll([
      {'type': 'feed', 'lines': 1},
      {
        'type': 'text',
        'text': 'Scan for digital receipt',
        'align': 'center',
        'style': 'bold',
      },
      {'type': 'qr', 'data': trackingUrl, 'size': 4},
    ]);
  }
  commands.addAll([
    {'type': 'feed', 'lines': 1},
    {'type': 'cut'},
  ]);
  return commands;
}

void _addTextCommand(
  List<Map<String, dynamic>> commands,
  String label,
  Object? value,
) {
  final text = _nullableString(value);
  if (text == null) {
    return;
  }
  commands.add({'type': 'text', 'text': '$label: $text'});
}

void _addNoteCommand(List<Map<String, dynamic>> commands, Object? value) {
  final text = _nullableString(value);
  if (text == null) {
    return;
  }
  commands.add({'type': 'text', 'text': 'Note: $text'});
}

void _addAmountCommand(
  List<Map<String, dynamic>> commands,
  String label,
  Object? value, {
  bool negative = false,
  bool bold = false,
}) {
  final amount = _doubleValue(value);
  if (amount == null || amount == 0) {
    return;
  }
  final display = _receiptAmount(negative ? -amount.abs() : amount);
  commands.add({
    'type': 'row',
    'left': label,
    'right': display,
    if (bold) 'style': 'bold_large',
  });
}

String _receiptAmount(Object? value) {
  final amount = _doubleValue(value);
  if (amount == null) {
    return '';
  }
  final sign = amount < 0 ? '-' : '';
  return '${sign}Rs ${amount.abs().toStringAsFixed(2)}';
}

String _receiptItemName(Map<String, dynamic> item) {
  final name = _stringValue(
    item['name'] ?? item['item_name'] ?? item['menu_item_name'],
    fallback: 'Item',
  );
  final variant = _nullableString(item['variant_name'] ?? item['variant']);
  return variant == null ? name : '$name ($variant)';
}

String _receiptTaxLabel(Map<String, dynamic> tax) {
  final name = _stringValue(tax['name'], fallback: 'Tax');
  final rate = _doubleValue(tax['rate']);
  if (rate == null || rate == 0) {
    return name;
  }
  final included = tax['included'] == true ? ' incl' : '';
  return '$name ${rate.toStringAsFixed(rate.truncateToDouble() == rate ? 0 : 2)}%$included';
}

class PosDailyReport {
  const PosDailyReport({
    required this.raw,
    required this.summary,
    required this.recentOrders,
  });

  final Map<String, dynamic> raw;
  final Map<String, dynamic> summary;
  final List<PosDailyReportOrder> recentOrders;

  factory PosDailyReport.fromResponse(Map<String, dynamic> json) {
    final summary = _asMap(json['summary']) ?? const <String, dynamic>{};
    final ordersValue =
        json['recent_orders'] ??
        json['recentOrders'] ??
        json['orders'] ??
        json['data'];
    return PosDailyReport(
      raw: json,
      summary: summary,
      recentOrders: _asMapList(
        ordersValue,
      ).map(PosDailyReportOrder.fromJson).toList(),
    );
  }

  int get todayOrders {
    return _intValue(
          summary['today_orders'] ??
              summary['todayOrders'] ??
              summary['orders'] ??
              summary['orders_count'] ??
              summary['count'] ??
              raw['today_orders'],
        ) ??
        0;
  }

  double get todayRevenue {
    return _doubleValue(
          summary['today_revenue'] ??
              summary['todayRevenue'] ??
              summary['revenue'] ??
              summary['sales'] ??
              summary['total_sales'] ??
              raw['today_revenue'],
        ) ??
        0;
  }

  int get todayPending {
    return _intValue(
          summary['today_pending'] ??
              summary['todayPending'] ??
              summary['pending'] ??
              summary['pending_orders'] ??
              raw['today_pending'],
        ) ??
        0;
  }
}

class PosDailyReportOrder {
  const PosDailyReportOrder({
    required this.raw,
    this.id,
    this.orderNumber,
    this.status,
    this.paymentStatus,
    this.paymentMethod,
    this.type,
    this.total,
    this.token,
    this.customerName,
    this.createdAt,
    this.paymentHint,
  });

  final Map<String, dynamic> raw;
  final int? id;
  final String? orderNumber;
  final String? status;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? type;
  final double? total;
  final int? token;
  final String? customerName;
  final DateTime? createdAt;
  final String? paymentHint;

  factory PosDailyReportOrder.fromJson(Map<String, dynamic> json) {
    return PosDailyReportOrder(
      raw: json,
      id: _intValue(json['id'] ?? json['order_id'] ?? json['orderId']),
      orderNumber: _nullableString(
        json['order_number'] ?? json['orderNumber'] ?? json['number'],
      ),
      status: _nullableString(json['status']),
      paymentStatus: _nullableString(
        json['payment_status'] ?? json['paymentStatus'],
      ),
      paymentMethod: _nullableString(
        json['payment_method'] ?? json['paymentMethod'],
      ),
      type: _nullableString(json['type'] ?? json['order_type']),
      total: _doubleValue(json['total'] ?? json['grand_total']),
      token: _intValue(json['token'] ?? json['token_no']),
      customerName: _nullableString(
        json['customer_name'] ?? json['customerName'] ?? json['customer'],
      ),
      createdAt: _dateTimeValue(json['created_at'] ?? json['createdAt']),
      paymentHint: _nullableString(json['payment_hint'] ?? json['paymentHint']),
    );
  }

  String get displayNumber {
    return orderNumber ??
        (token == null ? null : 'Token $token') ??
        (id == null ? 'Order' : 'Order $id');
  }
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

DateTime? _dateTimeValue(Object? value) {
  if (value is DateTime) {
    return value;
  }
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  return DateTime.tryParse(text);
}
