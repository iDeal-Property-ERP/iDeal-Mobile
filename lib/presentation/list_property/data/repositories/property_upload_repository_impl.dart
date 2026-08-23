import 'package:dartz/dartz.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/list_property/data/datasources/property_upload_remote_data_source.dart';
import 'package:ideal_mobile/presentation/list_property/domain/entities/property_upload_config.dart';
import 'package:ideal_mobile/presentation/list_property/domain/entities/property_upload_submission.dart';
import 'package:ideal_mobile/presentation/list_property/domain/repositories/property_upload_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class PropertyUploadRepositoryImpl implements PropertyUploadRepository {
  const PropertyUploadRepositoryImpl(this._remoteDataSource);

  final PropertyUploadRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<PropertyUploadConfig> getConfig() async {
    try {
      final config = await _remoteDataSource.getConfig();
      return Right(config);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    } catch (e) {
      return Left(APIFailure(message: e.toString(), statusCode: 505));
    }
  }

  @override
  ResultFuture<PropertyUploadResult> submitProperty(
    PropertyUploadPayload payload,
  ) async {
    try {
      final result = await _remoteDataSource.submitProperty(payload);
      return Right(result);
    } on APIException catch (e) {
      return Left(APIFailure.fromException(e));
    } catch (e) {
      return Left(APIFailure(message: e.toString(), statusCode: 505));
    }
  }
}
