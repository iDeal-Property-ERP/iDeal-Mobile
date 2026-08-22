import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/constants/constants.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_event.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_state.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/usecases/get_listing_detail.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/usecases/get_listing_detail_cached.dart';
import 'package:ideal_mobile/presentation/listings/domain/usecases/record_view_activity.dart';
import 'package:ideal_mobile/services/guest_access_service.dart';
import 'package:ideal_mobile/services/performance_monitoring_service.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:ideal_mobile/utils/extensions/primitive_types_extensions.dart';

class ListingDetailBloc extends Bloc<ListingDetailEvent, ListingDetailState> {
  ListingDetailBloc({
    GetListingDetail? getListingDetail,
    GetListingDetailCached? getListingDetailCached,
    RecordViewActivity? recordViewActivity,
    PerformanceMonitoringService? performanceService,
  }) : _getListingDetail = getListingDetail ?? sl<GetListingDetail>(),
       _recordViewActivity =
           recordViewActivity ??
           (sl.isRegistered<RecordViewActivity>()
               ? sl<RecordViewActivity>()
               : null),
       _performanceService =
           performanceService ??
           (sl.isRegistered<PerformanceMonitoringService>()
               ? sl<PerformanceMonitoringService>()
               : PerformanceMonitoringService()),
       _getListingDetailCached =
           getListingDetailCached ??
           (sl.isRegistered<GetListingDetailCached>()
               ? sl<GetListingDetailCached>()
               : null),
       super(const ListingDetailState.initial()) {
    on<LoadListingDetailEvent>(_onLoadListingDetailEvent);
    on<RetryListingDetailEvent>(_onRetryListingDetailEvent);
    on<ClearListingDetailErrorEvent>(_onClearListingDetailErrorEvent);
  }

  final GetListingDetail _getListingDetail;
  final GetListingDetailCached? _getListingDetailCached;
  final RecordViewActivity? _recordViewActivity;
  final PerformanceMonitoringService _performanceService;
  bool _hasRecordedView = false;

  void _recordViewOnce(int id) {
    final recordView = _recordViewActivity;
    if (_hasRecordedView || recordView == null) return;
    _hasRecordedView = true;
    unawaited(
      GuestAccessService.hasAuthenticatedSession()
          .then((isAuthenticated) {
            if (isAuthenticated) {
              recordView(id);
            }
          })
          .catchError((_) {}),
    );
  }

  Future<void> _onLoadListingDetailEvent(
    LoadListingDetailEvent event,
    Emitter<ListingDetailState> emit,
  ) {
    final seed = event.initialListing;
    if (seed != null && seed.id == event.id) {
      emit(state.copyWith(preview: seed, isFreshDetail: false));
      _recordViewOnce(event.id);
    }
    return _loadListingDetail(id: event.id, emit: emit);
  }

  Future<void> _onRetryListingDetailEvent(
    RetryListingDetailEvent event,
    Emitter<ListingDetailState> emit,
  ) {
    return _loadListingDetail(id: event.id, emit: emit);
  }

  void _onClearListingDetailErrorEvent(
    ClearListingDetailErrorEvent event,
    Emitter<ListingDetailState> emit,
  ) {
    emit(state.copyWith(clearErrorMessage: true));
  }

  Future<void> _loadListingDetail({
    required int id,
    required Emitter<ListingDetailState> emit,
  }) async {
    emit(ListingDetailLoadingState(state));
    final cached = _getListingDetailCached;
    if (cached != null) {
      await for (final result in cached(id: id)) {
        if (isClosed) return;
        result.fold(
          (failure) => emit(
            ListingDetailErrorState(state, errorMessage: failure.errorMessage),
          ),
          (event) {
            if (event.data.id != id) return;
            _recordViewOnce(id);
            if (event.origin == PublicDataOrigin.fresh) {
              emit(ListingDetailLoadedState(state, detail: event.data));
            } else {
              emit(
                state.copyWith(
                  detail: event.data,
                  isLoading: false,
                  isFreshDetail: false,
                  errorMessage: event.refreshError?.toString(),
                ),
              );
            }
          },
        );
      }
      return;
    }
    _performanceService.startTrace(kTraceApiGetListingDetail);
    final result = await _getListingDetail(GetListingDetailParams(id: id));

    result.fold(
      (failure) {
        _performanceService.putAttribute(
          kTraceApiGetListingDetail,
          kTraceAttrError,
          failure.errorMessage.truncate(100),
        );
        emit(
          ListingDetailErrorState(state, errorMessage: failure.errorMessage),
        );
      },
      (detail) {
        _recordViewOnce(id);
        _performanceService.putAttribute(
          kTraceApiGetListingDetail,
          kTraceAttrSuccess,
          true,
        );
        emit(ListingDetailLoadedState(state, detail: detail));
      },
    );

    _performanceService.stopTrace(kTraceApiGetListingDetail);
  }
}
