import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';

final customerDisplayApiServiceProvider = Provider<CustomerDisplayApiService>((
  ref,
) {
  return CustomerDisplayApiService(ref.watch(dioProvider));
});

class CustomerDisplayApiService {
  CustomerDisplayApiService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> sync({
    required int branchId,
    required String terminalCode,
    required String terminalToken,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _syncPath(branchId, terminalCode),
      data: payload,
      options: Options(headers: {'X-Terminal-Token': terminalToken}),
    );
    return unwrapDataMap(response.data);
  }

  Future<void> clear({
    required int branchId,
    required String terminalCode,
    required String terminalToken,
  }) async {
    await _dio.delete<Map<String, dynamic>>(
      _syncPath(branchId, terminalCode),
      options: Options(headers: {'X-Terminal-Token': terminalToken}),
    );
  }

  String _syncPath(int branchId, String terminalCode) {
    return '${AppConfig.apiPrefix}/displays/sync/$branchId/'
        '${Uri.encodeComponent(terminalCode)}';
  }
}
