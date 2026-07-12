import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../../models/auth_models.dart';
import '../../models/pairing_models.dart';
import '../../models/pos_terminal.dart';
import '../../models/printer_config.dart';
import 'storage_keys.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage, Uuid? uuid})
    : _storage = storage ?? const FlutterSecureStorage(),
      _uuid = uuid ?? const Uuid();

  final FlutterSecureStorage _storage;
  final Uuid _uuid;

  Future<String> readOrCreateDeviceUuid() async {
    final existing = await _storage.read(key: StorageKeys.deviceUuid);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final created = _uuid.v4();
    await _storage.write(key: StorageKeys.deviceUuid, value: created);
    return created;
  }

  Future<void> saveDeviceUuid(String deviceUuid) {
    return _storage.write(key: StorageKeys.deviceUuid, value: deviceUuid);
  }

  Future<String?> readString(String key) {
    return _storage.read(key: key);
  }

  Future<void> writeString(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  Future<void> deleteString(String key) {
    return _storage.delete(key: key);
  }

  Future<AuthSession?> readAuthSession() async {
    return _readJson(StorageKeys.authSession, AuthSession.fromJson);
  }

  Future<void> saveAuthSession(AuthSession session) {
    return _writeJson(StorageKeys.authSession, session.toJson());
  }

  Future<PairedDevice?> readPairedDevice() async {
    return _readJson(StorageKeys.pairedDevice, PairedDevice.fromJson);
  }

  Future<void> savePairedDevice(PairedDevice pairedDevice) async {
    await saveDeviceUuid(pairedDevice.deviceUuid);
    await _writeJson(StorageKeys.pairedDevice, pairedDevice.toJson());
  }

  Future<void> clearPairedDevice({bool clearDeviceUuid = false}) async {
    await _storage.delete(key: StorageKeys.pairedDevice);
    await _storage.delete(key: StorageKeys.terminalContext);
    if (clearDeviceUuid) {
      await _storage.delete(key: StorageKeys.deviceUuid);
    }
  }

  Future<TerminalContext?> readTerminalContext() async {
    return _readJson(StorageKeys.terminalContext, TerminalContext.fromJson);
  }

  Future<void> saveTerminalContext(TerminalContext terminalContext) {
    return _writeJson(StorageKeys.terminalContext, terminalContext.toJson());
  }

  Future<void> clearTerminalContext() {
    return _storage.delete(key: StorageKeys.terminalContext);
  }

  Future<PrinterConfig?> readPrinterConfig() async {
    return _readJson(StorageKeys.printerConfig, PrinterConfig.fromJson);
  }

  Future<void> savePrinterConfig(PrinterConfig config) {
    return _writeJson(StorageKeys.printerConfig, config.toJson());
  }

  Future<void> clearPrinterConfig() {
    return _storage.delete(key: StorageKeys.printerConfig);
  }

  Future<void> clearAuth() {
    return _storage.delete(key: StorageKeys.authSession);
  }

  Future<void> clearAll() async {
    await _storage.delete(key: StorageKeys.authSession);
    await _storage.delete(key: StorageKeys.terminalContext);
    await _storage.delete(key: StorageKeys.pairedDevice);
    await _storage.delete(key: StorageKeys.shiftState);
  }

  Future<T?> _readJson<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final raw = await _storage.read(key: key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return fromJson(decoded);
    } on Object {
      await _storage.delete(key: key);
      return null;
    }
  }

  Future<void> _writeJson(String key, Map<String, dynamic> json) {
    return _storage.write(key: key, value: jsonEncode(json));
  }
}
