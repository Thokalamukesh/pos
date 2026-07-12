import 'package:dio/dio.dart';

class AppException implements Exception {
  const AppException({
    required this.message,
    this.statusCode,
    this.retryAfter,
    this.errors = const {},
    this.isNetwork = false,
  });

  final String message;
  final int? statusCode;
  final Duration? retryAfter;
  final Map<String, List<String>> errors;
  final bool isNetwork;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isValidation => statusCode == 422;
  bool get canRetry =>
      isNetwork || statusCode == null || (statusCode ?? 0) >= 500;

  factory AppException.fromDio(DioException error) {
    final response = error.response;
    final data = response?.data;
    final retryAfter = _parseRetryAfter(response?.headers.value('retry-after'));
    if (data is Map<String, dynamic>) {
      return AppException(
        message: data['message']?.toString().trim().isNotEmpty == true
            ? data['message'].toString()
            : error.message ?? 'Request failed.',
        statusCode: response?.statusCode,
        retryAfter: retryAfter,
        errors: _parseErrors(data['errors']),
        isNetwork: _isNetworkError(error),
      );
    }

    return AppException(
      message: error.message ?? 'Network request failed.',
      statusCode: response?.statusCode,
      retryAfter: retryAfter,
      isNetwork: _isNetworkError(error),
    );
  }

  static bool _isNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.unknown;
  }

  static Duration? _parseRetryAfter(String? source) {
    if (source == null || source.trim().isEmpty) {
      return null;
    }
    final seconds = int.tryParse(source.trim());
    if (seconds == null || seconds <= 0) {
      return null;
    }
    return Duration(seconds: seconds);
  }

  static Map<String, List<String>> _parseErrors(Object? source) {
    if (source is! Map) {
      return const {};
    }

    return source.map((key, value) {
      final messages = value is List
          ? value.map((item) => item.toString()).toList()
          : <String>[value.toString()];
      return MapEntry(key.toString(), messages);
    });
  }

  @override
  String toString() => message;
}
