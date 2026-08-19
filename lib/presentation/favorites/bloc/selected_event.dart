import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/favorites/domain/entities/selected_sort.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';

abstract class SelectedEvent extends Equatable {
  const SelectedEvent();
}

class LoadSelectedEvent extends SelectedEvent {
  const LoadSelectedEvent({this.refresh = false});

  final bool refresh;

  @override
  List<Object> get props => [refresh];
}

class LoadMoreSelectedEvent extends SelectedEvent {
  const LoadMoreSelectedEvent();

  @override
  List<Object> get props => [];
}

class SearchSelectedEvent extends SelectedEvent {
  const SearchSelectedEvent(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

class ApplySelectedFiltersEvent extends SelectedEvent {
  const ApplySelectedFiltersEvent(this.filters);

  final ListingFilters filters;

  @override
  List<Object> get props => [filters];
}

class ClearSelectedFiltersEvent extends SelectedEvent {
  const ClearSelectedFiltersEvent();

  @override
  List<Object> get props => [];
}

class ChangeSelectedSortEvent extends SelectedEvent {
  const ChangeSelectedSortEvent(this.sort);

  final SelectedSort sort;

  @override
  List<Object> get props => [sort];
}

class LoadSelectedFilterOptionsEvent extends SelectedEvent {
  const LoadSelectedFilterOptionsEvent();

  @override
  List<Object> get props => [];
}

class ToggleSelectedFavoriteEvent extends SelectedEvent {
  const ToggleSelectedFavoriteEvent(this.listingId);

  final int listingId;

  @override
  List<Object> get props => [listingId];
}

class RestoreSelectedFavoriteEvent extends SelectedEvent {
  const RestoreSelectedFavoriteEvent(this.listingId);

  final int listingId;

  @override
  List<Object> get props => [listingId];
}

class ClearSelectedFeedbackEvent extends SelectedEvent {
  const ClearSelectedFeedbackEvent();

  @override
  List<Object> get props => [];
}

class ClearSelectedLoadErrorEvent extends SelectedEvent {
  const ClearSelectedLoadErrorEvent();

  @override
  List<Object> get props => [];
}

class SyncSelectedFavoriteEvent extends SelectedEvent {
  const SyncSelectedFavoriteEvent({
    required this.listingId,
    required this.isFavorite,
  });

  final int listingId;
  final bool isFavorite;

  @override
  List<Object> get props => [listingId, isFavorite];
}
