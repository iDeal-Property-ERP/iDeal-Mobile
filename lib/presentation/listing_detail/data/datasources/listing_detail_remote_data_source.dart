import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/listing_detail/data/models/listing_detail_model.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class ListingDetailRemoteDataSource {
  Future<ListingDetailModel> getListingDetail({required int id});
}

class ListingDetailRemoteDataSourceImpl
    implements ListingDetailRemoteDataSource {
  const ListingDetailRemoteDataSourceImpl(this._dio, this._cacheManager);

  static const _detailPath = '/mobile/home/listings/';

  final Dio _dio;
  final CacheManager _cacheManager;

  @override
  Future<ListingDetailModel> getListingDetail({required int id}) async {
    final response = await _request(
      () => _dio.get(
        '$_detailPath$id/',
        options: _cacheManager.noCacheOptions().toOptions(),
      ),
    );
    final data = _dataFromResponse(
      response,
      missingDataMessage: 'Listing detail was not returned.',
    );

    try {
      return ListingDetailModel.fromJson(data);
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
