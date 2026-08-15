import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';

class ListingMapState extends Equatable {
  const ListingMapState({
    this.initialFilters = const ListingFilters.empty(),
    this.filters = const ListingFilters.empty(),
    this.items = const [],
    this.currentBounds,
    this.selectedListingId,
    this.isLoading = false,
    this.hasLoadedBounds = false,
    this.showSearchThisArea = false,
    this.truncated = false,
    this.count = 0,
    this.errorMessage,
  });

  final ListingFilters initialFilters;
  final ListingFilters filters;
  final List<ListingCard> items;
  final PropertyMapBounds? currentBounds;
  final int? selectedListingId;
  final bool isLoading;
  final bool hasLoadedBounds;
  final bool showSearchThisArea;
  final bool truncated;
  final int count;
  final String? errorMessage;

  bool get filtersChanged => filters != initialFilters;

  ListingMapState copyWith({
    ListingFilters? initialFilters,
    ListingFilters? filters,
    List<ListingCard>? items,
    PropertyMapBounds? currentBounds,
    int? selectedListingId,
    bool? isLoading,
    bool? hasLoadedBounds,
    bool? showSearchThisArea,
    bool? truncated,
    int? count,
    String? errorMessage,
    bool clearSelectedListingId = false,
    bool clearErrorMessage = false,
  }) {
    return ListingMapState(
      initialFilters: initialFilters ?? this.initialFilters,
      filters: filters ?? this.filters,
      items: items ?? this.items,
      currentBounds: currentBounds ?? this.currentBounds,
      selectedListingId: clearSelectedListingId
          ? null
          : selectedListingId ?? this.selectedListingId,
      isLoading: isLoading ?? this.isLoading,
      hasLoadedBounds: hasLoadedBounds ?? this.hasLoadedBounds,
      showSearchThisArea: showSearchThisArea ?? this.showSearchThisArea,
      truncated: truncated ?? this.truncated,
      count: count ?? this.count,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    initialFilters,
    filters,
    items,
    currentBounds,
    selectedListingId,
    isLoading,
    hasLoadedBounds,
    showSearchThisArea,
    truncated,
    count,
    errorMessage,
  ];
}
