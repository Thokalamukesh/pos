import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../models/auth_models.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(ref.watch(dioProvider));
});

class AuthApiService {
  AuthApiService(this._dio);

  final Dio _dio;

  Future<AuthSession> login({
    required String email,
    required String password,
    required String deviceName,
    required String deviceUuid,
    int? restaurantId,
    int? branchId,
  }) async {
    final payload = <String, dynamic>{
      'email': email,
      'password': password,
      'device_name': deviceName,
      'device_uuid': deviceUuid,
      'token_ability': 'pos',
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (branchId != null) 'branch_id': branchId,
    };

    final response = await _dio.post<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/auth/login',
      data: payload,
      options: Options(extra: {'skipAuth': true}),
    );

    return AuthSession.fromJson(unwrapDataMap(response.data));
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/auth/me',
    );
    return unwrapDataMap(response.data);
  }

  Future<void> logout() async {
    await _dio.post<Map<String, dynamic>>('${AppConfig.apiPrefix}/auth/logout');
  }

  Future<Map<String, dynamic>> switchRestaurant(int restaurantId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/auth/switch-restaurant',
      data: {'restaurant_id': restaurantId},
    );
    return unwrapDataMap(response.data);
  }

  Future<Map<String, dynamic>> switchBranch(int branchId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/auth/switch-branch',
      data: {'branch_id': branchId},
    );
    return unwrapDataMap(response.data);
  }

  Future<bool> verifyPosPin(String pin) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '${AppConfig.apiPrefix}/auth/verify-pos-pin',
      data: {'pin': pin},
    );
    final data = unwrapDataMap(response.data);
    return data['verified'] == true;
  }
}
