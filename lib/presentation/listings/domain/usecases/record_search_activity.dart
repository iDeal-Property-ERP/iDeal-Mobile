import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/listings/domain/repositories/listings_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class RecordSearchActivity
    with UseCaseWithParams<void, RecordSearchActivityParams> {
  const RecordSearchActivity(this._repository);

  final ListingsRepository _repository;

  @override
  ResultFuture<void> call(RecordSearchActivityParams params) {
    return _repository.recordSearchActivity(
      query: params.query,
      filters: params.filters,
    );
  }
}

class RecordSearchActivityParams extends Equatable {
  const RecordSearchActivityParams({this.query, this.filters});

  final String? query;
  final Map<String, dynamic>? filters;

  @override
  List<Object?> get props => [query, filters];
}
