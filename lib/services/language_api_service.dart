import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/app_settings_controller.dart';
import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';

final languageApiServiceProvider = Provider<LanguageApiService>((ref) {
  return LanguageApiService(ref.watch(dioProvider));
});

final posLanguagesProvider = FutureProvider<List<PosLanguage>>((ref) async {
  final languages = await ref
      .watch(languageApiServiceProvider)
      .fetchLanguages();
  return languages.isEmpty ? defaultPosLanguages : languages;
});

class LanguageApiService {
  const LanguageApiService(this._dio);

  final Dio _dio;

  Future<List<PosLanguage>> fetchLanguages() async {
    const paths = [
      '/pos/languages',
      '/languages',
      '/locales',
      '/settings/languages',
    ];
    for (final path in paths) {
      try {
        final response = await _dio.get<dynamic>('${AppConfig.apiPrefix}$path');
        final parsed = _languagesFromResponse(response.data);
        if (parsed.isNotEmpty) {
          return _dedupeLanguages(parsed);
        }
      } on DioException catch (error) {
        final status = error.response?.statusCode;
        if (status != 404 && status != 405) {
          rethrow;
        }
      }
    }
    return defaultPosLanguages;
  }
}

List<PosLanguage> _languagesFromResponse(Object? responseData) {
  if (responseData is List) {
    return responseData
        .map(_languageFromValue)
        .whereType<PosLanguage>()
        .toList();
  }
  if (responseData is! Map<String, dynamic>) {
    return const [];
  }
  final data = unwrapDataMap(responseData);
  final settings = data['settings'] is Map
      ? Map<String, dynamic>.from(data['settings'] as Map)
      : const <String, dynamic>{};
  final value =
      data['languages'] ??
      data['locales'] ??
      data['pos_languages'] ??
      data['posLanguages'] ??
      data['available_languages'] ??
      data['availableLanguages'] ??
      data['supported_languages'] ??
      data['supportedLanguages'] ??
      settings['languages'] ??
      settings['locales'] ??
      data['data'] ??
      data['items'];
  if (value is List) {
    return value.map(_languageFromValue).whereType<PosLanguage>().toList();
  }
  if (value is Map) {
    return value.entries
        .map(
          (entry) => PosLanguage(
            code: entry.key.toString(),
            label: entry.value.toString(),
          ),
        )
        .toList();
  }
  return const [];
}

PosLanguage? _languageFromValue(Object? value) {
  if (value is String) {
    final code = value.trim();
    if (code.isEmpty) {
      return null;
    }
    return PosLanguage(code: code, label: _languageName(code));
  }
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    final code = _firstString(map, const [
      'code',
      'locale',
      'language_code',
      'languageCode',
      'slug',
    ]);
    if (code.isEmpty) {
      final id = _firstString(map, const ['id']);
      if (!_looksLikeLanguageCode(id)) {
        return null;
      }
      return PosLanguage(code: id, label: _languageName(id));
    }
    final label = _firstString(map, const [
      'name',
      'label',
      'title',
      'english_name',
      'englishName',
    ]);
    final nativeLabel = _firstString(map, const [
      'native_name',
      'nativeName',
      'local_name',
      'localName',
    ]);
    return PosLanguage(
      code: code,
      label: label.isEmpty ? _languageName(code) : label,
      nativeLabel: nativeLabel.isEmpty ? null : nativeLabel,
    );
  }
  return null;
}

List<PosLanguage> _dedupeLanguages(List<PosLanguage> languages) {
  final byCode = <String, PosLanguage>{};
  for (final language in [...defaultPosLanguages, ...languages]) {
    final code = language.code.trim();
    if (code.isNotEmpty) {
      byCode[code.toLowerCase()] = language;
    }
  }
  return byCode.values.toList();
}

bool _looksLikeLanguageCode(String value) {
  return RegExp(r'^[a-zA-Z]{2,3}([_-][a-zA-Z]{2})?$').hasMatch(value.trim());
}

String _firstString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) {
      continue;
    }
    final text = value.toString().trim();
    if (text.isNotEmpty) {
      return text;
    }
  }
  return '';
}

String _languageName(String code) {
  switch (code.toLowerCase()) {
    case 'en':
    case 'en-us':
    case 'en-in':
      return 'English';
    case 'hi':
    case 'hi-in':
      return 'Hindi';
    case 'te':
    case 'te-in':
      return 'Telugu';
    case 'ta':
    case 'ta-in':
      return 'Tamil';
    case 'kn':
    case 'kn-in':
      return 'Kannada';
    case 'ml':
    case 'ml-in':
      return 'Malayalam';
    default:
      return code.toUpperCase();
  }
}
