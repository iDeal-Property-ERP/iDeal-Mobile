import 'package:ideal_mobile/presentation/list_property/domain/entities/property_upload_config.dart';
import 'package:ideal_mobile/presentation/list_property/domain/entities/property_upload_submission.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class PropertyUploadRepository {
  ResultFuture<PropertyUploadConfig> getConfig();

  ResultFuture<PropertyUploadResult> submitProperty(
    PropertyUploadPayload payload,
  );
}
