import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: kIsWeb ? null : const Duration(seconds: 30),
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    SelfxAuthInterceptor(ref.watch(secureStorageServiceProvider)),
  );
  return dio;
});

class SelfxAuthInterceptor extends QueuedInterceptor {
  SelfxAuthInterceptor(this._storage);

  final SecureStorageService _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.putIfAbsent('Accept', () => 'application/json');

    if (options.data != null) {
      options.headers.putIfAbsent('Content-Type', () => 'application/json');
    }

    if (options.extra['skipAuth'] == true) {
      handler.next(options);
      return;
    }

    final session = await _storage.readAuthSession();
    final restaurantId = session?.currentRestaurant?.id;
    final branchId = session?.currentBranch?.id;

    if (session?.token.isNotEmpty == true) {
      options.headers.putIfAbsent(
        'Authorization',
        () => 'Bearer ${session!.token}',
      );
    }
    if (restaurantId != null) {
      options.headers.putIfAbsent('X-Restaurant-Id', () => restaurantId);
    }
    if (branchId != null) {
      options.headers.putIfAbsent('X-Branch-Id', () => branchId);
    }

    handler.next(options);
  }
}
