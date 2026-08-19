import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/presentation/booking/domain/repositories/booking_repository.dart';

class BookingsState extends Equatable {
  const BookingsState({
    this.isLoading = true,
    this.bookings = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final List<BookingDetail> bookings;
  final String? errorMessage;

  BookingsState copyWith({
    bool? isLoading,
    List<BookingDetail>? bookings,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return BookingsState(
      isLoading: isLoading ?? this.isLoading,
      bookings: bookings ?? this.bookings,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, bookings, errorMessage];
}

class BookingsCubit extends Cubit<BookingsState> {
  BookingsCubit({BookingRepository? repository})
    : _repository = repository ?? sl<BookingRepository>(),
      super(const BookingsState());

  final BookingRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));
    final result = await _repository.getBookings();
    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, errorMessage: failure.errorMessage),
      ),
      (bookings) => emit(
        state.copyWith(
          isLoading: false,
          bookings: bookings,
          clearErrorMessage: true,
        ),
      ),
    );
  }
}
