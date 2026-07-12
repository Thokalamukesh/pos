class CustomerDisplaySetup {
  const CustomerDisplaySetup({
    required this.restaurantName,
    required this.restaurantSlug,
    required this.branchName,
    required this.branchId,
    required this.terminalCode,
    required this.syncToken,
    this.showPrices = true,
  });

  final String restaurantName;
  final String restaurantSlug;
  final String branchName;
  final int branchId;
  final String terminalCode;
  final String syncToken;
  final bool showPrices;

  bool get hasSyncToken => syncToken.trim().isNotEmpty;

  CustomerDisplaySetup copyWith({
    String? restaurantName,
    String? restaurantSlug,
    String? branchName,
    int? branchId,
    String? terminalCode,
    String? syncToken,
    bool? showPrices,
  }) {
    return CustomerDisplaySetup(
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantSlug: restaurantSlug ?? this.restaurantSlug,
      branchName: branchName ?? this.branchName,
      branchId: branchId ?? this.branchId,
      terminalCode: terminalCode ?? this.terminalCode,
      syncToken: syncToken ?? this.syncToken,
      showPrices: showPrices ?? this.showPrices,
    );
  }
}

class CustomerBoardSnapshot {
  const CustomerBoardSnapshot({
    this.preparing = const [],
    this.ready = const [],
  });

  final List<CustomerDisplayOrder> preparing;
  final List<CustomerDisplayOrder> ready;

  factory CustomerBoardSnapshot.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']).isNotEmpty ? _asMap(json['data']) : json;
    final explicitPreparing = _ordersFrom(
      data['preparingOrders'] ??
          data['preparing'] ??
          data['queued'] ??
          data['cooking'] ??
          data['confirmed'] ??
          const [],
    );
    final explicitReady = _ordersFrom(
      data['readyOrders'] ?? data['ready'] ?? const [],
    );
    final allOrders = _ordersFrom(data['orders'] ?? data['items'] ?? const []);

    if (allOrders.isEmpty) {
      return CustomerBoardSnapshot(
        preparing: explicitPreparing.where((order) => !order.isHidden).toList(),
        ready: explicitReady.where((order) => !order.isHidden).toList(),
      );
    }

    return CustomerBoardSnapshot(
      preparing: allOrders.where((order) => order.isPreparing).toList(),
      ready: allOrders.where((order) => order.isReady).toList(),
    );
  }
}

class CustomerDisplayOrder {
  const CustomerDisplayOrder({
    required this.id,
    required this.orderNumber,
    required this.token,
    required this.status,
    this.updatedAt,
  });

  final String id;
  final String orderNumber;
  final String token;
  final String status;
  final DateTime? updatedAt;

  bool get isReady => _normalizedStatus == 'ready';

  bool get isPreparing {
    return const {
      'new',
      'queued',
      'queue',
      'cooking',
      'preparing',
      'confirmed',
      'accepted',
      'in_progress',
    }.contains(_normalizedStatus);
  }

  bool get isHidden {
    return const {
      'completed',
      'cancelled',
      'canceled',
      'served',
      'closed',
    }.contains(_normalizedStatus);
  }

  String get _normalizedStatus =>
      status.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');

  factory CustomerDisplayOrder.fromJson(Map<String, dynamic> json) {
    final tokenValue =
        json['token'] ??
        json['token_no'] ??
        json['tokenNumber'] ??
        json['token_number'] ??
        json['display_token'] ??
        json['number'] ??
        '-';
    return CustomerDisplayOrder(
      id: (json['id'] ?? json['order_id'] ?? json['uuid'] ?? tokenValue)
          .toString(),
      orderNumber:
          (json['order_number'] ??
                  json['orderNumber'] ??
                  json['code'] ??
                  json['number'] ??
                  '-')
              .toString(),
      token: tokenValue.toString(),
      status: (json['status'] ?? '').toString(),
      updatedAt: DateTime.tryParse(
        (json['updated_at'] ?? json['updatedAt'] ?? '').toString(),
      ),
    );
  }
}

class CustomerCart {
  const CustomerCart({
    required this.active,
    this.items = const [],
    this.subtotal = 0,
    this.tax = 0,
    this.total = 0,
    this.currency = 'USD',
    this.updatedAt,
  });

  final bool active;
  final List<CustomerCartItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final String currency;
  final DateTime? updatedAt;

  factory CustomerCart.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']).isNotEmpty ? _asMap(json['data']) : json;
    final cart = _asMap(data['cart']);
    return CustomerCart(
      active: data['active'] == true,
      items: _cartItemsFrom(cart['items']),
      subtotal: _asDouble(cart['subtotal']),
      tax: _asDouble(cart['tax']),
      total: _asDouble(cart['total']),
      currency: (cart['currency'] ?? 'USD').toString(),
      updatedAt: DateTime.tryParse(
        (cart['updated_at'] ?? data['updated_at'] ?? '').toString(),
      ),
    );
  }
}

class CustomerCartItem {
  const CustomerCartItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String name;
  final int quantity;
  final double price;

  factory CustomerCartItem.fromJson(Map<String, dynamic> json) {
    return CustomerCartItem(
      name: (json['name'] ?? json['menu_item_name'] ?? json['title'] ?? 'Item')
          .toString(),
      quantity: _asInt(json['quantity'] ?? json['qty'] ?? 1),
      price: _asDouble(json['price'] ?? json['total']),
    );
  }
}

class DisplayBootstrap {
  const DisplayBootstrap({
    required this.branchId,
    required this.branchName,
    required this.terminalCode,
    this.showPrices = true,
  });

  final int branchId;
  final String branchName;
  final String terminalCode;
  final bool showPrices;

  factory DisplayBootstrap.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']).isNotEmpty ? _asMap(json['data']) : json;
    final branch = _asMap(data['branch']);
    final terminal = _asMap(data['terminal']);
    final display = _asMap(data['display']);
    return DisplayBootstrap(
      branchId: _asInt(branch['id']),
      branchName: (branch['name'] ?? data['branch_name'] ?? 'Main Branch')
          .toString(),
      terminalCode: (terminal['code'] ?? data['terminal_code'] ?? '')
          .toString(),
      showPrices: display['show_prices'] != false,
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

List<CustomerDisplayOrder> _ordersFrom(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => CustomerDisplayOrder.fromJson(Map.from(item)))
      .toList();
}

List<CustomerCartItem> _cartItemsFrom(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => CustomerCartItem.fromJson(Map.from(item)))
      .toList();
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
