// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => _AuthUser(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  hasPosPin: json['has_pos_pin'] as bool? ?? false,
);

Map<String, dynamic> _$AuthUserToJson(_AuthUser instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'has_pos_pin': instance.hasPosPin,
};

_AuthSession _$AuthSessionFromJson(Map<String, dynamic> json) => _AuthSession(
  token: json['token'] as String,
  tokenType: json['token_type'] as String? ?? 'Bearer',
  abilities:
      (json['abilities'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
  isSuperAdmin: json['is_super_admin'] as bool? ?? false,
  restaurants:
      (json['restaurants'] as List<dynamic>?)
          ?.map((e) => RestaurantSummary.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RestaurantSummary>[],
  currentRestaurant: json['current_restaurant'] == null
      ? null
      : RestaurantSummary.fromJson(
          json['current_restaurant'] as Map<String, dynamic>,
        ),
  currentBranch: json['current_branch'] == null
      ? null
      : BranchSummary.fromJson(json['current_branch'] as Map<String, dynamic>),
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
);

Map<String, dynamic> _$AuthSessionToJson(_AuthSession instance) =>
    <String, dynamic>{
      'token': instance.token,
      'token_type': instance.tokenType,
      'abilities': instance.abilities,
      'user': instance.user,
      'is_super_admin': instance.isSuperAdmin,
      'restaurants': instance.restaurants,
      'current_restaurant': instance.currentRestaurant,
      'current_branch': instance.currentBranch,
      'permissions': instance.permissions,
      'plan_features': instance.planFeatures,
    };
