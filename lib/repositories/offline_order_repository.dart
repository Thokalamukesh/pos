import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/hive_storage_service.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/order_models.dart';
import '../services/order_api_service.dart';

final offlineOrderRepositoryProvider = Provider<OfflineOrderRepository>((ref) {
  return OfflineOrderRepository(
    hive: ref.watch(hiveStorageServiceProvider),
    secureStorage: ref.watch(secureStorageServiceProvider),
    api: ref.watch(posOrderApiServiceProvider),
  );
});

class OfflineOrderRepository {
  OfflineOrderRepository({
    required HiveStorageService hive,
    required SecureStorageService secureStorage,
    required PosOrderApiService api,
  }) : _hive = hive,
       _secureStorage = secureStorage,
       _api = api;

  final HiveStorageService _hive;
  final SecureStorageService _secureStorage;
  final PosOrderApiService _api;

  Future<OfflineQueuedOrder> enqueue({
    required CreatePosOrderRequest request,
    required String paymentMethod,
    required double total,
  }) async {
    final orders = await _readAll();
    final createdAt = DateTime.now().toUtc();
    final order = OfflineQueuedOrder(
      localId: _localId(request.posTerminalCode, createdAt),
      createdAt: createdAt,
      request: request.toJson(),
      paymentMethod: paymentMethod,
      total: total,
      status: OfflineOrderStatus.pending,
    );
    orders.add(order);
    await _writeAll(orders);
    return order;
  }

  Future<List<OfflineQueuedOrder>> pendingOrders() async {
    final orders = await _readAll();
    return orders
        .where((order) => order.status == OfflineOrderStatus.pending)
        .toList(growable: false);
  }

  Future<int> pendingCount() async {
    return (await pendingOrders()).length;
  }

  Future<OfflineOrderSyncResult> syncPending() async {
    final orders = await _readAll();
    var synced = 0;
    var failed = 0;
    var changed = false;

    for (var index = 0; index < orders.length; index += 1) {
      final order = orders[index];
      if (order.status != OfflineOrderStatus.pending) {
        continue;
      }

      try {
        final result = await _api.createOrderFromPayload(order.request);
        orders[index] = order.synced(
          serverOrderId: result.id,
          serverOrderNumber: result.displayNumber,
        );
        synced += 1;
        changed = true;
      } on DioException catch (error) {
        final statusCode = error.response?.statusCode;
        final message = _errorMessage(error);
        final shouldRetry = statusCode == null || statusCode >= 500;
        orders[index] = order.failedAttempt(
          message: message,
          terminal: shouldRetry
              ? OfflineOrderStatus.pending
              : OfflineOrderStatus.failed,
        );
        failed += 1;
        changed = true;
        if (shouldRetry) {
          break;
        }
      } on Object catch (error) {
        orders[index] = order.failedAttempt(
          message: error.toString(),
          terminal: OfflineOrderStatus.pending,
        );
        failed += 1;
        changed = true;
        break;
      }
    }

    if (changed) {
      await _writeAll(orders);
    }
    if (synced > 0 || failed > 0) {
      debugPrint('[OFFLINE_SYNC] synced=$synced failed=$failed');
    }
    return OfflineOrderSyncResult(synced: synced, failed: failed);
  }

