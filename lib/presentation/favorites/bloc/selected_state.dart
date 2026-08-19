import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/presentation/favorites/domain/entities/selected_sort.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';

const selectedPageOutOfDateErrorKey = 'selected_page_out_of_date';
const selectedLoadErrorKey = 'selected_load_error';
const selectedMutationErrorKey = 'selected_mutation_error';

/// A listing removed from the selected list, kept briefly so the screen can
/// offer an undo action while the removal settles.
class SelectedUndoInfo with EquatableMixin {
  const SelectedUndoInfo({
    required this.listingId,
    required this.item,
    required this.index,
  });

  final int listingId;
  final ListingCard item;
  final int index;

  @override
  List<Object?> get props => [listingId, index];
}

class SelectedState with EquatableMixin {
  SelectedState({
    this.items = const [],
    this.page = 1,
    this.numPages = 0,
    this.count = 0,
    this.hasReachedMax = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasLoaded = false,
    this.errorMessage,
    this.failedPage,
    this.favoriteMutationErrorMessage,
    this.filters = const ListingFilters.empty(),
    this.sort = SelectedSort.recent,
    this.filterOptions = const ListingFilterOptions.empty(),
    this.removedListing,
  });

  SelectedState.initial() : this();

  SelectedState.copy(SelectedState state)
    : items = state.items,
      page = state.page,
      numPages = state.numPages,
      count = state.count,
      hasReachedMax = state.hasReachedMax,
      isLoading = state.isLoading,
      isLoadingMore = state.isLoadingMore,
      hasLoaded = state.hasLoaded,
      errorMessage = state.errorMessage,
      failedPage = state.failedPage,
      favoriteMutationErrorMessage = state.favoriteMutationErrorMessage,
      filters = state.filters,
      sort = state.sort,
      filterOptions = state.filterOptions,
      removedListing = state.removedListing;

  final List<ListingCard> items;
  final int page;
  final int numPages;
  final int count;
  final bool hasReachedMax;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasLoaded;
  final String? errorMessage;
  final int? failedPage;
  final String? favoriteMutationErrorMessage;
  final ListingFilters filters;
  final SelectedSort sort;
  final ListingFilterOptions filterOptions;
  final SelectedUndoInfo? removedListing;

  bool get hasActiveFilters => !filters.isEmpty;

  SelectedState copyWith({
    List<ListingCard>? items,
    int? page,
    int? numPages,
    int? count,
    bool? hasReachedMax,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasLoaded,
    String? errorMessage,
    int? failedPage,
    String? favoriteMutationErrorMessage,
    ListingFilters? filters,
    SelectedSort? sort,
    ListingFilterOptions? filterOptions,
    SelectedUndoInfo? removedListing,
    bool clearErrorMessage = false,
    bool clearFailedPage = false,
    bool clearFavoriteMutationErrorMessage = false,
    bool clearRemovedListing = false,
  }) {
    return SelectedState(
      items: items ?? this.items,
      page: page ?? this.page,
      numPages: numPages ?? this.numPages,
      count: count ?? this.count,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      failedPage: clearFailedPage ? null : failedPage ?? this.failedPage,
      favoriteMutationErrorMessage: clearFavoriteMutationErrorMessage
          ? null
          : favoriteMutationErrorMessage ?? this.favoriteMutationErrorMessage,
      filters: filters ?? this.filters,
      sort: sort ?? this.sort,
      filterOptions: filterOptions ?? this.filterOptions,
      removedListing: clearRemovedListing
          ? null
          : removedListing ?? this.removedListing,
    );
  }

  @visibleForTesting
  SelectedState.test({
    List<ListingCard>? items,
    int? page,
    int? numPages,
    int? count,
    bool? hasReachedMax,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasLoaded,
    this.errorMessage,
    int? failedPage,
    this.favoriteMutationErrorMessage,
    this.filters = const ListingFilters.empty(),
    this.sort = SelectedSort.recent,
    this.filterOptions = const ListingFilterOptions.empty(),
    this.removedListing,
  }) : items = items ?? const [],
       page = page ?? 1,
       numPages = numPages ?? 0,
       count = count ?? 0,
       hasReachedMax = hasReachedMax ?? false,
       isLoading = isLoading ?? false,
       isLoadingMore = isLoadingMore ?? false,
       hasLoaded = hasLoaded ?? false,
       failedPage =
           failedPage ??
           (errorMessage != null && items != null && items.isNotEmpty
               ? (page ?? 1) + 1
               : null);

  @override
  List<Object?> get props => [
    items,
    page,
    numPages,
    count,
    hasReachedMax,
    isLoading,
    isLoadingMore,
    hasLoaded,
    errorMessage,
    failedPage,
    favoriteMutationErrorMessage,
    filters,
    sort,
    filterOptions,
    removedListing,
  ];
}

class SelectedLoadingState extends SelectedState {
  SelectedLoadingState(super.state) : super.copy();
}

class SelectedLoadedState extends SelectedState {
  SelectedLoadedState(super.state) : super.copy();
}

class SelectedLoadingMoreState extends SelectedState {
  SelectedLoadingMoreState(super.state) : super.copy();
}

class SelectedErrorState extends SelectedState {
  SelectedErrorState(SelectedState state, {String? errorMessage})
    : super.copy(
        state.copyWith(errorMessage: errorMessage ?? state.errorMessage),
      );
}
