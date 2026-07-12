import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_exception.dart';
import '../services/customer_display_api_service.dart';

final customerDisplayRepositoryProvider = Provider<CustomerDisplayRepository>((
  ref,
) {
  return CustomerDisplayRepository(
    api: ref.watch(customerDisplayApiServiceProvider),
  );
});

class CustomerDisplayRepository {
  CustomerDisplayRepository({required CustomerDisplayApiService api})
    : _api = api;

  final CustomerDisplayApiService _api;

  Future<void> syncCart({
    required int branchId,
    required String terminalCode,
    required String terminalToken,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await _api.sync(
        branchId: branchId,
        terminalCode: terminalCode,
        terminalToken: terminalToken,
        payload: payload,
      );
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<void> clearCart({
    required int branchId,
    required String terminalCode,
    required String terminalToken,
  }) async {
    try {
      await _api.clear(
        branchId: branchId,
        terminalCode: terminalCode,
        terminalToken: terminalToken,
      );
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }
}
