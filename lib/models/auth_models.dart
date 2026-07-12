import 'package:freezed_annotation/freezed_annotation.dart';

import 'branch.dart';
import 'restaurant.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required int id,
    required String name,
    required String email,
    @JsonKey(name: 'has_pos_pin') @Default(false) bool hasPosPin,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);
}

@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required String token,
    @JsonKey(name: 'token_type') @Default('Bearer') String tokenType,
    @Default(<String>[]) List<String> abilities,
    required AuthUser user,
    @JsonKey(name: 'is_super_admin') @Default(false) bool isSuperAdmin,
    @Default(<RestaurantSummary>[]) List<RestaurantSummary> restaurants,
    @JsonKey(name: 'current_restaurant') RestaurantSummary? currentRestaurant,
    @JsonKey(name: 'current_branch') BranchSummary? currentBranch,
    @Default(<String>[]) List<String> permissions,
    @JsonKey(name: 'plan_features')
    @Default(<String>[])
    List<String> planFeatures,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);
}
