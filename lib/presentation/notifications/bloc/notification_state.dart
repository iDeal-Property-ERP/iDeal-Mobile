import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/notifications/domain/entities/app_notification.dart';

class NotificationState extends Equatable {
  const NotificationState({
    this.items = const [],
    this.page = 1,
    this.numPages = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.errorMessage,
  });

  final List<AppNotification> items;
  final int page;
  final int numPages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String? errorMessage;

  NotificationState copyWith({
    List<AppNotification>? items,
    int? page,
    int? numPages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return NotificationState(
      items: items ?? this.items,
      page: page ?? this.page,
      numPages: numPages ?? this.numPages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    items,
    page,
    numPages,
    isLoading,
    isLoadingMore,
    hasReachedMax,
    errorMessage,
  ];
}
