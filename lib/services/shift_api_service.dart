import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';

final shiftApiServiceProvider = Provider<ShiftApiService>((ref) {
  return ShiftApiService(ref.watch(dioProvider));
});

class ShiftApiService {
  ShiftApiService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> current() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/pos/shift/current',
    );
    return unwrapDataMap(response.data);
  }

  Future<Map<String, dynamic>> summary() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${AppConfig.apiPrefix}/pos/shift/summary',
      );
      return _unwrapSummary(response.data);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status != 404 && status != 405) {
        rethrow;
      }
    }
    final response = await _dio.post<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/pos/shift/summary',
    );
    return _unwrapSummary(response.data);
  }

  Future<Map<String, dynamic>> open(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/pos/shift/open',
      data: payload,
    );
    return unwrapDataMap(response.data);
  }

  Future<Map<String, dynamic>> close(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/pos/shift/close',
      data: payload,
    );
    return unwrapDataMap(response.data);
  }
}

Map<String, dynamic> _unwrapSummary(Object? responseData) {
  final data = unwrapDataMap(responseData);
  final summary = data['summary'];
  if (summary is Map) {
    return Map<String, dynamic>.from(summary);
  }
  return data;
}
