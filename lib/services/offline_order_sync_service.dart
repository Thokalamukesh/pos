import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/offline_order_repository.dart';

final offlineOrderSyncServiceProvider = Provider<OfflineOrderSyncService>((
  ref,
) {
  final service = OfflineOrderSyncService(
    repository: ref.watch(offlineOrderRepositoryProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

class OfflineOrderSyncService {
  OfflineOrderSyncService({required OfflineOrderRepository repository})
    : _repository = repository;

  final OfflineOrderRepository _repository;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _syncing = false;

  void start() {
    if (_subscription != null) {
      return;
    }
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      if (_hasNetwork(results)) {
        unawaited(syncNow());
      }
    });
    unawaited(_syncIfOnline());
  }

  Future<OfflineOrderSyncResult> syncNow() async {
    if (_syncing) {
      return const OfflineOrderSyncResult(synced: 0, failed: 0);
    }
    _syncing = true;
    try {
      final pending = await _repository.pendingCount();
      if (pending == 0) {
        return const OfflineOrderSyncResult(synced: 0, failed: 0);
      }
      debugPrint('[OFFLINE_SYNC] syncing pending=$pending');
      return await _repository.syncPending();
    } finally {
      _syncing = false;
    }
  }

  Future<void> _syncIfOnline() async {
    final results = await Connectivity().checkConnectivity();
    if (_hasNetwork(results)) {
      await syncNow();
    }
  }

  void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }

  static bool _hasNetwork(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
