import 'package:ideal_mobile/presentation/contracts/domain/entities/mobile_contract.dart';
import 'package:ideal_mobile/presentation/contracts/domain/repositories/contracts_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetContracts {
  const GetContracts(this._repository);

  final ContractsRepository _repository;

  ResultFuture<List<MobileContract>> call() => _repository.getContracts();
}
