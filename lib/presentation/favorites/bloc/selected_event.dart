import 'package:equatable/equatable.dart';

abstract class SelectedEvent extends Equatable {
  const SelectedEvent();
}

class LoadSelectedEvent extends SelectedEvent {
  const LoadSelectedEvent({this.refresh = false});

  final bool refresh;

  @override
  List<Object> get props => [refresh];
}

class LoadMoreSelectedEvent extends SelectedEvent {
  const LoadMoreSelectedEvent();

  @override
  List<Object> get props => [];
}

class ToggleSelectedFavoriteEvent extends SelectedEvent {
  const ToggleSelectedFavoriteEvent(this.listingId);

  final int listingId;

  @override
  List<Object> get props => [listingId];
}

class ClearSelectedFeedbackEvent extends SelectedEvent {
  const ClearSelectedFeedbackEvent();

  @override
  List<Object> get props => [];
}

class ClearSelectedLoadErrorEvent extends SelectedEvent {
  const ClearSelectedLoadErrorEvent();

  @override
  List<Object> get props => [];
}

class SyncSelectedFavoriteEvent extends SelectedEvent {
  const SyncSelectedFavoriteEvent({
    required this.listingId,
    required this.isFavorite,
  });

  final int listingId;
  final bool isFavorite;

  @override
  List<Object> get props => [listingId, isFavorite];
}
