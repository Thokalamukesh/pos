import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../models/order_models.dart';

final posOrderApiServiceProvider = Provider<PosOrderApiService>((ref) {
  return PosOrderApiService(ref.watch(dioProvider));
});

class PosOrderApiService {
  PosOrderApiService(this._dio);

  final Dio _dio;

  Future<PosOrderResult> createOrder(CreatePosOrderRequest request) async {
    return createOrderFromPayload(request.toJson());
  }

  Future<PosOrderResult> createOrderFromPayload(
    Map<String, dynamic> payload,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/pos/orders',
      data: payload,
    );
    return PosOrderResult.fromResponse(unwrapDataMap(response.data));
  }

  Future<ReceiptPrintObject> fetchReceipt(int orderId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/pos/orders/$orderId/receipt',
    );
    return ReceiptPrintObject.fromResponse(unwrapDataMap(response.data));
  }

  Future<PosOrderPaymentResult> payOrder(int orderId, {String? method}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/pos/orders/$orderId/pay',
      data: method == null
          ? null
          : <String, dynamic>{
              'pos_register_payment': <String, dynamic>{'method': method},
            },
    );
    return PosOrderPaymentResult.fromResponse(unwrapDataMap(response.data));
  }

  Future<PosOrderPaymentResult> payOrderDynamicQr(int orderId) async {
    final payloads = <Map<String, dynamic>?>[
      const {
        'pos_register_payment': {'method': 'phonepe'},
      },
      const {
        'pos_register_payment': {'method': 'phonepe'},
        'gateway': 'phonepe',
      },
      const {
        'pos_register_payment': {'method': 'upi'},
      },
      const {'method': 'phonepe'},
      const {'payment_method': 'phonepe'},
      const {'gateway': 'phonepe'},
    ];
    DioException? lastValidationError;
    for (final payload in payloads) {
      try {
        debugPrint(
          '[UPI_QR][API] POST /pos/orders/$orderId/pay payload=$payload',
        );
        final response = await _dio.post<Map<String, dynamic>>(
          '${AppConfig.apiPrefix}/pos/orders/$orderId/pay',
          data: payload,
        );
        final data = unwrapDataMap(response.data);
        final result = PosOrderPaymentResult.fromResponse(data);
        debugPrint(
          '[UPI_QR][API] pay success status=${response.statusCode} '
          'keys=${data.keys.toList()} gateway=${result.gateway} '
          'paymentStatus=${result.paymentStatus} qrLen=${result.qrText?.length ?? 0} '
          'upi=${result.qrText?.startsWith('upi://') ?? false}',
        );
        return result;
      } on DioException catch (error) {
        final statusCode = error.response?.statusCode;
        debugPrint(
          '[UPI_QR][API] pay failed status=$statusCode payload=$payload '
          'body=${error.response?.data}',
        );
        if (statusCode != 400 && statusCode != 422) {
          rethrow;
        }
        lastValidationError = error;
      }
    }
    throw lastValidationError!;
  }

  Future<PosOrderPaymentResult> fetchPaymentQr(
    int orderId, {
    String? gateway,
  }) async {
    debugPrint(
      '[UPI_QR][API] GET /pos/orders/$orderId/payment/qr gateway=$gateway',
    );
    final response = await _dio.get<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/pos/orders/$orderId/payment/qr',
      queryParameters: {
        if (gateway != null && gateway.trim().isNotEmpty)
          'gateway': gateway.trim(),
      },
    );
    final data = unwrapDataMap(response.data);
    final result = PosOrderPaymentResult.fromResponse(data);
    debugPrint(
      '[UPI_QR][API] fetch QR success status=${response.statusCode} '
      'keys=${data.keys.toList()} gateway=${result.gateway} '
      'qrLen=${result.qrText?.length ?? 0} '
      'upi=${result.qrText?.startsWith('upi://') ?? false}',
    );
    return result;
  }

  Future<PosOrderPaymentResult> fetchPaymentStatus(int orderId) async {
    try {
      debugPrint('[UPI_QR][API] GET /pos/orders/$orderId/payment/status');
      final response = await _dio.get<Map<String, dynamic>>(
        '${AppConfig.apiPrefix}/pos/orders/$orderId/payment/status',
      );
      final data = unwrapDataMap(response.data);
      final result = PosOrderPaymentResult.fromResponse(data);
      debugPrint(
        '[UPI_QR][API] payment status success status=${response.statusCode} '
        'keys=${data.keys.toList()} paymentStatus=${result.paymentStatus}',
      );
      return result;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      debugPrint(
        '[UPI_QR][API] payment status failed status=$statusCode '
        'body=${error.response?.data}',
      );
      if (statusCode != 404 && statusCode != 405) {
        rethrow;
      }
    }

    try {
      debugPrint('[UPI_QR][API] fallback GET /pos/orders/$orderId/pay');
      final response = await _dio.get<Map<String, dynamic>>(
        '${AppConfig.apiPrefix}/pos/orders/$orderId/pay',
      );
      final data = unwrapDataMap(response.data);
      final result = PosOrderPaymentResult.fromResponse(data);
      debugPrint(
        '[UPI_QR][API] fallback pay status success '
        'paymentStatus=${result.paymentStatus}',
      );
      return result;
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      debugPrint(
        '[UPI_QR][API] fallback pay status failed status=$statusCode '
        'body=${error.response?.data}',
      );
      if (statusCode != 404 && statusCode != 405) {
        rethrow;
      }
    }

    debugPrint('[UPI_QR][API] fallback GET /pos/orders/$orderId');
    final response = await _dio.get<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/pos/orders/$orderId',
    );
    final data = unwrapDataMap(response.data);
    final result = PosOrderPaymentResult.fromResponse(data);
    debugPrint(
      '[UPI_QR][API] fallback order status success '
      'paymentStatus=${result.paymentStatus}',
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchOpenOrders() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/pos/open-orders',
    );
    final data = unwrapDataMap(response.data);
    final value = data['orders'] ?? data['data'] ?? data['items'];
    if (value is! List) {
      return const <Map<String, dynamic>>[];
    }
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<PosDailyReport> fetchDailyReport() async {
    final queryParameters = _todayReportQueryParameters();
    final paths = const [
      '/pos/recent-orders',
      '/pos/reports/daily',
      '/pos/reports/today',
      '/pos/daily-report',
    ];
    DioException? lastRouteError;
    for (final path in paths) {
      try {
        final response = await _dio.get<Map<String, dynamic>>(
          '${AppConfig.apiPrefix}$path',
          queryParameters: queryParameters,
        );
        return _filterDailyReportForDate(
          PosDailyReport.fromResponse(unwrapDataMap(response.data)),
          DateTime.now(),
        );
      } on DioException catch (error) {
        final status = error.response?.statusCode;
        if (status != 404 && status != 405) {
          rethrow;
        }
        lastRouteError = error;
      }
    }
    throw lastRouteError!;
  }

  Future<ReceiptPrintObject> fetchDailyReportPrintObject({
    String type = 'consolidated',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/pos/reports/thermal-print',
      queryParameters: _todayReportQueryParameters(type: type),
    );
    return ReceiptPrintObject.fromResponse(unwrapDataMap(response.data));
  }
}

Map<String, dynamic> _todayReportQueryParameters({String? type}) {
  final today = _yyyyMmDd(DateTime.now());
  return <String, dynamic>{
    if (type != null) 'type': type,
    'date_from': today,
    'date_to': today,
  };
}

String _yyyyMmDd(DateTime value) {
  final local = value.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

PosDailyReport _filterDailyReportForDate(PosDailyReport report, DateTime date) {
  final filteredOrders = report.recentOrders.where((order) {
    final createdAt = order.createdAt;
    return createdAt == null || _isSameLocalDate(createdAt, date);
  }).toList();
  if (filteredOrders.length == report.recentOrders.length) {
    return report;
  }
  return PosDailyReport(
    raw: report.raw,
    summary: report.summary,
    recentOrders: filteredOrders,
  );
}

bool _isSameLocalDate(DateTime first, DateTime second) {
  final a = first.toLocal();
  final b = second.toLocal();
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
