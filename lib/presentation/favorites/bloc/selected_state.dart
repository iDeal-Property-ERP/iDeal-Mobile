import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';

const selectedPageOutOfDateErrorKey = 'selected_page_out_of_date';
const selectedLoadErrorKey = 'selected_load_error';
const selectedMutationErrorKey = 'selected_mutation_error';

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
      favoriteMutationErrorMessage = state.favoriteMutationErrorMessage;

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
    bool clearErrorMessage = false,
    bool clearFailedPage = false,
    bool clearFavoriteMutationErrorMessage = false,
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
