// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BranchSummary _$BranchSummaryFromJson(Map<String, dynamic> json) =>
    _BranchSummary(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );

Map<String, dynamic> _$BranchSummaryToJson(_BranchSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'address': instance.address,
      'phone': instance.phone,
      'is_default': instance.isDefault,
    };
