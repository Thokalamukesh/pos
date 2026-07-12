import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../models/pairing_models.dart';
import '../../repositories/pairing_repository.dart';

final pairingControllerProvider =
    AsyncNotifierProvider<PairingController, PairingStatusResponse?>(
      PairingController.new,
    );

final pairedDeviceProvider = FutureProvider<PairedDevice?>((ref) {
  return ref.watch(pairingRepositoryProvider).restorePairedDevice();
});

class PairingController extends AsyncNotifier<PairingStatusResponse?> {
  String? _deviceUuid;
  bool _pollInFlight = false;
  DateTime? _retryPollAfter;

  String? get deviceUuid => _deviceUuid;

  @override
  Future<PairingStatusResponse?> build() async {
    _deviceUuid = null;
    _retryPollAfter = null;
    _pollInFlight = false;
    return null;
  }

  Future<void> resetForPairing() async {
    _deviceUuid = null;
    _retryPollAfter = null;
    _pollInFlight = false;
    await ref
        .read(pairingRepositoryProvider)
        .clearLocalPairing(clearDeviceUuid: true);
    ref.invalidate(pairedDeviceProvider);
    state = const AsyncData(null);
  }

  Future<PairingStartResponse> startPairing() async {
    await resetForPairing();
    state = const AsyncLoading();
    try {
      final start = await ref.read(pairingRepositoryProvider).start();
      _deviceUuid = start.deviceUuid;
      _retryPollAfter = null;
      final pending = PairingStatusResponse(
        status: 'pending',
        pairingCode: start.pairingCode,
        deviceUuid: start.deviceUuid,
        expiresAt: start.expiresAt,
      );
      state = AsyncData(pending);
      ref.invalidate(pairedDeviceProvider);
      return start;
    } on Object catch (error) {
      if (_isRateLimitError(error)) {
        state = const AsyncData(null);
        throw const AppException(
          message: 'Too many attempts. Please wait a moment, then tap Start pairing again.',
          statusCode: 429,
        );
      }
      state = AsyncError(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> poll() async {
    final uuid = _deviceUuid;
    if (uuid == null || uuid.isEmpty || _pollInFlight) {
      return;
    }
    final now = DateTime.now();
    final retryAfter = _retryPollAfter;
    if (retryAfter != null && now.isBefore(retryAfter)) {
      return;
    }

    final previous = state.asData?.value;
    _pollInFlight = true;
    try {
      final next = await ref.read(pairingRepositoryProvider).poll(uuid);
      _retryPollAfter = null;
      state = AsyncData(next);
      if (next.status == 'paired') {
        ref.invalidate(pairedDeviceProvider);
      }
    } on Object catch (error, stackTrace) {
      if (_isRateLimitError(error) && previous != null) {
        _retryPollAfter = DateTime.now().add(const Duration(seconds: 20));
        state = AsyncData(previous);
      } else {
        state = AsyncError(error, stackTrace);
      }
    } finally {
      _pollInFlight = false;
    }
  }

  bool _isRateLimitError(Object error) {
    final message = error is AppException ? error.message : error.toString();
    final normalized = message.toLowerCase();
    return normalized.contains('too many attempts') ||
        normalized.contains('too many requests') ||
        normalized.contains('429');
  }
}
