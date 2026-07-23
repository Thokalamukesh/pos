import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../domain/customer_display_models.dart';

final customerDisplayBoardRepositoryProvider =
    Provider<CustomerDisplayRepository>((ref) {
      return CustomerDisplayRepository(
        dio: ref.watch(dioProvider),
        storage: ref.watch(secureStorageServiceProvider),
      );
    });

class CustomerDisplayRepository {
  const CustomerDisplayRepository({
    required Dio dio,
    required SecureStorageService storage,
  }) : _dio = dio,
       _storage = storage;

  final Dio _dio;
  final SecureStorageService _storage;

  Future<CustomerDisplaySetup> readSetup() async {
    final values = await Future.wait<String?>([
      _storage.readString(StorageKeys.customerDisplaySlug),
      _storage.readString(StorageKeys.customerDisplayBranchId),
      _storage.readString(StorageKeys.customerDisplayTerminalCode),
      _storage.readString(StorageKeys.customerDisplaySyncToken),
    ]);
    final session = await _storage.readAuthSession();
    final terminal = await _storage.readTerminalContext();
    final restaurant = session?.currentRestaurant;
    final branch = session?.currentBranch;

    return CustomerDisplaySetup(
      restaurantName: _cleanName(restaurant?.name, fallback: 'Kumar Bistro'),
      restaurantSlug: _firstNonEmpty([
        values[0],
        restaurant?.slug,
        _slugFrom(restaurant?.name ?? 'Kumar Bistro'),
      ]),
      branchName: _cleanName(branch?.name, fallback: 'Kumar Bistro - Main'),
      branchId:
          int.tryParse(values[1] ?? '') ??
          terminal?.branchId ??
          branch?.id ??
          1,
      terminalCode: _firstNonEmpty([values[2], terminal?.terminalCode, 'T1']),
      syncToken: _firstNonEmpty([values[3], terminal?.syncToken, '']),
    );
  }

  Future<void> saveSetup({
    required String restaurantSlug,
    required int branchId,
    required String terminalCode,
    required String syncToken,
  }) async {
    await Future.wait([
      _storage.writeString(
        StorageKeys.customerDisplaySlug,
        _slugFrom(restaurantSlug),
      ),
      _storage.writeString(
        StorageKeys.customerDisplayBranchId,
        branchId.toString(),
      ),
      _storage.writeString(
        StorageKeys.customerDisplayTerminalCode,
        terminalCode.trim().isEmpty ? 'T1' : terminalCode.trim(),
      ),
      _storage.writeString(
        StorageKeys.customerDisplaySyncToken,
        syncToken.trim(),
      ),
    ]);
  }

  Future<CustomerBoardSnapshot> pollBoard({
    required String restaurantSlug,
    required int branchId,
    required String terminalCode,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${AppConfig.apiPrefix}/display/$branchId/'
        '${Uri.encodeComponent(terminalCode)}/bootstrap',
      );
      return CustomerBoardSnapshot.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status != 401 && status != 403 && status != 404 && status != 405) {
        throw AppException.fromDio(error);
      }
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${AppConfig.apiPrefix}/pos/recent-orders',
      );
      return CustomerBoardSnapshot.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status != 401 && status != 403 && status != 404 && status != 405) {
        throw AppException.fromDio(error);
      }
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${AppConfig.apiPrefix}/board/orders',
      );
      return CustomerBoardSnapshot.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status != 401 && status != 403 && status != 404) {
        throw AppException.fromDio(error);
      }
    }

    try {
      final path =
          '${AppConfig.apiPrefix}/public/'
          '${Uri.encodeComponent(_slugFrom(restaurantSlug))}'
          '/board/$branchId/poll';
      final response = await _dio.get<Map<String, dynamic>>(
        AppConfig.urlFrom(AppConfig.publicBaseUrl, path),
        options: Options(extra: const {'skipAuth': true}),
      );
      return CustomerBoardSnapshot.fromJson(response.data ?? const {});
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }
}

String _cleanName(String? value, {required String fallback}) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return '';
}

String _slugFrom(String value) {
  final slug = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return slug.isEmpty ? 'kumar-bistro' : slug;
}
