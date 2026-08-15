import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';

sealed class ListingMapEvent extends Equatable {
  const ListingMapEvent();
}

class InitializeListingMap extends ListingMapEvent {
  const InitializeListingMap({
    required this.filters,
    required this.seedListings,
  });

  final ListingFilters filters;
  final List<ListingCard> seedListings;

  @override
  List<Object> get props => [filters, seedListings];
}

class ListingMapCameraSettled extends ListingMapEvent {
  const ListingMapCameraSettled({required this.bounds, required this.reason});

  final PropertyMapBounds bounds;
  final PropertyMapCameraMoveReason reason;

  @override
  List<Object> get props => [bounds, reason];
}

class SearchListingMapArea extends ListingMapEvent {
  const SearchListingMapArea();

  @override
  List<Object> get props => [];
}

class ChangeListingMapFilters extends ListingMapEvent {
  const ChangeListingMapFilters(this.filters);

  final ListingFilters filters;

  @override
  List<Object> get props => [filters];
}

class ChangeListingMapSearch extends ListingMapEvent {
  const ChangeListingMapSearch(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

class SelectListingMapItem extends ListingMapEvent {
  const SelectListingMapItem(this.listingId);

  final int? listingId;

  @override
  List<Object?> get props => [listingId];
}

class RetryListingMap extends ListingMapEvent {
  const RetryListingMap();

  @override
  List<Object> get props => [];
}

/// Internal event emitted after programmatic camera updates have settled.
class RunProgrammaticListingMapLoad extends ListingMapEvent {
  const RunProgrammaticListingMapLoad(this.generation);

  final int generation;

  @override
  List<Object> get props => [generation];
}

/// Internal event emitted after controlled search input has settled.
class RunDebouncedListingMapSearch extends ListingMapEvent {
  const RunDebouncedListingMapSearch(this.generation);

  final int generation;

  @override
  List<Object> get props => [generation];
}
