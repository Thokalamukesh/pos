import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/pos_bootstrap.dart';
import '../../repositories/bootstrap_repository.dart';

final posBootstrapProvider = FutureProvider.autoDispose<PosBootstrap>((ref) {
  return ref.watch(bootstrapRepositoryProvider).loadBootstrap();
});
