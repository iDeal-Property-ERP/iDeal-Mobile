import 'package:ideal_mobile/presentation/contracts/domain/entities/mobile_contract.dart';
import 'package:ideal_mobile/utils/typedef.dart';

// ignore: one_member_abstracts
abstract interface class ContractsRepository {
  ResultFuture<List<MobileContract>> getContracts();
}
