import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';

final posMenuApiServiceProvider = Provider<PosMenuApiService>((ref) {
  return PosMenuApiService(ref.watch(dioProvider));
});

class PosMenuApiService {
  PosMenuApiService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> fetchMenu() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/pos/menu',
    );
    return unwrapDataMap(response.data);
  }
}
