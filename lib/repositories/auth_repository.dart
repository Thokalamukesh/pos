import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_exception.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/auth_models.dart';
import '../services/auth_api_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.watch(authApiServiceProvider),
    storage: ref.watch(secureStorageServiceProvider),
  );
});

class AuthRepository {
  AuthRepository({
    required AuthApiService api,
    required SecureStorageService storage,
  }) : _api = api,
       _storage = storage;

  final AuthApiService _api;
  final SecureStorageService _storage;

  Future<AuthSession?> restoreSession() => _storage.readAuthSession();

  Future<AuthSession> login({
    required String email,
    required String password,
    int? restaurantId,
    int? branchId,
  }) async {
    try {
      final deviceUuid = await _storage.readOrCreateDeviceUuid();
      final session = await _api.login(
        email: email,
        password: password,
        deviceName: 'SELFX POS $deviceUuid',
        deviceUuid: deviceUuid,
        restaurantId: restaurantId,
        branchId: branchId,
      );
      await _storage.saveAuthSession(session);
      return session;
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } on DioException {
      // Local logout must still clear secrets if token is expired or offline.
    } finally {
      await _storage.clearAuth();
      await _storage.clearTerminalContext();
    }
  }

  Future<bool> verifyPosPin(String pin) async {
    try {
      return await _api.verifyPosPin(pin);
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }
}
