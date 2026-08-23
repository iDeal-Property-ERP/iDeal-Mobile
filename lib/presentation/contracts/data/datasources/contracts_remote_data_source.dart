import 'package:dio/dio.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/contracts/data/models/mobile_contract_model.dart';

// ignore: one_member_abstracts
abstract interface class ContractsRemoteDataSource {
  Future<List<MobileContractModel>> getContracts();
}

class ContractsRemoteDataSourceImpl implements ContractsRemoteDataSource {
  const ContractsRemoteDataSourceImpl(this._dio);

  static const _contractsPath = '/mobile/contracts/';

  final Dio _dio;

  @override
  Future<List<MobileContractModel>> getContracts() async {
    try {
      final response = await _dio.get(_contractsPath);
      final data = _data(response);
      if (data is! List) {
        throw APIException(
          message: 'Invalid response payload.',
          statusCode: response.statusCode ?? 500,
        );
      }

      return data.map((item) {
        if (item is! Map) {
          throw const FormatException('Invalid mobile contract item.');
        }
        return MobileContractModel.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    } on DioException catch (error) {
      throw APIException(
        message:
            _message(error.response?.data) ??
            error.message ??
            'Request failed.',
        statusCode: error.response?.statusCode ?? 505,
      );
    } on APIException {
      rethrow;
    } on FormatException catch (error) {
      throw APIException(message: error.message, statusCode: 500);
    } catch (error) {
      throw APIException(message: error.toString(), statusCode: 505);
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
