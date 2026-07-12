import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/auth_models.dart';
import '../../repositories/auth_repository.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() {
    return ref.read(authRepositoryProvider).restoreSession();
  }

  Future<AuthSession> login({
    required String email,
    required String password,
    int? restaurantId,
    int? branchId,
  }) async {
    final previousSession = state.asData?.value;
    state = const AsyncLoading();
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .login(
            email: email,
            password: password,
            restaurantId: restaurantId,
            branchId: branchId,
          );
      state = AsyncData(session);
      return session;
    } on Object catch (error, stackTrace) {
      state = AsyncData(previousSession);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
