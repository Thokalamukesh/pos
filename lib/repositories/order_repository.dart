import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_exception.dart';
import '../models/order_models.dart';
import '../services/order_api_service.dart';

final posOrderRepositoryProvider = Provider<PosOrderRepository>((ref) {
  return PosOrderRepository(api: ref.watch(posOrderApiServiceProvider));
});

class PosOrderRepository {
  PosOrderRepository({required PosOrderApiService api}) : _api = api;

  final PosOrderApiService _api;

  Future<PosOrderResult> createOrder(CreatePosOrderRequest request) async {
    try {
      return await _api.createOrder(request);
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<PosOrderResult> parkOrder(CreatePosOrderRequest request) async {
    try {
      return await _api.parkOrder(request);
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> fetchOrder(int orderId) async {
    try {
      return await _api.fetchOrder(orderId);
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<ReceiptPrintObject> fetchReceipt(int orderId) async {
    try {
      return await _api.fetchReceipt(orderId);
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<PosOrderPaymentResult> payOrder(
    int orderId, {
    String? method,
    PosRegisterPayment? payment,
  }) async {
    try {
      return await _api.payOrder(orderId, method: method, payment: payment);
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<PosOrderPaymentResult> payOrderDynamicQr(int orderId) async {
    try {
      return await _api.payOrderDynamicQr(orderId);
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<PosOrderPaymentResult> fetchPaymentQr(
    int orderId, {
    String? gateway,
  }) async {
    try {
      return await _api.fetchPaymentQr(orderId, gateway: gateway);
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<PosOrderPaymentResult> fetchPaymentStatus(int orderId) async {
    try {
      return await _api.fetchPaymentStatus(orderId);
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<List<Map<String, dynamic>>> fetchOpenOrders() async {
    try {
      return await _api.fetchOpenOrders();
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<List<Map<String, dynamic>>> fetchRecentOrders({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      return await _api.fetchRecentOrders(dateFrom: dateFrom, dateTo: dateTo);
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<PosDailyReport> fetchDailyReport() async {
    try {
      return await _api.fetchDailyReport();
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<ReceiptPrintObject> fetchDailyReportPrintObject({
    String type = 'consolidated',
  }) async {
    try {
      return await _api.fetchDailyReportPrintObject(type: type);
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }
}
