import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/listings/data/models/listing_filter_options_model.dart';
import 'package:ideal_mobile/presentation/listings/data/models/listings_page_model.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class ListingsRemoteDataSource {
  Future<ListingsPageModel> getListings({
    required ListingFilters filters,
    required int page,
    int perPage = 20,
  });

  Future<ListingFilterOptionsModel> getFilterOptions();
}

class ListingsRemoteDataSourceImpl implements ListingsRemoteDataSource {
  const ListingsRemoteDataSourceImpl(this._dio, this._cacheManager);

  static const _listingsPath = '/mobile/home/listings/';
  static const _filtersPath = '/mobile/home/filters/';

  final Dio _dio;
  final CacheManager _cacheManager;

  @override
  Future<ListingsPageModel> getListings({
    required ListingFilters filters,
    required int page,
    int perPage = 20,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      ...filters.toQueryParameters(),
    };
    final response = await _request(
      () => _dio.get(
        _listingsPath,
        queryParameters: queryParameters,
        options: _cacheManager.noCacheOptions().toOptions(),
      ),
    );
    final data = _dataFromResponse(
      response,
      missingDataMessage: 'Listings were not returned.',
    );

    try {
      return ListingsPageModel.fromJson({'data': data});
    } on FormatException catch (error) {
      throw APIException(
        message: error.message,
        statusCode: response.statusCode ?? 500,
      );
    }
  }

  @override
  Future<ListingFilterOptionsModel> getFilterOptions() async {
    final response = await _request(() => _dio.get(_filtersPath));
    final data = _dataFromResponse(
      response,
      missingDataMessage: 'Listing filters were not returned.',
    );

    try {
      return ListingFilterOptionsModel.fromJson({'data': data});
    } on FormatException catch (error) {
      throw APIException(
        message: error.message,
        statusCode: response.statusCode ?? 500,
      );
    }
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw APIException(
        message:
            _messageFromData(error.response?.data) ??
            error.message ??
            'Request failed.',
        statusCode: error.response?.statusCode ?? 505,
      );
    } catch (error) {
      throw APIException(message: error.toString(), statusCode: 505);
    }
  }

  DataMap _dataFromResponse(
    Response<dynamic> response, {
    required String missingDataMessage,
  }) {
    final body = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};

    if (response.statusCode != 200 || body['success'] != true) {
      throw APIException(
        message: _messageFromData(response.data) ?? 'Request failed.',
        statusCode: response.statusCode ?? 500,
      );
    }

    final data = body['data'];
    if (data is! Map) {
      throw APIException(
        message: missingDataMessage,
        statusCode: response.statusCode ?? 500,
      );
    }

    return Map<String, dynamic>.from(data);
  }

  String? _messageFromData(dynamic data) {
    if (data is! Map) return data?.toString();

    final message = data['message'];
    return message is String && message.trim().isNotEmpty ? message : null;
  }
}
