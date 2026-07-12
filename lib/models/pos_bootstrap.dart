import 'package:freezed_annotation/freezed_annotation.dart';

import 'branch.dart';
import 'pos_terminal.dart';
import 'restaurant.dart';

part 'pos_bootstrap.freezed.dart';
part 'pos_bootstrap.g.dart';

@freezed
abstract class PosBootstrap with _$PosBootstrap {
  const factory PosBootstrap({
    PosRestaurant? restaurant,
    BranchSummary? branch,
    @JsonKey(name: 'receipt_settings')
    @Default(<String, dynamic>{})
    Map<String, dynamic> receiptSettings,
    @JsonKey(name: 'popular_items')
    @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> popularItems,
    @Default(<Map<String, dynamic>>[]) List<Map<String, dynamic>> categories,
    @Default(<BranchSummary>[]) List<BranchSummary> branches,
    @JsonKey(name: 'current_shift') Map<String, dynamic>? currentShift,
    @JsonKey(name: 'require_shift_for_pos')
    @Default(false)
    bool requireShiftForPos,
    @JsonKey(name: 'pos_blocked') @Default(false) bool posBlocked,
    @JsonKey(name: 'pos_terminals')
    @Default(<PosTerminal>[])
    List<PosTerminal> posTerminals,
    @Default(<String>[]) List<String> permissions,
    @JsonKey(name: 'plan_features')
    @Default(<String>[])
    List<String> planFeatures,
    PosBootstrapSync? sync,
  }) = _PosBootstrap;

  factory PosBootstrap.fromJson(Map<String, dynamic> json) =>
      _$PosBootstrapFromJson(json);
}

@freezed
abstract class PosBootstrapSync with _$PosBootstrapSync {
  const factory PosBootstrapSync({
    @JsonKey(name: 'menu_revision') String? menuRevision,
    @JsonKey(name: 'bootstrap_revision') String? bootstrapRevision,
  }) = _PosBootstrapSync;

  factory PosBootstrapSync.fromJson(Map<String, dynamic> json) =>
      _$PosBootstrapSyncFromJson(json);
}
