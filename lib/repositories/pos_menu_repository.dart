import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_exception.dart';
import '../services/pos_menu_api_service.dart';

final posMenuRepositoryProvider = Provider<PosMenuRepository>((ref) {
  return PosMenuRepository(api: ref.watch(posMenuApiServiceProvider));
});

class PosMenuRepository {
  PosMenuRepository({required PosMenuApiService api}) : _api = api;

  final PosMenuApiService _api;

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final data = await _api.fetchMenu();
      final value = data['categories'];
      if (value is! List) {
        return const <Map<String, dynamic>>[];
      }
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } on DioException catch (error) {
      throw AppException.fromDio(error);
    }
  }
}
