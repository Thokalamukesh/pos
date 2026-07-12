import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_exception.dart';
import '../core/storage/hive_storage_service.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/pos_bootstrap.dart';
import '../services/bootstrap_api_service.dart';

final bootstrapRepositoryProvider = Provider<BootstrapRepository>((ref) {
  return BootstrapRepository(
    api: ref.watch(bootstrapApiServiceProvider),
    secureStorage: ref.watch(secureStorageServiceProvider),
    hive: ref.watch(hiveStorageServiceProvider),
  );
});

class BootstrapRepository {
  BootstrapRepository({
    required BootstrapApiService api,
    required SecureStorageService secureStorage,
    required HiveStorageService hive,
  }) : _api = api,
       _secureStorage = secureStorage,
       _hive = hive;

  final BootstrapApiService _api;
  final SecureStorageService _secureStorage;
  final HiveStorageService _hive;

  Future<PosBootstrap> loadBootstrap({bool allowCache = true}) async {
    try {
      final bootstrap = await _api.fetchBootstrap();
      final session = await _secureStorage.readAuthSession();
      final restaurantId = session?.currentRestaurant?.id;
      final branchId = session?.currentBranch?.id;
      if (restaurantId != null && branchId != null) {
        await _hive.putJson(
          _hive.scopedKey(
            prefix: 'bootstrap',
            restaurantId: restaurantId,
            branchId: branchId,
          ),
          bootstrap.toJson(),
        );
      }
      return bootstrap;
    } on DioException catch (error) {
      if (allowCache) {
        final cached = await cachedBootstrap();
        if (cached != null) {
          return cached;
        }
      }
      throw AppException.fromDio(error);
    }
  }

  Future<PosBootstrap?> cachedBootstrap() async {
    final session = await _secureStorage.readAuthSession();
    final restaurantId = session?.currentRestaurant?.id;
    final branchId = session?.currentBranch?.id;
    if (restaurantId == null || branchId == null) {
      return null;
    }
    final cached = _hive.getJson(
      _hive.scopedKey(
        prefix: 'bootstrap',
        restaurantId: restaurantId,
        branchId: branchId,
      ),
    );
    return cached == null ? null : PosBootstrap.fromJson(cached);
  }
}
