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
    @JsonKey(readValue: _readLanguages)
    @Default(<Object?>[])
    List<Object?> languages,
    @Default(<String>[]) List<String> permissions,
    @JsonKey(name: 'plan_features')
    @Default(<String>[])
    List<String> planFeatures,
    PosBootstrapSync? sync,
  }) = _PosBootstrap;

  factory PosBootstrap.fromJson(Map<String, dynamic> json) =>
      _$PosBootstrapFromJson(json);
}

Object? _readLanguages(Map json, String key) {
  final settings = json['settings'];
  final branchSettings = json['branch'] is Map
      ? (json['branch'] as Map)['settings']
      : null;
  final restaurantSettings = json['restaurant'] is Map
      ? (json['restaurant'] as Map)['settings']
      : null;

  final value =
      json['languages'] ??
      json['locales'] ??
      json['pos_languages'] ??
      json['posLanguages'] ??
      json['available_languages'] ??
      json['availableLanguages'] ??
      json['supported_languages'] ??
      json['supportedLanguages'] ??
      (settings is Map ? settings['languages'] ?? settings['locales'] : null) ??
      (branchSettings is Map
          ? branchSettings['languages'] ?? branchSettings['locales']
          : null) ??
      (restaurantSettings is Map
          ? restaurantSettings['languages'] ?? restaurantSettings['locales']
          : null);

  if (value is List) {
    return value;
  }
  if (value is Map) {
    return value.entries.map((entry) {
      final item = entry.value;
      if (item is Map) {
        return {'code': entry.key.toString(), ...item};
      }
      return {'code': entry.key.toString(), 'name': item};
    }).toList();
  }
  if (value is String && value.trim().isNotEmpty) {
    return [value.trim()];
  }
  return null;
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
