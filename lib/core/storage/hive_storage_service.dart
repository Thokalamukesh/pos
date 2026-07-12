import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final hiveStorageServiceProvider = Provider<HiveStorageService>((ref) {
  return HiveStorageService();
});

class HiveStorageService {
  static const cacheBoxName = 'selfx_cache';

  Box<String> get _box => Hive.box<String>(cacheBoxName);

  Future<void> putJson(String key, Map<String, dynamic> json) {
    return _box.put(key, jsonEncode(json));
  }

  Map<String, dynamic>? getJson(String key) {
    final raw = _box.get(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on Object {
      _box.delete(key);
      return null;
    }
  }

  Future<void> delete(String key) => _box.delete(key);

  String scopedKey({
    required String prefix,
    required int restaurantId,
    required int branchId,
    String? terminalCode,
  }) {
    final terminal = terminalCode == null ? '' : ':$terminalCode';
    return '$prefix:$restaurantId:$branchId$terminal';
  }
}
