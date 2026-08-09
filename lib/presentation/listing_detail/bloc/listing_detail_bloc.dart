import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/constants/constants.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_event.dart';
import 'package:ideal_mobile/presentation/listing_detail/bloc/listing_detail_state.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/usecases/get_listing_detail.dart';
import 'package:ideal_mobile/services/performance_monitoring_service.dart';
import 'package:ideal_mobile/utils/extensions/primitive_types_extensions.dart';

class ListingDetailBloc extends Bloc<ListingDetailEvent, ListingDetailState> {
  ListingDetailBloc({
    GetListingDetail? getListingDetail,
    PerformanceMonitoringService? performanceService,
  }) : _getListingDetail = getListingDetail ?? sl<GetListingDetail>(),
       _performanceService =
           performanceService ??
           (sl.isRegistered<PerformanceMonitoringService>()
               ? sl<PerformanceMonitoringService>()
               : PerformanceMonitoringService()),
       super(const ListingDetailState.initial()) {
    on<LoadListingDetailEvent>(_onLoadListingDetailEvent);
    on<RetryListingDetailEvent>(_onRetryListingDetailEvent);
    on<ClearListingDetailErrorEvent>(_onClearListingDetailErrorEvent);
  }

  final GetListingDetail _getListingDetail;
  final PerformanceMonitoringService _performanceService;

  Future<void> _onLoadListingDetailEvent(
    LoadListingDetailEvent event,
    Emitter<ListingDetailState> emit,
  ) {
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
