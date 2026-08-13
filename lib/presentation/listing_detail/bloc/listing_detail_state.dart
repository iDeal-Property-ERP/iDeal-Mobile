import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';

class ListingDetailState extends Equatable {
  const ListingDetailState({
    this.detail,
    this.preview,
    this.isFreshDetail = false,
    this.isLoading = false,
    this.errorMessage,
  });

  const ListingDetailState.initial() : this();

  ListingDetailState.copy(ListingDetailState state)
    : detail = state.detail,
      preview = state.preview,
      isFreshDetail = state.isFreshDetail,
      isLoading = state.isLoading,
      errorMessage = state.errorMessage;

  final ListingDetail? detail;

  /// The feed data used while the authoritative detail request is in flight.
  final ListingCard? preview;
  final bool isFreshDetail;
  final bool isLoading;
  final String? errorMessage;

  ListingDetailState copyWith({
    ListingDetail? detail,
    ListingCard? preview,
    bool? isFreshDetail,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ListingDetailState(
      detail: detail ?? this.detail,
      preview: preview ?? this.preview,
      isFreshDetail: isFreshDetail ?? this.isFreshDetail,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @visibleForTesting
  const ListingDetailState.test({
    this.detail,
    this.preview,
    this.isFreshDetail = false,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    detail,
    preview,
    isFreshDetail,
    isLoading,
    errorMessage,
  ];
}

class ListingDetailLoadingState extends ListingDetailState {
  ListingDetailLoadingState(ListingDetailState state)
    : super.copy(state.copyWith(isLoading: true, clearErrorMessage: true));
}

class ListingDetailLoadedState extends ListingDetailState {
  ListingDetailLoadedState(
    ListingDetailState state, {
    required ListingDetail detail,
  }) : super.copy(
         state.copyWith(
           detail: detail,
           isFreshDetail: true,
           isLoading: false,
           clearErrorMessage: true,
         ),
       );
}

class ListingDetailErrorState extends ListingDetailState {
  ListingDetailErrorState(
    ListingDetailState state, {
    required String errorMessage,
  }) : super.copy(state.copyWith(isLoading: false, errorMessage: errorMessage));
}
