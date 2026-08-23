import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/list_property/domain/entities/property_upload_submission.dart';
import 'package:ideal_mobile/presentation/list_property/domain/repositories/property_upload_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class SubmitPropertyUpload
    with UseCaseWithParams<PropertyUploadResult, PropertyUploadPayload> {
  const SubmitPropertyUpload(this._repository);

  final PropertyUploadRepository _repository;

  @override
  ResultFuture<PropertyUploadResult> call(PropertyUploadPayload params) =>
      _repository.submitProperty(params);
}
