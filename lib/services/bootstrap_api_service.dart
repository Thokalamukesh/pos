import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../models/pos_bootstrap.dart';

final bootstrapApiServiceProvider = Provider<BootstrapApiService>((ref) {
  return BootstrapApiService(ref.watch(dioProvider));
});

class BootstrapApiService {
  BootstrapApiService(this._dio);

  final Dio _dio;

  Future<PosBootstrap> fetchBootstrap() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/pos/bootstrap',
    );
    return PosBootstrap.fromJson(unwrapDataMap(response.data));
  }
}
