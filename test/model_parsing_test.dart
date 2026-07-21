import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:selfx_pos/models/order_models.dart';
import 'package:selfx_pos/models/pairing_models.dart';
import 'package:selfx_pos/models/pos_bootstrap.dart';
import 'package:selfx_pos/models/printer_config.dart';
import 'package:selfx_pos/features/customer_display/domain/customer_display_models.dart';
import 'package:selfx_pos/repositories/offline_order_repository.dart';
import 'package:selfx_pos/repositories/shift_repository.dart';
import 'package:selfx_pos/services/shift_api_service.dart';
import 'package:selfx_pos/services/receipt_printer_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pairing start response parses official field names', () {
    final response = PairingStartResponse.fromJson({
      'data': {
        'pairing_code': '123456',
        'device_uuid': 'device-uuid',
        'expires_at': '2026-06-29T07:11:22+00:00',
      },
      'meta': null,
    });

    expect(response.pairingCode, '123456');
    expect(response.deviceUuid, 'device-uuid');
    expect(response.expiresAt, isNotNull);
  });

  test('pairing start response parses top-level POS start-post payload', () {
    final response = PairingStartResponse.fromJson({
      'pairing_code': '073138',
      'device_uuid': 'a367fff5-5e8d-4bb1-ac36-3231f0265eb5',
      'expires_at': '2026-07-08T11:01:31+00:00',
    });

    expect(response.pairingCode, '073138');
    expect(response.deviceUuid, 'a367fff5-5e8d-4bb1-ac36-3231f0265eb5');
    expect(response.expiresAt, isNotNull);
  });

  test(
    'pairing status parses admin complete response with partial objects',
    () {
      final response = PairingStatusResponse.fromJson({
        'data': {
          'pairing_code': '123456',
          'branch': {'id': 9},
          'pos_terminal': {'id': 12},
        },
        'meta': null,
      });

      expect(response.status, 'paired');
      expect(response.pairingCode, '123456');
      expect(response.branchId, 9);
      expect(response.posTerminal?.id, 12);
      expect(response.posTerminal?.code, 'T12');
    },
  );

  test(
    'POS bootstrap parses terminal sync token without hardcoding context',
    () {
      final bootstrap = PosBootstrap.fromJson({
        'restaurant': {'id': 1, 'name': 'Fixture Restaurant'},
        'branch': {'id': 1, 'name': 'Fixture Branch'},
        'pos_terminals': [
          {
            'id': 1,
            'code': 'T1',
            'name': 'Terminal 1',
            'sync_token': 'secret',
            'display_url':
                'https://selfx.laravel.cloud/order/fixture/display/1/T1',
          },
        ],
        'permissions': ['access_pos'],
        'plan_features': ['orders'],
      });

      expect(bootstrap.posTerminals.single.code, 'T1');
      expect(bootstrap.posTerminals.single.syncToken, 'secret');
      expect(bootstrap.permissions, contains('access_pos'));
    },
  );

  test('create POS order payload uses official payment field names', () {
    final request = CreatePosOrderRequest(
      type: 'takeaway',
      posTerminalCode: 'T1',
      items: const [
        PosOrderItemRequest(
          menuItemId: 5,
          variantId: 2,
          quantity: 3,
          modifiers: [
            {
              'modifier_option_id': 4,
              'modifier_name': 'Extras',
              'option_name': 'Cheese',
              'price_adjustment': 0.75,
              'quantity': 1,
            },
          ],
        ),
      ],
      posRegisterPayment: const PosRegisterPayment(
        method: 'cash',
        cashTendered: 50,
        tip: 5,
      ),
    );

    final json = request.toJson();

    expect(json['type'], 'takeaway');
    expect(json['pos_terminal_code'], 'T1');
    expect(json['items'], [
      {
        'menu_item_id': 5,
        'variant_id': 2,
        'quantity': 3,
        'modifiers': [
          {
            'modifier_option_id': 4,
            'modifier_name': 'Extras',
            'option_name': 'Cheese',
            'price_adjustment': 0.75,
            'quantity': 1,
          },
        ],
      },
    ]);
    expect(json['pos_register_payment'], {
      'method': 'cash',
      'cash_tendered': 50.0,
      'tip': 5.0,
    });
  });

  test('create POS order payload serializes dynamic QR register method', () {
    final request = CreatePosOrderRequest(
      type: 'takeaway',
      posTerminalCode: 'T1',
      items: const [PosOrderItemRequest(menuItemId: 5, quantity: 1)],
      posRegisterPayment: const PosRegisterPayment(method: 'phonepe'),
    );

    final json = request.toJson();

    expect(json['pos_register_payment'], {'method': 'phonepe'});
  });

  test('dynamic QR payment response parses real POS pay response shape', () {
    final response = PosOrderPaymentResult.fromResponse({
      'success': true,
      'order': {
        'id': 316,
        'token': 10,
        'order_number': 'ORD-6A4E3ECABE56E',
        'payment_status': 'pending',
        'payment_method': 'phonepe',
        'transaction_id': 'PP-316-1783512778',
        'total': 90,
      },
      'payment': {
        'type': 'dynamic_qr',
        'gateway': 'phonepe',
        'timeout_seconds': 300,
        'qr': {
          'upi_url':
              'upi://pay?pa=GODAVARICAFE@ybl&pn=GODAVARI%20CAFE&am=90.00&mam=90.00&tr=PP-316-1783512778&tn=Payment%20for%20ORD-6A4E3ECABE56E&mc=5812&mode=15&purpose=00',
          'qr_url': 'https://app.selfx.in/pay/qr/example',
          'display_upi_id': 'GODAVARICAFE@ybl',
          'payee_name': 'Kumar Bistro',
        },
      },
    });

    expect(response.qrText, startsWith('upi://pay?'));
    expect(response.gateway, 'phonepe');
    expect(response.orderNumber, 'ORD-6A4E3ECABE56E');
    expect(response.paymentStatus, 'pending');
    expect(response.displayUpiId, 'GODAVARICAFE@ybl');
    expect(response.payeeName, 'Kumar Bistro');
    expect(response.total, 90);
    expect(response.timeoutSeconds, 300);
  });

  test('POS order create response exposes dynamic QR payment data', () {
    final order = PosOrderResult.fromResponse({
      'success': true,
      'order': {
        'id': 332,
        'order_number': 'ORD-6A4E6EA73DD79',
        'payment_status': 'pending',
        'payment_method': 'phonepe',
        'total': 150,
      },
      'payment': {
        'type': 'dynamic_qr',
        'gateway': 'phonepe',
        'timeout_seconds': 300,
        'qr': {
          'upi_url':
              'upi://pay?pa=GODAVARICAFE@ybl&pn=GODAVARI%20CAFE&am=150.00&cu=INR',
          'display_upi_id': 'GODAVARICAFE@ybl',
          'payee_name': 'Kumar Bistro',
        },
      },
    });
    final payment = PosOrderPaymentResult.fromResponse(order.raw);

    expect(order.id, 332);
    expect(order.displayNumber, 'ORD-6A4E6EA73DD79');
    expect(payment.qrText, startsWith('upi://pay?'));
    expect(payment.gateway, 'phonepe');
    expect(payment.timeoutSeconds, 300);
  });

  test('payment QR endpoint response parses documented direct QR shape', () {
    final response = PosOrderPaymentResult.fromResponse({
      'order_id': 316,
      'order_number': 'ORD-6A4E3ECABE56E',
      'gateway': 'phonepe',
      'payment_status': 'pending',
      'total': 90,
      'timeout_seconds': '300',
      'qr': 'upi://pay?pa=GODAVARICAFE@ybl&pn=GODAVARI%20CAFE&am=90.00&cu=INR',
    });

    expect(response.qrText, startsWith('upi://pay?'));
    expect(response.gateway, 'phonepe');
    expect(response.orderNumber, 'ORD-6A4E3ECABE56E');
    expect(response.paymentStatus, 'pending');
    expect(response.total, 90);
    expect(response.timeoutSeconds, 300);
  });

  test('offline queued order serializes pending sync state', () {
    final createdAt = DateTime.utc(2026, 7, 12, 10, 30);
    final order = OfflineQueuedOrder(
      localId: 'OFF-T1-123',
      createdAt: createdAt,
      request: {
        'type': 'dine_in',
        'pos_terminal_code': 'T1',
        'items': [
          {'menu_item_id': 5, 'quantity': 1},
        ],
        'pos_register_payment': {'method': 'cash', 'cash_tendered': 100.0},
      },
      paymentMethod: 'cash',
      total: 90,
      status: OfflineOrderStatus.pending,
      attempts: 1,
      lastError: 'No internet',
    );

    final parsed = OfflineQueuedOrder.fromJson(order.toJson());

    expect(parsed.localId, 'OFF-T1-123');
    expect(parsed.createdAt, createdAt);
    expect(parsed.request['pos_terminal_code'], 'T1');
    expect(parsed.paymentMethod, 'cash');
    expect(parsed.total, 90);
    expect(parsed.status, OfflineOrderStatus.pending);
    expect(parsed.attempts, 1);
    expect(parsed.lastError, 'No internet');
  });

  test(
    'close shift retries string closing_cash payload after validation error',
    () async {
      final api = _RetryingShiftApiService();
      final repository = ShiftRepository(api: api);

      await repository.close(countedCash: 123.45, notes: 'Done');

      expect(api.closePayloads, hasLength(2));
      expect(api.closePayloads.first['closing_cash'], 123.45);
      expect(api.closePayloads.last['closing_cash'], '123.45');
      expect(api.closePayloads.last['notes_closing'], 'Done');
    },
  );

  test('receipt print object parses nested command list', () {
    final receipt = ReceiptPrintObject.fromResponse({
      'order': {'id': 88},
      'print_object': {
        'paper': '80mm',
        'font_size': 'normal',
        'print_object': [
          {'type': 'init'},
          {'type': 'text', 'text': 'Fixture Restaurant', 'align': 'center'},
          {'type': 'row', 'left': 'Subtotal', 'right': 'Rs 13.99'},
        ],
      },
    });

    expect(receipt.paper, '80mm');
    expect(receipt.commands, hasLength(3));
    expect(receipt.commands.last['right'], 'Rs 13.99');
  });

  test('POS daily report parses summary and recent orders', () {
    final report = PosDailyReport.fromResponse({
      'summary': {
        'today_orders': 99,
        'today_revenue': 9010,
        'today_pending': 96,
      },
      'recent_orders': [
        {
          'id': 1264,
          'order_number': 'ORD-20260720110121',
          'status': 'pending',
          'payment_status': 'pending',
          'payment_method': null,
          'type': 'dine_in',
          'total': 6,
          'token': 99,
          'customer_name': 'Kiosk guest',
          'created_at': '2026-07-20T17:37:17+00:00',
        },
      ],
    });

    expect(report.todayOrders, 99);
    expect(report.todayRevenue, 9010);
    expect(report.todayPending, 96);
    expect(report.recentOrders, hasLength(1));
    expect(report.recentOrders.single.displayNumber, 'ORD-20260720110121');
    expect(report.recentOrders.single.token, 99);
    expect(report.recentOrders.single.customerName, 'Kiosk guest');
  });

  test('customer display order history parses items and totals', () {
    final snapshot = CustomerBoardSnapshot.fromJson({
      'data': {
        'recent_orders': [
          {
            'id': 1264,
            'order_number': 'ORD-20260720110121',
            'status': 'pending',
            'token': 99,
            'total': 901,
            'currency': 'INR',
            'created_at': '2026-07-20T17:37:17+00:00',
            'items': [
              {
                'menu_item_name': 'Masala Dosa',
                'quantity': 2,
                'unit_price': 120,
                'total': 240,
              },
              {'name': 'Tea', 'qty': 1, 'line_total': 20},
            ],
          },
        ],
      },
    });

    expect(snapshot.history, hasLength(1));
    final order = snapshot.history.single;
    expect(order.token, '99');
    expect(order.total, 901);
    expect(order.currency, 'INR');
    expect(order.items, hasLength(2));
    expect(order.items.first.name, 'Masala Dosa');
    expect(order.items.first.quantity, 2);
    expect(order.items.first.lineTotal, 240);
    expect(order.items.last.lineTotal, 20);
  });

  test('receipt printer renderer produces ESC/POS bytes', () async {
    final receipt = ReceiptPrintObject.fromResponse({
      'order': {'id': 88},
      'print_object': {
        'paper': '80mm',
        'print_object': [
          {'type': 'init'},
          {'type': 'text', 'text': 'Fixture Restaurant', 'align': 'center'},
          {'type': 'divider'},
          {'type': 'row', 'left': 'Total', 'right': 'Rs 13.99'},
          {'type': 'feed', 'lines': 1},
          {'type': 'cut'},
        ],
      },
    });

    final bytes = await ReceiptPrinterService().buildEscPos(receipt);

    expect(bytes, isNotEmpty);
    expect(bytes.first, 27);
  });

  test('receipt printer normalizes INR currency and separators', () async {
    final receipt = ReceiptPrintObject.fromResponse({
      'order': {'id': 88},
      'print_object': {
        'paper': '56mm',
        'print_object': [
          {'type': 'init'},
          {'type': 'text', 'text': 'Dine in · 30 Jun', 'align': 'center'},
          {'type': 'row', 'left': '1x Sample Item', 'right': r'$120.00'},
          {'type': 'cut'},
        ],
      },
    });

    final bytes = await ReceiptPrinterService().buildEscPos(
      receipt,
      currencyCode: 'INR',
    );
    final text = String.fromCharCodes(bytes);

    expect(text, contains('Rs 120.00'));
    expect(text, isNot(contains(r'$120.00')));
    expect(text, isNot(contains('·')));
  });

  test(
    'receipt printer preserves server receipt footer and branding',
    () async {
      final receipt = ReceiptPrintObject.fromResponse({
        'order': {'id': 88},
        'print_object': {
          'paper': '80mm',
          'print_object': [
            {'type': 'init'},
            {
              'type': 'logo',
              'url': 'asset://restaurant-logo',
              'align': 'center',
              'max_width_dots': 230,
            },
            {
              'type': 'text',
              'text': 'Yogi Ahar',
              'align': 'center',
              'style': 'title',
            },
            {'type': 'text', 'text': 'Main', 'align': 'center'},
            {
              'type': 'text',
              'text': 'TOKEN #118',
              'align': 'center',
              'style': 'large_bold',
            },
            {'type': 'qr', 'data': 'https://app.selfx.in/order/88'},
            {'type': 'text', 'text': 'Thank you for your order!'},
            {'type': 'divider'},
            {'type': 'logo', 'max_width_dots': 230},
            {'type': 'cut', 'mode': 'partial'},
            {'type': 'text', 'text': 'TOKEN #62', 'style': 'large_bold'},
            {'type': 'cut', 'mode': 'full'},
          ],
        },
      });

      final bytes = await ReceiptPrinterService().buildEscPos(
        receipt,
        paperWidth: '56mm',
      );
      final text = String.fromCharCodes(bytes);

      expect(text, contains('Thank you for your order!'));
      expect(text, isNot(contains('Yogi Ahar')));
      expect(text, contains('Main'));
      expect(text, contains('TOKEN #118'));
      expect(text, contains('TOKEN #62'));
      expect(RegExp('TOKEN #62').allMatches(text), hasLength(1));
      expect(text, isNot(contains('Powered By')));
      expect(text, isNot(contains('SELFX POS')));
    },
  );

  test(
    'receipt printer appends production footer when server omits it',
    () async {
      final receipt = ReceiptPrintObject.fromResponse({
        'order': {'id': 88},
        'print_object': {
          'paper': '56mm',
          'print_object': [
            {'type': 'init'},
            {'type': 'text', 'text': 'Fixture Restaurant', 'align': 'center'},
            {'type': 'row', 'left': 'Total', 'right': 'Rs 120.00'},
            {'type': 'cut'},
          ],
        },
      });

      final bytes = await ReceiptPrinterService().buildEscPos(receipt);
      final text = String.fromCharCodes(bytes);

      expect(text, contains('THANK YOU FOR YOUR ORDER'));
      expect(text, contains('Powered By'));
      expect(text, contains('SELFX POS'));
      expect(
        text.indexOf('Rs 120.00'),
        lessThan(text.indexOf('THANK YOU FOR YOUR ORDER')),
      );
    },
  );

  test(
    'receipt printer keeps production footer once when commands include it',
    () async {
      final receipt = ReceiptPrintObject.fromResponse({
        'order': {'id': 88},
        'print_object': {
          'paper': '56mm',
          'print_object': [
            {'type': 'init'},
            {'type': 'text', 'text': 'Fixture Restaurant', 'align': 'center'},
            {'type': 'row', 'left': 'Total', 'right': 'Rs 120.00'},
            {
              'type': 'text',
              'text': 'THANK YOU FOR YOUR ORDER!',
              'align': 'center',
            },
            {'type': 'text', 'text': 'Powered By', 'align': 'center'},
            {'type': 'text', 'text': 'SELFX POS', 'align': 'center'},
            {'type': 'cut'},
          ],
        },
      });

      final bytes = await ReceiptPrinterService().buildEscPos(receipt);
      final text = String.fromCharCodes(bytes);

      expect(RegExp('THANK YOU FOR YOUR ORDER').allMatches(text), hasLength(1));
      expect(RegExp('Powered By').allMatches(text), hasLength(1));
      expect(RegExp('SELFX POS').allMatches(text), hasLength(1));
    },
  );

  test(
    'receipt printer drops redundant final cut after counter copy',
    () async {
      final receipt = ReceiptPrintObject.fromResponse({
        'order': {'id': 88},
        'print_object': {
          'paper': '58mm',
          'print_object': [
            {'type': 'init'},
            {'type': 'text', 'text': 'TOKEN #1', 'align': 'center'},
            {'type': 'text', 'text': 'Thank you for your order!'},
            {'type': 'cut', 'mode': 'partial'},
            {'type': 'text', 'text': 'COUNTER COPY', 'align': 'center'},
            {'type': 'feed', 'lines': 2},
            {'type': 'cut', 'mode': 'partial'},
            {'type': 'cut', 'mode': 'full'},
          ],
        },
      });

      final bytes = await ReceiptPrinterService().buildEscPos(receipt);
      final text = String.fromCharCodes(bytes);

      expect(text, contains('TOKEN #1'));
      expect(text, contains('COUNTER COPY'));
      expect(RegExp('\x1dV').allMatches(text), hasLength(2));
    },
  );

  test('printer config persists LAN receipt settings', () {
    final config = PrinterConfig.fromJson({
      'name': 'Counter receipt',
      'connection_type': 'lan',
      'host': '192.168.1.50',
      'port': 9100,
      'paper_width': '58mm',
      'enabled': true,
      'print_receipts': true,
    });

    expect(config.isLan, isTrue);
    expect(config.host, '192.168.1.50');
    expect(config.paperWidth, '58mm');
    expect(config.toJson()['paper_width'], '58mm');
    expect(config.toJson()['print_receipts'], isTrue);
  });

  test('printer config normalizes wide 88mm paper setting', () {
    final config = PrinterConfig.fromJson({
      'name': 'Wide receipt',
      'connection_type': 'lan',
      'host': '192.168.1.60',
      'paper_width': '88mm',
    });

    expect(config.paperWidth, '80mm');
    expect(config.toJson()['paper_width'], '80mm');
  });

  test('printer config persists USB and Bluetooth device identity', () {
    final usb = PrinterConfig.fromJson({
      'name': 'USB receipt',
      'connection_type': 'usb',
      'vendor_id': '1234',
      'product_id': '5678',
    });
    final bluetooth = PrinterConfig.fromJson({
      'name': 'BT receipt',
      'connection_type': 'bluetooth',
      'address': 'AA:BB:CC:DD',
    });

    expect(usb.isUsb, isTrue);
    expect(usb.hasDeviceIdentity, isTrue);
    expect(usb.toJson()['vendor_id'], '1234');
    expect(bluetooth.isBluetooth, isTrue);
    expect(bluetooth.hasDeviceIdentity, isTrue);
    expect(bluetooth.toJson()['address'], 'AA:BB:CC:DD');
  });
}

class _RetryingShiftApiService implements ShiftApiService {
  _RetryingShiftApiService()
    : _requestOptions = RequestOptions(path: '/pos/shift/close');

  final RequestOptions _requestOptions;
  final List<Map<String, dynamic>> closePayloads = [];

  @override
  Future<Map<String, dynamic>> close(Map<String, dynamic> payload) async {
    closePayloads.add(payload);
    if (closePayloads.length == 1) {
      throw DioException(
        requestOptions: _requestOptions,
        response: Response<Map<String, dynamic>>(
          requestOptions: _requestOptions,
          statusCode: 422,
          data: const {'message': 'The closing cash field must be a string.'},
        ),
      );
    }
    return const <String, dynamic>{'shift': null};
  }

  @override
  Future<Map<String, dynamic>> current() async => const <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> open(Map<String, dynamic> payload) async {
    return const <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> summary() async => const <String, dynamic>{};
}
