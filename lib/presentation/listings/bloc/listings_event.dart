import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';

abstract class ListingsEvent extends Equatable {
  const ListingsEvent();
}

class LoadListingsEvent extends ListingsEvent {
  const LoadListingsEvent();

  @override
  List<Object> get props => [];
}

class LoadMoreListingsEvent extends ListingsEvent {
  const LoadMoreListingsEvent();

  @override
  List<Object> get props => [];
}

class SearchListingsEvent extends ListingsEvent {
  const SearchListingsEvent(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

class ApplyListingFiltersEvent extends ListingsEvent {
  const ApplyListingFiltersEvent(this.filters);

  final ListingFilters filters;

  @override
  List<Object> get props => [filters];
}

class ClearListingFiltersEvent extends ListingsEvent {
  const ClearListingFiltersEvent();

  @override
  List<Object> get props => [];
}

class LoadFilterOptionsEvent extends ListingsEvent {
  const LoadFilterOptionsEvent();

  @override
  List<Object> get props => [];
}

class LoadHomeRailsEvent extends ListingsEvent {
  const LoadHomeRailsEvent({
    this.recentSearchQuery,
    this.favoriteListingIds = const [],
    this.favoriteDistrictId,
  });

  final String? recentSearchQuery;
  final List<int> favoriteListingIds;
  final int? favoriteDistrictId;

  @override
  List<Object?> get props => [
    recentSearchQuery,
    favoriteListingIds,
    favoriteDistrictId,
  ];
}

class ToggleFavoriteEvent extends ListingsEvent {
  const ToggleFavoriteEvent(this.listingId);

  final int listingId;

  @override
  List<Object> get props => [listingId];
}

class ClearFavoriteFeedbackEvent extends ListingsEvent {
  const ClearFavoriteFeedbackEvent();

  @override
  List<Object> get props => [];
}

class SyncFavoriteStatusEvent extends ListingsEvent {
  const SyncFavoriteStatusEvent({
    required this.listingId,
    required this.isFavorite,
  });

  final int listingId;
  final bool isFavorite;

  @override
  List<Object> get props => [listingId, isFavorite];
}
