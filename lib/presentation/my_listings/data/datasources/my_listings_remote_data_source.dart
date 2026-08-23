import 'package:dio/dio.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/my_listings/data/models/my_listings_data_model.dart';
import 'package:ideal_mobile/presentation/my_listings/data/models/my_listings_stats_model.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class MyListingsRemoteDataSource {
  Future<MyListingsStatsModel> getMyListingsStats();

  Future<MyListingsDataModel> getMyListings({String status = 'all'});
}

class MyListingsRemoteDataSourceImpl implements MyListingsRemoteDataSource {
  const MyListingsRemoteDataSourceImpl(this._dio);

  static const _myListingsPath = '/mobile/my-listings/';

  final Dio _dio;

  @override
  Future<MyListingsStatsModel> getMyListingsStats() async {
    final response = await _request(() => _dio.get('${_myListingsPath}stats/'));
    return _parse(response, MyListingsStatsModel.fromJson);
  }

  @override
  Future<MyListingsDataModel> getMyListings({String status = 'all'}) async {
    final queryParameters = <String, dynamic>{
      if (status.isNotEmpty && status != 'all') 'status': status,
    };
    final response = await _request(
      () => _dio.get(_myListingsPath, queryParameters: queryParameters),
    );
    return _parse(response, MyListingsDataModel.fromJson);
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw APIException(
        message:
            _message(error.response?.data) ??
            error.message ??
            'Request failed.',
        statusCode: error.response?.statusCode ?? 505,
      );
    } catch (error) {
      if (error is APIException) rethrow;
      throw APIException(message: error.toString(), statusCode: 505);
    }
  }

  T _parse<T>(Response<dynamic> response, T Function(DataMap) parser) {
    final value = _data(response);
    if (value is! Map) {
      throw APIException(
        message: 'Invalid response payload.',
        statusCode: response.statusCode ?? 500,
      );
    }

    try {
      return parser(Map<String, dynamic>.from(value));
    } on FormatException catch (error) {
      throw APIException(
        message: error.message,
        statusCode: response.statusCode ?? 500,
      );
    }
  }

  dynamic _data(Response<dynamic> response) {
    final body = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};

    if (response.statusCode != 200 || body['success'] != true) {
      throw APIException(
        message: _message(response.data) ?? 'Request failed.',
        statusCode: response.statusCode ?? 500,
      );
    }

    return body['data'];
  }

  String? _message(dynamic data) {
    if (data is! Map) return null;
    final value = data['message'] ?? data['error'];
    return value is String && value.isNotEmpty ? value : null;
  }
}
