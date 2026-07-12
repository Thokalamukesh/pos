// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RestaurantSummary _$RestaurantSummaryFromJson(Map<String, dynamic> json) =>
    _RestaurantSummary(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String?,
      status: json['status'] as String?,
      role: json['role'] as String?,
      branches:
          (json['branches'] as List<dynamic>?)
              ?.map((e) => BranchSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <BranchSummary>[],
    );

Map<String, dynamic> _$RestaurantSummaryToJson(_RestaurantSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'status': instance.status,
      'role': instance.role,
      'branches': instance.branches,
    };

_PosRestaurant _$PosRestaurantFromJson(Map<String, dynamic> json) =>
    _PosRestaurant(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String?,
      logoUrl: json['logo_url'] as String?,
      primaryColor: json['primary_color'] as String?,
      defaultCurrency: json['default_currency'] as String?,
      taxId: json['tax_id'] as String?,
      taxSettings:
          json['tax_settings'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      serviceCharge:
          json['service_charge'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      orderTypeCharges:
          json['order_type_charges'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      orderTypeSurchargeSettings:
          json['order_type_surcharge_settings'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      tips: json['tips'] as Map<String, dynamic>? ?? const <String, dynamic>{},
    );

Map<String, dynamic> _$PosRestaurantToJson(_PosRestaurant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'logo_url': instance.logoUrl,
      'primary_color': instance.primaryColor,
      'default_currency': instance.defaultCurrency,
      'tax_id': instance.taxId,
      'tax_settings': instance.taxSettings,
      'service_charge': instance.serviceCharge,
      'order_type_charges': instance.orderTypeCharges,
      'order_type_surcharge_settings': instance.orderTypeSurchargeSettings,
      'tips': instance.tips,
    };
