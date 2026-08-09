import 'package:equatable/equatable.dart';

abstract class ListingDetailEvent extends Equatable {
  const ListingDetailEvent();
}

class LoadListingDetailEvent extends ListingDetailEvent {
  const LoadListingDetailEvent(this.id);

  final int id;

  @override
  List<Object> get props => [id];
}

class RetryListingDetailEvent extends ListingDetailEvent {
  const RetryListingDetailEvent(this.id);

  final int id;

  @override
  List<Object> get props => [id];
}

class ClearListingDetailErrorEvent extends ListingDetailEvent {
  const ClearListingDetailErrorEvent();

  @override
  List<Object> get props => [];
}