  Future<List<OfflineQueuedOrder>> _readAll() async {
    final cached = _hive.getJson(await _storageKey());
    final items = cached?['orders'];
    if (items is! List) {
      return <OfflineQueuedOrder>[];
    }
    return items
        .whereType<Map>()
        .map(
          (item) =>
              OfflineQueuedOrder.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<void> _writeAll(List<OfflineQueuedOrder> orders) async {
    await _hive.putJson(await _storageKey(), {
      'orders': orders.map((order) => order.toJson()).toList(),
    });
  }

  Future<String> _storageKey() async {
    final session = await _secureStorage.readAuthSession();
    final restaurantId = session?.currentRestaurant?.id;
    final branchId = session?.currentBranch?.id;
    if (restaurantId == null || branchId == null) {
      return 'offline_orders:global';
    }
    return _hive.scopedKey(
      prefix: 'offline_orders',
      restaurantId: restaurantId,
      branchId: branchId,
    );
  }

  static String _localId(String terminalCode, DateTime createdAt) {
    return 'OFF-$terminalCode-${createdAt.microsecondsSinceEpoch}';
  }

  static String _errorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return error.message ?? 'Sync failed.';
  }
}

enum OfflineOrderStatus { pending, synced, failed }

class OfflineQueuedOrder {
  const OfflineQueuedOrder({
    required this.localId,
    required this.createdAt,
    required this.request,
    required this.paymentMethod,
    required this.total,
    required this.status,
    this.attempts = 0,
    this.lastError,
    this.syncedAt,
    this.serverOrderId,
    this.serverOrderNumber,
  });

  final String localId;
  final DateTime createdAt;
  final Map<String, dynamic> request;
  final String paymentMethod;
  final double total;
  final OfflineOrderStatus status;
  final int attempts;
  final String? lastError;
  final DateTime? syncedAt;
  final int? serverOrderId;
  final String? serverOrderNumber;

  factory OfflineQueuedOrder.fromJson(Map<String, dynamic> json) {
    return OfflineQueuedOrder(
      localId: json['local_id']?.toString() ?? 'OFF-unknown',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      request: Map<String, dynamic>.from(json['request'] as Map? ?? const {}),
      paymentMethod: json['payment_method']?.toString() ?? 'cash',
      total: _doubleValue(json['total']),
      status: _statusValue(json['status']),
      attempts: _intValue(json['attempts']),
      lastError: json['last_error']?.toString(),
      syncedAt: DateTime.tryParse(json['synced_at']?.toString() ?? ''),
      serverOrderId: _nullableIntValue(json['server_order_id']),
      serverOrderNumber: json['server_order_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'local_id': localId,
      'created_at': createdAt.toIso8601String(),
      'request': request,
      'payment_method': paymentMethod,
      'total': total,
      'status': status.name,
      'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (syncedAt != null) 'synced_at': syncedAt!.toIso8601String(),
      if (serverOrderId != null) 'server_order_id': serverOrderId,
      if (serverOrderNumber != null) 'server_order_number': serverOrderNumber,
    };
  }

  OfflineQueuedOrder synced({int? serverOrderId, String? serverOrderNumber}) {
    return OfflineQueuedOrder(
      localId: localId,
      createdAt: createdAt,
      request: request,
      paymentMethod: paymentMethod,
      total: total,
      status: OfflineOrderStatus.synced,
      attempts: attempts + 1,
      syncedAt: DateTime.now().toUtc(),
      serverOrderId: serverOrderId,
      serverOrderNumber: serverOrderNumber,
    );
  }

  OfflineQueuedOrder failedAttempt({
    required String message,
    required OfflineOrderStatus terminal,
  }) {
    return OfflineQueuedOrder(
      localId: localId,
      createdAt: createdAt,
      request: request,
      paymentMethod: paymentMethod,
      total: total,
      status: terminal,
      attempts: attempts + 1,
      lastError: message,
      syncedAt: syncedAt,
      serverOrderId: serverOrderId,
      serverOrderNumber: serverOrderNumber,
    );
  }

  static OfflineOrderStatus _statusValue(Object? value) {
    final source = value?.toString();
    return OfflineOrderStatus.values.firstWhere(
      (status) => status.name == source,
      orElse: () => OfflineOrderStatus.pending,
    );
  }

  static double _doubleValue(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _intValue(Object? value) => _nullableIntValue(value) ?? 0;

  static int? _nullableIntValue(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }
}

class OfflineOrderSyncResult {
  const OfflineOrderSyncResult({required this.synced, required this.failed});

  final int synced;
  final int failed;
}
