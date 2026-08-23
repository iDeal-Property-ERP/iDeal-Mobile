import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/contracts/domain/entities/mobile_contract.dart';

class ContractsState extends Equatable {
  const ContractsState({
    this.contracts = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  const ContractsState.initial()
    : contracts = const [],
      isLoading = false,
      errorMessage = null;

  final List<MobileContract> contracts;
  final bool isLoading;
  final String? errorMessage;

  ContractsState copyWith({
    List<MobileContract>? contracts,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ContractsState(
      contracts: contracts ?? this.contracts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [contracts, isLoading, errorMessage];
}
