import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';

class ListingsState with EquatableMixin {
  ListingsState({
    this.items = const [],
    this.filters = const ListingFilters.empty(),
    this.searchQuery = '',
    this.page = 1,
    this.numPages = 0,
    this.count = 0,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.filterOptions = const ListingFilterOptions.empty(),
    this.favoriteIds = const <int>{},
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
      errorMessage = state.errorMessage,
      filterOptions = state.filterOptions,
      favoriteIds = state.favoriteIds;

  final List<ListingCard> items;
  final ListingFilters filters;
  final String searchQuery;
  final int page;
  final int numPages;
  final int count;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? errorMessage;
  final ListingFilterOptions filterOptions;
  final Set<int> favoriteIds;

  ListingsState copyWith({
    List<ListingCard>? items,
    ListingFilters? filters,
    String? searchQuery,
    int? page,
    int? numPages,
    int? count,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? errorMessage,
    ListingFilterOptions? filterOptions,
    Set<int>? favoriteIds,
    bool clearErrorMessage = false,
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
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      filterOptions: filterOptions ?? this.filterOptions,
      favoriteIds: favoriteIds ?? this.favoriteIds,
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
    ListingFilterOptions? filterOptions,
    Set<int>? favoriteIds,
    this.errorMessage,
  }) : items = items ?? const [],
       filters = filters ?? const ListingFilters.empty(),
       searchQuery = searchQuery ?? '',
       page = page ?? 1,
       numPages = numPages ?? 0,
       count = count ?? 0,
       hasReachedMax = hasReachedMax ?? false,
       isLoadingMore = isLoadingMore ?? false,
       filterOptions = filterOptions ?? const ListingFilterOptions.empty(),
       favoriteIds = favoriteIds ?? const <int>{};

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
    errorMessage,
    filterOptions,
    favoriteIds,
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
