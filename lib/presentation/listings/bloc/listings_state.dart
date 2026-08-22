import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';

class ListingsState with EquatableMixin {
  ListingsState({
    this.items = const [],
    this.filters = const ListingFilters(sort: 'score_desc'),
    this.searchQuery = '',
    this.page = 1,
    this.numPages = 0,
    this.count = 0,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.isListingsLoading = false,
    this.hasLoadedListings = false,
    this.errorMessage,
    this.filterOptions = const ListingFilterOptions.empty(),
    this.dataOrigin = PublicDataOrigin.fresh,
    this.isStale = false,
    this.listingRefreshError,
    this.favoriteMutationErrorMessage,
    this.recentSearchRailListings = const [],
    this.recentSearchContext,
    this.isRecentSearchRailLoading = false,
    this.selectedInspiredRailListings = const [],
    this.isSelectedRailLoading = false,
  });

  ListingsState.initial() : this();

  ListingsState.copy(ListingsState state)
    : items = state.items,
      filters = state.filters,
      searchQuery = state.searchQuery,
      page = state.page,
      numPages = state.numPages,
      count = state.count,
      hasReachedMax = state.hasReachedMax,
      isLoadingMore = state.isLoadingMore,
      isListingsLoading = state.isListingsLoading,
      hasLoadedListings = state.hasLoadedListings,
      errorMessage = state.errorMessage,
      filterOptions = state.filterOptions,
      dataOrigin = state.dataOrigin,
      isStale = state.isStale,
      listingRefreshError = state.listingRefreshError,
      favoriteMutationErrorMessage = state.favoriteMutationErrorMessage,
      recentSearchRailListings = state.recentSearchRailListings,
      recentSearchContext = state.recentSearchContext,
      isRecentSearchRailLoading = state.isRecentSearchRailLoading,
      selectedInspiredRailListings = state.selectedInspiredRailListings,
      isSelectedRailLoading = state.isSelectedRailLoading;

  final List<ListingCard> items;
  final ListingFilters filters;
  final String searchQuery;
  final int page;
  final int numPages;
  final int count;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final bool isListingsLoading;
  final bool hasLoadedListings;
  final String? errorMessage;
  final ListingFilterOptions filterOptions;
  final PublicDataOrigin dataOrigin;
  final bool isStale;
  final String? listingRefreshError;
  final String? favoriteMutationErrorMessage;
  final List<ListingCard> recentSearchRailListings;
  final String? recentSearchContext;
  final bool isRecentSearchRailLoading;
  final List<ListingCard> selectedInspiredRailListings;
  final bool isSelectedRailLoading;

  ListingsState copyWith({
    List<ListingCard>? items,
    ListingFilters? filters,
    String? searchQuery,
    int? page,
    int? numPages,
    int? count,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? isListingsLoading,
    bool? hasLoadedListings,
    String? errorMessage,
    ListingFilterOptions? filterOptions,
    PublicDataOrigin? dataOrigin,
    bool? isStale,
    String? listingRefreshError,
    String? favoriteMutationErrorMessage,
    List<ListingCard>? recentSearchRailListings,
    String? recentSearchContext,
    bool? isRecentSearchRailLoading,
    List<ListingCard>? selectedInspiredRailListings,
    bool? isSelectedRailLoading,
    bool clearErrorMessage = false,
    bool clearListingRefreshError = false,
    bool clearFavoriteMutationErrorMessage = false,
    bool clearRecentSearchContext = false,
  }) {
    return ListingsState(
      items: items ?? this.items,
      filters: filters ?? this.filters,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      numPages: numPages ?? this.numPages,
      count: count ?? this.count,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isListingsLoading: isListingsLoading ?? this.isListingsLoading,
      hasLoadedListings: hasLoadedListings ?? this.hasLoadedListings,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      filterOptions: filterOptions ?? this.filterOptions,
      dataOrigin: dataOrigin ?? this.dataOrigin,
      isStale: isStale ?? this.isStale,
      listingRefreshError: clearListingRefreshError
          ? null
          : listingRefreshError ?? this.listingRefreshError,
      favoriteMutationErrorMessage: clearFavoriteMutationErrorMessage
          ? null
          : favoriteMutationErrorMessage ?? this.favoriteMutationErrorMessage,
      recentSearchRailListings:
          recentSearchRailListings ?? this.recentSearchRailListings,
      recentSearchContext: clearRecentSearchContext
          ? null
          : recentSearchContext ?? this.recentSearchContext,
      isRecentSearchRailLoading:
          isRecentSearchRailLoading ?? this.isRecentSearchRailLoading,
      selectedInspiredRailListings:
          selectedInspiredRailListings ?? this.selectedInspiredRailListings,
      isSelectedRailLoading:
          isSelectedRailLoading ?? this.isSelectedRailLoading,
    );
  }

  @visibleForTesting
  ListingsState.test({
    List<ListingCard>? items,
    ListingFilters? filters,
    String? searchQuery,
    int? page,
    int? numPages,
    int? count,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? isListingsLoading,
    bool? hasLoadedListings,
    ListingFilterOptions? filterOptions,
    this.dataOrigin = PublicDataOrigin.fresh,
    this.isStale = false,
    this.listingRefreshError,
    this.errorMessage,
    this.favoriteMutationErrorMessage,
    List<ListingCard>? recentSearchRailListings,
    this.recentSearchContext,
    this.isRecentSearchRailLoading = false,
    List<ListingCard>? selectedInspiredRailListings,
    this.isSelectedRailLoading = false,
  }) : items = items ?? const [],
       filters = filters ?? const ListingFilters(sort: 'score_desc'),
       searchQuery = searchQuery ?? '',
       page = page ?? 1,
       numPages = numPages ?? 0,
       count = count ?? 0,
       hasReachedMax = hasReachedMax ?? false,
       isLoadingMore = isLoadingMore ?? false,
       isListingsLoading = isListingsLoading ?? false,
       hasLoadedListings = hasLoadedListings ?? false,
       filterOptions = filterOptions ?? const ListingFilterOptions.empty(),
       recentSearchRailListings = recentSearchRailListings ?? const [],
       selectedInspiredRailListings = selectedInspiredRailListings ?? const [];

  @override
  List<Object?> get props => [
    items,
    filters,
    searchQuery,
    page,
    numPages,
    count,
    hasReachedMax,
    isLoadingMore,
    isListingsLoading,
    hasLoadedListings,
    errorMessage,
    filterOptions,
    dataOrigin,
    isStale,
    listingRefreshError,
    favoriteMutationErrorMessage,
    recentSearchRailListings,
    recentSearchContext,
    isRecentSearchRailLoading,
    selectedInspiredRailListings,
    isSelectedRailLoading,
  ];
}

class ListingsLoadingState extends ListingsState {
  ListingsLoadingState(super.state) : super.copy();
}

class ListingsLoadedState extends ListingsState {
  ListingsLoadedState(super.state) : super.copy();
}

class ListingsLoadingMoreState extends ListingsState {
  ListingsLoadingMoreState(super.state) : super.copy();
}

class ListingsErrorState extends ListingsState {
  ListingsErrorState(ListingsState state, {String? errorMessage})
    : super.copy(
        state.copyWith(errorMessage: errorMessage ?? state.errorMessage),
      );
}

class ListingFilterOptionsLoadedState extends ListingsState {
  ListingFilterOptionsLoadedState(super.state) : super.copy();
}
