import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/list_property/domain/entities/property_upload_config.dart';
import 'package:ideal_mobile/presentation/list_property/domain/repositories/property_upload_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetPropertyUploadConfig with UseCaseWithoutParams<PropertyUploadConfig> {
  const GetPropertyUploadConfig(this._repository);

  final PropertyUploadRepository _repository;

  @override
  ResultFuture<PropertyUploadConfig> call() => _repository.getConfig();
}
