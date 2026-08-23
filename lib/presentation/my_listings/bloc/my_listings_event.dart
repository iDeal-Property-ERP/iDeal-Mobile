import 'package:equatable/equatable.dart';

abstract class MyListingsEvent extends Equatable {
  const MyListingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyListingsStatsEvent extends MyListingsEvent {
  const LoadMyListingsStatsEvent();
}

class LoadMyListingsEvent extends MyListingsEvent {
  const LoadMyListingsEvent({this.status = 'all'});

  final String status;

  @override
  List<Object?> get props => [status];
}

class ChangeStatusFilterEvent extends MyListingsEvent {
  const ChangeStatusFilterEvent(this.status);

  final String status;

  @override
  List<Object?> get props => [status];
}

class RefreshMyListingsEvent extends MyListingsEvent {
  const RefreshMyListingsEvent();
}
