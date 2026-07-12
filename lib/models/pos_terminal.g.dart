// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_terminal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PosTerminal _$PosTerminalFromJson(Map<String, dynamic> json) => _PosTerminal(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  name: json['name'] as String,
  syncToken: json['sync_token'] as String?,
  displayUrl: json['display_url'] as String?,
);

Map<String, dynamic> _$PosTerminalToJson(_PosTerminal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'sync_token': instance.syncToken,
      'display_url': instance.displayUrl,
    };

_TerminalContext _$TerminalContextFromJson(Map<String, dynamic> json) =>
    _TerminalContext(
      restaurantId: (json['restaurantId'] as num).toInt(),
      branchId: (json['branchId'] as num).toInt(),
      terminalId: (json['terminalId'] as num).toInt(),
      terminalCode: json['terminalCode'] as String,
      terminalName: json['terminalName'] as String,
      deviceUuid: json['deviceUuid'] as String,
      syncToken: json['syncToken'] as String?,
      displayUrl: json['displayUrl'] as String?,
    );

Map<String, dynamic> _$TerminalContextToJson(_TerminalContext instance) =>
    <String, dynamic>{
      'restaurantId': instance.restaurantId,
      'branchId': instance.branchId,
      'terminalId': instance.terminalId,
      'terminalCode': instance.terminalCode,
      'terminalName': instance.terminalName,
      'deviceUuid': instance.deviceUuid,
      'syncToken': instance.syncToken,
      'displayUrl': instance.displayUrl,
    };
