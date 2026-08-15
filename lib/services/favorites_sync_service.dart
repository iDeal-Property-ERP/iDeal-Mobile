import 'dart:async';

class FavoriteStatusChange {
  const FavoriteStatusChange({
    required this.listingId,
    required this.isFavorite,
  });

  final int listingId;
  final bool isFavorite;
}

class FavoritesSyncService {
  FavoritesSyncService();

  final StreamController<FavoriteStatusChange> _controller =
      StreamController<FavoriteStatusChange>.broadcast();

  Stream<FavoriteStatusChange> get stream => _controller.stream;

  void publish(FavoriteStatusChange change) {
    if (_controller.isClosed) return;
    _controller.add(change);
  }
}
