import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/entities/my_listing_item.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/entities/my_listings_stats.dart';

class MyListingsState extends Equatable {
  const MyListingsState({
    this.stats = MyListingsStats.empty,
    this.listings = const [],
    this.selectedStatus = 'all',
    this.isLoadingStats = false,
    this.isLoadingListings = false,
    this.errorMessage,
  });

  const MyListingsState.initial()
    : stats = MyListingsStats.empty,
      listings = const [],
      selectedStatus = 'all',
      isLoadingStats = false,
      isLoadingListings = false,
      errorMessage = null;

  final MyListingsStats stats;
  final List<MyListingItem> listings;
  final String selectedStatus;
  final bool isLoadingStats;
  final bool isLoadingListings;
  final String? errorMessage;

  bool get isLoading => isLoadingStats || isLoadingListings;

  MyListingsState copyWith({
    MyListingsStats? stats,
    List<MyListingItem>? listings,
    String? selectedStatus,
    bool? isLoadingStats,
    bool? isLoadingListings,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MyListingsState(
      stats: stats ?? this.stats,
      listings: listings ?? this.listings,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isLoadingStats: isLoadingStats ?? this.isLoadingStats,
      isLoadingListings: isLoadingListings ?? this.isLoadingListings,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    stats,
    listings,
    selectedStatus,
    isLoadingStats,
    isLoadingListings,
    errorMessage,
  ];
}
