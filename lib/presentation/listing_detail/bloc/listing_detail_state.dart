import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';

class ListingDetailState extends Equatable {
  const ListingDetailState({
    this.detail,
    this.isLoading = false,
    this.errorMessage,
  });

  const ListingDetailState.initial() : this();

  ListingDetailState.copy(ListingDetailState state)
    : detail = state.detail,
      isLoading = state.isLoading,
      errorMessage = state.errorMessage;

  final ListingDetail? detail;
  final bool isLoading;
  final String? errorMessage;

  ListingDetailState copyWith({
    ListingDetail? detail,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ListingDetailState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @visibleForTesting
  const ListingDetailState.test({
    this.detail,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [detail, isLoading, errorMessage];
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
