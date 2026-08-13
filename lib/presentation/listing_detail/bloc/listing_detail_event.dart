import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';

abstract class ListingDetailEvent extends Equatable {
  const ListingDetailEvent();
}

class LoadListingDetailEvent extends ListingDetailEvent {
  const LoadListingDetailEvent(this.id, {this.initialListing});

  final int id;
  final ListingCard? initialListing;

  @override
  List<Object?> get props => [id, initialListing];
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
