import 'package:freezed_annotation/freezed_annotation.dart';

import 'pos_terminal.dart';

part 'pairing_models.freezed.dart';
part 'pairing_models.g.dart';

@freezed
abstract class PairingStartResponse with _$PairingStartResponse {
  const factory PairingStartResponse({
    @JsonKey(name: 'pairing_code') required String pairingCode,
    @JsonKey(name: 'device_uuid') required String deviceUuid,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
  }) = _PairingStartResponse;

  factory PairingStartResponse.fromJson(Map<String, dynamic> json) =>
      _$PairingStartResponseFromJson(_normalizePairingStartJson(json));
}

@freezed
abstract class PairingStatusResponse with _$PairingStatusResponse {
  const factory PairingStatusResponse({
    required String status,
    @JsonKey(name: 'pairing_code') String? pairingCode,
    @JsonKey(name: 'device_uuid') String? deviceUuid,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'restaurant_id') int? restaurantId,
    @JsonKey(name: 'restaurant_name') String? restaurantName,
    @JsonKey(name: 'branch_id') int? branchId,
    @JsonKey(name: 'branch_name') String? branchName,
    @JsonKey(name: 'pos_terminal') PosTerminal? posTerminal,
  }) = _PairingStatusResponse;

  factory PairingStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$PairingStatusResponseFromJson(_normalizePairingStatusJson(json));
}

@freezed
abstract class PairedDevice with _$PairedDevice {
  const factory PairedDevice({
    required String deviceUuid,
    required int restaurantId,
    required String restaurantName,
    required int branchId,
    required String branchName,
    required PosTerminal terminal,
    required DateTime pairedAt,
  }) = _PairedDevice;

  factory PairedDevice.fromJson(Map<String, dynamic> json) =>
      _$PairedDeviceFromJson(json);
}

Map<String, dynamic> _normalizePairingStartJson(Map<String, dynamic> json) {
  final data = _dataMap(json);
  return <String, dynamic>{
    ...data,
    'pairing_code': _stringValue(
      data['pairing_code'] ?? data['pairingCode'] ?? data['code'],
    ),
    'device_uuid': _stringValue(
      data['device_uuid'] ?? data['deviceUuid'] ?? data['uuid'],
    ),
    'expires_at': data['expires_at'] ?? data['expiresAt'],
  };
}

Map<String, dynamic> _normalizePairingStatusJson(Map<String, dynamic> json) {
  final data = _dataMap(json);
  final branch = _asMap(data['branch']);
  final terminal = _asMap(
    data['pos_terminal'] ?? data['posTerminal'] ?? data['terminal'],
  );
  final hasTerminal = terminal.isNotEmpty || data['pos_terminal_id'] != null;
  final status = _stringValue(
    data['status'] ??
        data['pairing_status'] ??
        data['pairingStatus'] ??
        (hasTerminal ? 'paired' : 'pending'),
    fallback: 'pending',
  );
  final terminalId = _intValue(
    terminal['id'] ?? data['pos_terminal_id'] ?? data['terminal_id'],
  );
  final terminalCode = _stringValue(
    terminal['code'] ?? terminal['terminal_code'] ?? data['terminal_code'],
    fallback: terminalId == null ? 'POS' : 'T$terminalId',
  );
  final terminalName = _stringValue(
    terminal['name'] ?? terminal['terminal_name'] ?? data['terminal_name'],
    fallback: 'Terminal $terminalCode',
  );

  return <String, dynamic>{
    ...data,
    'status': status,
    'pairing_code': data['pairing_code'] ?? data['pairingCode'],
    'device_uuid': data['device_uuid'] ?? data['deviceUuid'],
    'expires_at': data['expires_at'] ?? data['expiresAt'],
    'restaurant_id': _intValue(
      _asMap(data['restaurant'])['id'] ?? data['restaurant_id'],
    ),
    'restaurant_name':
        _asMap(data['restaurant'])['name'] ?? data['restaurant_name'],
    'branch_id': _intValue(branch['id'] ?? data['branch_id']),
    'branch_name': branch['name'] ?? data['branch_name'],
    if (terminalId != null)
      'pos_terminal': <String, dynamic>{
        ...terminal,
        'id': terminalId,
        'code': terminalCode,
        'name': terminalName,
        if (terminal['sync_token'] != null || data['sync_token'] != null)
          'sync_token': terminal['sync_token'] ?? data['sync_token'],
        if (terminal['display_url'] != null || data['display_url'] != null)
          'display_url': terminal['display_url'] ?? data['display_url'],
      },
  };
}

Map<String, dynamic> _dataMap(Map<String, dynamic> json) {
  final data = json['data'];
  if (data is Map<String, dynamic>) {
    return data;
  }
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return json;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return const <String, dynamic>{};
}

String _stringValue(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? fallback : text;
}

int? _intValue(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}
