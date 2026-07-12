import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../models/pairing_models.dart';

final pairingApiServiceProvider = Provider<PairingApiService>((ref) {
  return PairingApiService(ref.watch(dioProvider));
});

class PairingApiService {
  PairingApiService(this._dio);

  final Dio _dio;

  Future<PairingStartResponse> startPairing({
    required String platform,
    required String appVersion,
    required String deviceName,
    required String deviceUuid,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/pos/pairing/start',
      data: {
        'platform': platform,
        'app_version': appVersion,
        'device_name': deviceName,
        'device_uuid': deviceUuid,
      },
      options: Options(
        extra: {'skipAuth': true},
        headers: {'X-Pos-Platform': platform, 'X-Pos-App-Version': appVersion},
      ),
    );
    return PairingStartResponse.fromJson(unwrapDataMap(response.data));
  }

  Future<PairingStatusResponse> getStatus(String deviceUuid) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/pos/pairing/status',
      queryParameters: {'device_uuid': deviceUuid},
      options: Options(extra: {'skipAuth': true}),
    );
    return PairingStatusResponse.fromJson(unwrapDataMap(response.data));
  }
}
