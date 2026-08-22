import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/listings/domain/repositories/listings_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class RecordViewActivity with UseCaseWithParams<void, int> {
  const RecordViewActivity(this._repository);

  final ListingsRepository _repository;

  @override
  ResultFuture<void> call(int listingId) {
    return _repository.recordViewActivity(listingId);
  }
}
