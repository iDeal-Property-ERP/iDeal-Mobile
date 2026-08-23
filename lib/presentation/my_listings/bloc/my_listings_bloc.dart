import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/my_listings/bloc/my_listings_event.dart';
import 'package:ideal_mobile/presentation/my_listings/bloc/my_listings_state.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/usecases/get_my_listings.dart';
import 'package:ideal_mobile/presentation/my_listings/domain/usecases/get_my_listings_stats.dart';

class MyListingsBloc extends Bloc<MyListingsEvent, MyListingsState> {
  MyListingsBloc({
    GetMyListingsStats? getMyListingsStats,
    GetMyListings? getMyListings,
  }) : _getMyListingsStats = getMyListingsStats ?? sl<GetMyListingsStats>(),
       _getMyListings = getMyListings ?? sl<GetMyListings>(),
       super(const MyListingsState.initial()) {
    on<LoadMyListingsStatsEvent>(_onLoadStats);
    on<LoadMyListingsEvent>(_onLoadListings);
    on<ChangeStatusFilterEvent>(_onChangeFilter);
    on<RefreshMyListingsEvent>(_onRefresh);
  }

  final GetMyListingsStats _getMyListingsStats;
  final GetMyListings _getMyListings;

  Future<void> _onLoadStats(
    LoadMyListingsStatsEvent event,
    Emitter<MyListingsState> emit,
  ) async {
    emit(state.copyWith(isLoadingStats: true, clearError: true));
    final result = await _getMyListingsStats();
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingStats: false, errorMessage: failure.message),
      ),
      (stats) => emit(state.copyWith(stats: stats, isLoadingStats: false)),
    );
  }

  Future<void> _onLoadListings(
    LoadMyListingsEvent event,
    Emitter<MyListingsState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoadingListings: true,
        selectedStatus: event.status,
        clearError: true,
      ),
    );
    final result = await _getMyListings(
      GetMyListingsParams(status: event.status),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingListings: false, errorMessage: failure.message),
      ),
      (data) => emit(
        state.copyWith(
          stats: data.stats,
          listings: data.listings,
          isLoadingListings: false,
        ),
      ),
    );
  }

  Future<void> _onChangeFilter(
    ChangeStatusFilterEvent event,
    Emitter<MyListingsState> emit,
  ) async {
    if (state.selectedStatus == event.status && !state.isLoadingListings) {
      return;
    }
    add(LoadMyListingsEvent(status: event.status));
  }

  Future<void> _onRefresh(
    RefreshMyListingsEvent event,
    Emitter<MyListingsState> emit,
  ) async {
    add(LoadMyListingsEvent(status: state.selectedStatus));
  }
}
