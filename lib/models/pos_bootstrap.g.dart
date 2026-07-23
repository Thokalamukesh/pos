// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_bootstrap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PosBootstrapImpl _$$PosBootstrapImplFromJson(Map<String, dynamic> json) =>
    _$PosBootstrapImpl(
      restaurant: json['restaurant'] == null
          ? null
          : PosRestaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
      branch: json['branch'] == null
          ? null
          : BranchSummary.fromJson(json['branch'] as Map<String, dynamic>),
      receiptSettings:
          json['receipt_settings'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      popularItems:
          (json['popular_items'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const <Map<String, dynamic>>[],
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const <Map<String, dynamic>>[],
      branches:
          (json['branches'] as List<dynamic>?)
              ?.map((e) => BranchSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <BranchSummary>[],
      currentShift: json['current_shift'] as Map<String, dynamic>?,
      requireShiftForPos: json['require_shift_for_pos'] as bool? ?? false,
      posBlocked: json['pos_blocked'] as bool? ?? false,
      posTerminals:
          (json['pos_terminals'] as List<dynamic>?)
              ?.map((e) => PosTerminal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PosTerminal>[],
      languages:
          _readLanguages(json, 'languages') as List<dynamic>? ??
          const <Object?>[],
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      planFeatures:
          (json['plan_features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      sync: json['sync'] == null
          ? null
          : PosBootstrapSync.fromJson(json['sync'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PosBootstrapImplToJson(_$PosBootstrapImpl instance) =>
    <String, dynamic>{
      'restaurant': instance.restaurant,
      'branch': instance.branch,
      'receipt_settings': instance.receiptSettings,
      'popular_items': instance.popularItems,
      'categories': instance.categories,
      'branches': instance.branches,
      'current_shift': instance.currentShift,
      'require_shift_for_pos': instance.requireShiftForPos,
      'pos_blocked': instance.posBlocked,
      'pos_terminals': instance.posTerminals,
      'languages': instance.languages,
      'permissions': instance.permissions,
      'plan_features': instance.planFeatures,
      'sync': instance.sync,
    };

_$PosBootstrapSyncImpl _$$PosBootstrapSyncImplFromJson(
  Map<String, dynamic> json,
) => _$PosBootstrapSyncImpl(
  menuRevision: json['menu_revision'] as String?,
  bootstrapRevision: json['bootstrap_revision'] as String?,
);

Map<String, dynamic> _$$PosBootstrapSyncImplToJson(
  _$PosBootstrapSyncImpl instance,
) => <String, dynamic>{
  'menu_revision': instance.menuRevision,
  'bootstrap_revision': instance.bootstrapRevision,
};
