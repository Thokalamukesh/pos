import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/secure_storage_service.dart';
import '../models/pos_terminal.dart';

final terminalRepositoryProvider = Provider<TerminalRepository>((ref) {
  return TerminalRepository(ref.watch(secureStorageServiceProvider));
});

class TerminalRepository {
  TerminalRepository(this._storage);

  final SecureStorageService _storage;

  Future<TerminalContext?> restoreTerminal() async {
    final context = await _storage.readTerminalContext();
    if (context == null) {
      return null;
    }
    final session = await _storage.readAuthSession();
    final restaurantId = session?.currentRestaurant?.id;
    final branchId = session?.currentBranch?.id;
    if (restaurantId == context.restaurantId && branchId == context.branchId) {
      return context;
    }
    await _storage.clearTerminalContext();
    return null;
  }

  Future<TerminalContext> selectTerminal(PosTerminal terminal) async {
    final session = await _storage.readAuthSession();
    final restaurantId = session?.currentRestaurant?.id;
    final branchId = session?.currentBranch?.id;
    if (restaurantId == null || branchId == null) {
      throw StateError('Restaurant and branch context are required.');
    }

    final deviceUuid = await _storage.readOrCreateDeviceUuid();
    final context = TerminalContext(
      restaurantId: restaurantId,
      branchId: branchId,
      terminalId: terminal.id,
      terminalCode: terminal.code,
      terminalName: terminal.name,
      deviceUuid: deviceUuid,
      syncToken: terminal.syncToken,
      displayUrl: terminal.displayUrl,
    );
    await _storage.saveTerminalContext(context);
    return context;
  }

  Future<void> clearTerminal() {
    return _storage.clearTerminalContext();
  }
}
