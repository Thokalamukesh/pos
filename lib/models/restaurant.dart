import 'package:freezed_annotation/freezed_annotation.dart';

import 'branch.dart';

part 'restaurant.freezed.dart';
part 'restaurant.g.dart';

@freezed
abstract class RestaurantSummary with _$RestaurantSummary {
  const factory RestaurantSummary({
    required int id,
    required String name,
    String? slug,
    String? status,
    String? role,
    @Default(<BranchSummary>[]) List<BranchSummary> branches,
  }) = _RestaurantSummary;

  factory RestaurantSummary.fromJson(Map<String, dynamic> json) =>
      _$RestaurantSummaryFromJson(json);
}

@freezed
abstract class PosRestaurant with _$PosRestaurant {
  const factory PosRestaurant({
    required int id,
    required String name,
    String? slug,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @JsonKey(name: 'primary_color') String? primaryColor,
    @JsonKey(name: 'default_currency') String? defaultCurrency,
    @JsonKey(name: 'tax_id') String? taxId,
    @JsonKey(name: 'tax_settings')
    @Default(<String, dynamic>{})
    Map<String, dynamic> taxSettings,
    @JsonKey(name: 'service_charge')
    @Default(<String, dynamic>{})
    Map<String, dynamic> serviceCharge,
    @JsonKey(name: 'order_type_charges')
    @Default(<String, dynamic>{})
    Map<String, dynamic> orderTypeCharges,
    @JsonKey(name: 'order_type_surcharge_settings')
    @Default(<String, dynamic>{})
    Map<String, dynamic> orderTypeSurchargeSettings,
    @Default(<String, dynamic>{}) Map<String, dynamic> tips,
  }) = _PosRestaurant;

  factory PosRestaurant.fromJson(Map<String, dynamic> json) =>
      _$PosRestaurantFromJson(json);
}
