import 'package:freezed_annotation/freezed_annotation.dart';

part 'pos_terminal.freezed.dart';
part 'pos_terminal.g.dart';

@freezed
abstract class PosTerminal with _$PosTerminal {
  const factory PosTerminal({
    required int id,
    required String code,
    required String name,
    @JsonKey(name: 'sync_token') String? syncToken,
    @JsonKey(name: 'display_url') String? displayUrl,
  }) = _PosTerminal;

  factory PosTerminal.fromJson(Map<String, dynamic> json) =>
      _$PosTerminalFromJson(json);
}

@freezed
abstract class TerminalContext with _$TerminalContext {
  const factory TerminalContext({
    required int restaurantId,
    required int branchId,
    required int terminalId,
    required String terminalCode,
    required String terminalName,
    required String deviceUuid,
    String? syncToken,
    String? displayUrl,
  }) = _TerminalContext;

  factory TerminalContext.fromJson(Map<String, dynamic> json) =>
      _$TerminalContextFromJson(json);
}
