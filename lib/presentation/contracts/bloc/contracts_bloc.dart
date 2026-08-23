import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/contracts/bloc/contracts_event.dart';
import 'package:ideal_mobile/presentation/contracts/bloc/contracts_state.dart';
import 'package:ideal_mobile/presentation/contracts/domain/usecases/get_contracts.dart';

class ContractsBloc extends Bloc<ContractsEvent, ContractsState> {
  ContractsBloc({GetContracts? getContracts})
    : _getContracts = getContracts ?? sl<GetContracts>(),
      super(const ContractsState.initial()) {
    on<LoadContractsEvent>(_onLoadContracts);
  }

  final GetContracts _getContracts;

  Future<void> _onLoadContracts(
    LoadContractsEvent event,
    Emitter<ContractsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _getContracts();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (contracts) =>
          emit(state.copyWith(contracts: contracts, isLoading: false)),
    );
  }
}
