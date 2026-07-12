import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/errors/app_exception.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/pairing_models.dart';
import '../services/pairing_api_service.dart';

final pairingRepositoryProvider = Provider<PairingRepository>((ref) {
  return PairingRepository(
    api: ref.watch(pairingApiServiceProvider),
    storage: ref.watch(secureStorageServiceProvider),
  );
});

class PairingRepository {
  PairingRepository({
    required PairingApiService api,
    required SecureStorageService storage,
  }) : _api = api,
       _storage = storage;

  final PairingApiService _api;
  final SecureStorageService _storage;

  Future<PairingStartResponse> start({
    String deviceName = 'SELFX POS device',
  }) async {
    await _storage.clearPairedDevice();
    try {
      final deviceUuid = await _storage.readOrCreateDeviceUuid();
      final response = await _api.startPairing(
        platform: AppConfig.platformHeaderValue,
        appVersion: AppConfig.appVersion,
        deviceName: deviceName,
        deviceUuid: deviceUuid,
      );
      await _storage.saveDeviceUuid(response.deviceUuid);
      return response;
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<PairingStatusResponse> poll(String deviceUuid) async {
    try {
      final status = await _api.getStatus(deviceUuid);
      if (_isPaired(status) &&
          status.branchId != null &&
          status.posTerminal != null) {
        await _storage.savePairedDevice(
          PairedDevice(
            deviceUuid: status.deviceUuid ?? deviceUuid,
            restaurantId: status.restaurantId ?? 0,
            restaurantName: status.restaurantName ?? 'Restaurant',
            branchId: status.branchId!,
            branchName: status.branchName ?? 'Branch ${status.branchId}',
            terminal: status.posTerminal!,
            pairedAt: DateTime.now().toUtc(),
          ),
        );
      }
      return status;
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<void> clearLocalPairing({bool clearDeviceUuid = false}) {
    return _storage.clearPairedDevice(clearDeviceUuid: clearDeviceUuid);
  }

  Future<PairedDevice?> restorePairedDevice() => _storage.readPairedDevice();
}

bool _isPaired(PairingStatusResponse status) {
  final value = status.status.trim().toLowerCase();
  return value == 'paired' || value == 'complete' || value == 'completed';
}
