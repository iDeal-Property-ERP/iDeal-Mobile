// ignore_for_file: one_member_abstracts

import 'package:dio/dio.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/listing_map/data/models/listing_map_result_model.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class ListingMapRemoteDataSource {
  Future<ListingMapResultModel> getListings({
    required PropertyMapBounds bounds,
    required ListingFilters filters,
    CancelToken? cancelToken,
    bool favoritesOnly = false,
  });
}

class ListingMapRemoteDataSourceImpl implements ListingMapRemoteDataSource {
  const ListingMapRemoteDataSourceImpl(this._dio);

  static const path = '/mobile/home/listings/map/';

  final Dio _dio;

  @override
  Future<ListingMapResultModel> getListings({
    required PropertyMapBounds bounds,
    required ListingFilters filters,
    CancelToken? cancelToken,
    bool favoritesOnly = false,
  }) async {
    final query = <String, dynamic>{
      'bbox': _bbox(bounds),
      ...filters.toQueryParameters(),
      if (favoritesOnly) 'favorites_only': true,
    };

    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: query,
        cancelToken: cancelToken,
      );
      final body = _mapValue(response.data);
      if (response.statusCode != 200 || body?['success'] != true) {
        throw APIException(
          message: _message(response.data) ?? 'Map listings request failed.',
          statusCode: response.statusCode ?? 500,
        );
      }
      try {
        return ListingMapResultModel.fromJson(body!);
      } on FormatException catch (error) {
        throw APIException(
          message: error.message,
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw APIException(
        message:
            _message(error.response?.data) ??
            error.message ??
            'Map listings request failed.',
        statusCode: error.response?.statusCode ?? 505,
      );
    }
  }

  String _bbox(PropertyMapBounds bounds) => [
    bounds.southWest.longitude,
    bounds.southWest.latitude,
    bounds.northEast.longitude,
    bounds.northEast.latitude,
  ].map(_formatCoordinate).join(',');
}

DataMap? _mapValue(dynamic value) {
  if (value is! Map) return null;
  return Map<String, dynamic>.from(value);
}

String _formatCoordinate(double value) {
  final formatted = value.toStringAsFixed(6);
  return formatted.replaceFirst(RegExp(r'\.?0+$'), '');
}

String? _message(dynamic value) {
  final map = _mapValue(value);
  final message = map?['message'];
  return message is String && message.trim().isNotEmpty ? message : null;
}
