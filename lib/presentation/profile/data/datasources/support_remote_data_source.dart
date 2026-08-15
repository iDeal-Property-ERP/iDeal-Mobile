// ignore_for_file: one_member_abstracts

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:ideal_mobile/presentation/profile/data/models/support_links_model.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';

abstract class SupportRemoteDataSource {
  Future<SupportLinksModel> getSupportLinks();
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  const SupportRemoteDataSourceImpl(this._dio, this._cacheManager);

  static const String _supportLinksPath = '/mobile/support/links/';

  final Dio _dio;
  final CacheManager _cacheManager;

  @override
  Future<SupportLinksModel> getSupportLinks() async {
    try {
      final response = await _dio.get(
        _supportLinksPath,
        options: _cacheManager
            .customCacheOptions(
              policy: CachePolicy.forceCache,
              maxStale: const Duration(days: 7),
            )
            .toOptions(),
      );

      final body = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};

      if (response.statusCode != 200 || body['success'] != true) {
        return const SupportLinksModel();
      }

      final data = body['data'];
      if (data is! Map) {
        return const SupportLinksModel();
      }

      return SupportLinksModel.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return const SupportLinksModel();
    }
  }
}
