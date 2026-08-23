import 'package:equatable/equatable.dart';

sealed class ContractsEvent extends Equatable {
  const ContractsEvent();

  @override
  List<Object?> get props => [];
}

class LoadContractsEvent extends ContractsEvent {
  const LoadContractsEvent();
}
