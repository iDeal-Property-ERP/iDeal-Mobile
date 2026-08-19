import 'package:dio/dio.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/favorites/domain/entities/selected_sort.dart';
import 'package:ideal_mobile/presentation/listings/data/models/listings_page_model.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';

abstract class FavoritesRemoteDataSource {
  Future<ListingsPageModel> getFavorites({
    required int page,
    int perPage = 20,
    ListingFilters? filters,
    SelectedSort? sort,
  });

  Future<void> setFavorite({required int listingId, required bool isFavorite});
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  const FavoritesRemoteDataSourceImpl(this._dio);

  static const _favoritesPath = '/mobile/favorites/';

  final Dio _dio;

  @override
  Future<ListingsPageModel> getFavorites({
    required int page,
    int perPage = 20,
    ListingFilters? filters,
    SelectedSort? sort,
  }) async {
    final queryParameters = {
      'page': page,
      'per_page': perPage,
      ...?filters?.toQueryParameters(),
      if (sort != null) 'sort': sort.wireValue,
    };
    final response = await _request(
      () => _dio.get(_favoritesPath, queryParameters: queryParameters),
    );

    final body = _bodyFromResponse(response);
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw APIException(
        message: 'Favorites were not returned.',
        statusCode: response.statusCode ?? 500,
      );
    }

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
  Future<void> setFavorite({
    required int listingId,
    required bool isFavorite,
  }) async {
    final path = '$_favoritesPath$listingId/';
    final response = await _request(
      () => isFavorite ? _dio.put(path) : _dio.delete(path),
    );
    _bodyFromResponse(response);
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
        statusCode: error.response?.statusCode ?? 500,
      );
    } catch (error) {
      throw APIException(message: error.toString(), statusCode: 500);
    }
  }

  Map<String, dynamic> _bodyFromResponse(Response<dynamic> response) {
    final body = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
    final success = body['success'] == true;
    final status = response.statusCode ?? 500;
    if ((status != 200 && status != 204) || !success) {
      throw APIException(
        message: _messageFromData(response.data) ?? 'Request failed.',
        statusCode: status,
      );
    }
    return body;
  }

  String? _messageFromData(dynamic data) {
    if (data is! Map) return data?.toString();
    final message = data['message'];
    return message is String && message.trim().isNotEmpty ? message : null;
  }
}
