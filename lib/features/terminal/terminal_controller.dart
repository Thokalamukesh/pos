import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/pos_terminal.dart';
import '../../repositories/terminal_repository.dart';

final terminalContextProvider =
    AsyncNotifierProvider<TerminalContextController, TerminalContext?>(
      TerminalContextController.new,
    );

class TerminalContextController extends AsyncNotifier<TerminalContext?> {
  @override
  Future<TerminalContext?> build() {
    return ref.read(terminalRepositoryProvider).restoreTerminal();
  }

  Future<TerminalContext> select(PosTerminal terminal) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(terminalRepositoryProvider).selectTerminal(terminal),
    );
    state = result;
    return result.requireValue;
  }

  Future<void> clear() async {
    await ref.read(terminalRepositoryProvider).clearTerminal();
    state = const AsyncData(null);
  }
}
