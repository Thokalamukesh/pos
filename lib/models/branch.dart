import 'package:freezed_annotation/freezed_annotation.dart';

part 'branch.freezed.dart';
part 'branch.g.dart';

@freezed
abstract class BranchSummary with _$BranchSummary {
  const factory BranchSummary({
    required int id,
    required String name,
    String? slug,
    String? address,
    String? phone,
    @JsonKey(name: 'is_default') @Default(false) bool isDefault,
  }) = _BranchSummary;

  factory BranchSummary.fromJson(Map<String, dynamic> json) =>
      _$BranchSummaryFromJson(json);
}
