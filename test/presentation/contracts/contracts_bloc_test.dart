import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/contracts/bloc/contracts_bloc.dart';
import 'package:ideal_mobile/presentation/contracts/bloc/contracts_event.dart';
import 'package:ideal_mobile/presentation/contracts/bloc/contracts_state.dart';
import 'package:ideal_mobile/presentation/contracts/domain/entities/mobile_contract.dart';
import 'package:ideal_mobile/presentation/contracts/domain/repositories/contracts_repository.dart';
import 'package:ideal_mobile/presentation/contracts/domain/usecases/get_contracts.dart';
import 'package:ideal_mobile/utils/typedef.dart';

const _contract = MobileContract(
  id: 42,
  reference: '#42',
  propertyId: 7,
  propertyTitle: 'Tenant contract home',
  propertyAddress: '12 Amir Temur Street',
  startDate: '2026-02-01',
  endDate: '2027-02-01',
  monthlyRent: 850,
  currency: 'USD',
  status: 'active',
  statusDisplay: 'Active',
);

void main() {
  blocTest<ContractsBloc, ContractsState>(
    'loads contracts from the repository',
    build: () =>
        ContractsBloc(getContracts: GetContracts(_SuccessRepository())),
    act: (bloc) => bloc.add(const LoadContractsEvent()),
    expect: () => const [
      ContractsState(isLoading: true),
      ContractsState(contracts: [_contract]),
    ],
  );

  blocTest<ContractsBloc, ContractsState>(
    'keeps contract data empty and reports a failed request',
    build: () =>
        ContractsBloc(getContracts: GetContracts(_FailureRepository())),
    act: (bloc) => bloc.add(const LoadContractsEvent()),
    expect: () => const [
      ContractsState(isLoading: true),
      ContractsState(errorMessage: 'Could not load contracts'),
    ],
  );
}

class _SuccessRepository implements ContractsRepository {
  @override
  ResultFuture<List<MobileContract>> getContracts() async =>
      const Right([_contract]);
}

class _FailureRepository implements ContractsRepository {
  @override
  ResultFuture<List<MobileContract>> getContracts() async => const Left(
    APIFailure(message: 'Could not load contracts', statusCode: 500),
  );
}
