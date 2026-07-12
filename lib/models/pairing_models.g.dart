// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairing_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PairingStartResponse _$PairingStartResponseFromJson(
  Map<String, dynamic> json,
) => _PairingStartResponse(
  pairingCode: json['pairing_code'] as String,
  deviceUuid: json['device_uuid'] as String,
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
);

Map<String, dynamic> _$PairingStartResponseToJson(
  _PairingStartResponse instance,
) => <String, dynamic>{
  'pairing_code': instance.pairingCode,
  'device_uuid': instance.deviceUuid,
  'expires_at': instance.expiresAt?.toIso8601String(),
};

_PairingStatusResponse _$PairingStatusResponseFromJson(
  Map<String, dynamic> json,
) => _PairingStatusResponse(
  status: json['status'] as String,
  pairingCode: json['pairing_code'] as String?,
  deviceUuid: json['device_uuid'] as String?,
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  restaurantId: (json['restaurant_id'] as num?)?.toInt(),
  restaurantName: json['restaurant_name'] as String?,
  branchId: (json['branch_id'] as num?)?.toInt(),
  branchName: json['branch_name'] as String?,
  posTerminal: json['pos_terminal'] == null
      ? null
      : PosTerminal.fromJson(json['pos_terminal'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PairingStatusResponseToJson(
  _PairingStatusResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'pairing_code': instance.pairingCode,
  'device_uuid': instance.deviceUuid,
  'expires_at': instance.expiresAt?.toIso8601String(),
  'restaurant_id': instance.restaurantId,
  'restaurant_name': instance.restaurantName,
  'branch_id': instance.branchId,
  'branch_name': instance.branchName,
  'pos_terminal': instance.posTerminal,
};

_PairedDevice _$PairedDeviceFromJson(Map<String, dynamic> json) =>
    _PairedDevice(
      deviceUuid: json['deviceUuid'] as String,
      restaurantId: (json['restaurantId'] as num).toInt(),
      restaurantName: json['restaurantName'] as String,
      branchId: (json['branchId'] as num).toInt(),
      branchName: json['branchName'] as String,
      terminal: PosTerminal.fromJson(json['terminal'] as Map<String, dynamic>),
      pairedAt: DateTime.parse(json['pairedAt'] as String),
    );

Map<String, dynamic> _$PairedDeviceToJson(_PairedDevice instance) =>
    <String, dynamic>{
      'deviceUuid': instance.deviceUuid,
      'restaurantId': instance.restaurantId,
      'restaurantName': instance.restaurantName,
      'branchId': instance.branchId,
      'branchName': instance.branchName,
      'terminal': instance.terminal,
      'pairedAt': instance.pairedAt.toIso8601String(),
    };
