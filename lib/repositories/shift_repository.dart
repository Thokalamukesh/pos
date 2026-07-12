import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_exception.dart';
import '../services/shift_api_service.dart';

final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  return ShiftRepository(api: ref.watch(shiftApiServiceProvider));
});

class ShiftRepository {
  ShiftRepository({required ShiftApiService api}) : _api = api;

  final ShiftApiService _api;

  Future<Map<String, dynamic>> current() async {
    try {
      return await _api.current();
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> summary() async {
    try {
      return await _api.summary();
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> open({
    required double openingCashFloat,
    String? notes,
  }) async {
    final payloads = [
      {
        'opening_float': openingCashFloat,
        if (_hasText(notes)) 'notes_opening': notes!.trim(),
      },
      {
        'opening_cash_float': openingCashFloat,
        if (_hasText(notes)) 'notes': notes!.trim(),
      },
    ];
    return _tryPayloads((payload) => _api.open(payload), payloads);
  }

  Future<Map<String, dynamic>> close({
    required double countedCash,
    String? notes,
  }) async {
    final countedCashText = countedCash.toStringAsFixed(2);
    final payloads = [
      {
        'closing_cash': countedCash,
        if (_hasText(notes)) 'notes_closing': notes!.trim(),
      },
      {
        'closing_cash': countedCashText,
        if (_hasText(notes)) 'notes_closing': notes!.trim(),
      },
      {
        'closing_cash': countedCash,
        if (_hasText(notes)) 'notes': notes!.trim(),
      },
      {
        'closing_cash_counted': countedCash,
        if (_hasText(notes)) 'notes': notes!.trim(),
      },
      {
        'closing_cash_counted': countedCashText,
        if (_hasText(notes)) 'notes': notes!.trim(),
      },
      {
        'counted_cash': countedCash,
        if (_hasText(notes)) 'notes_closing': notes!.trim(),
      },
      {
        'cash_counted': countedCash,
        if (_hasText(notes)) 'notes': notes!.trim(),
      },
    ];
    return _tryPayloads((payload) => _api.close(payload), payloads);
  }

  Future<Map<String, dynamic>> _tryPayloads(
    Future<Map<String, dynamic>> Function(Map<String, dynamic> payload) call,
    List<Map<String, dynamic>> payloads,
  ) async {
    DioException? lastDioError;
    for (final payload in payloads) {
      try {
        return await call(payload);
      } on DioException catch (error) {
        lastDioError = error;
        final status = error.response?.statusCode;
        if (status != 400 && status != 422) {
          throw AppException.fromDio(error);
        }
      }
    }
    throw AppException.fromDio(lastDioError!);
  }
}

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}
