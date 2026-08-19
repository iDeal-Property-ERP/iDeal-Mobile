import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/booking/bloc/bookings_cubit.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/presentation/booking/domain/repositories/booking_repository.dart';
import 'package:mocktail/mocktail.dart';

class _Repository extends Mock implements BookingRepository {}

BookingDetail _booking(int id) => BookingDetail(
  id: id,
  listing: const BookingListingSummary(
    id: 12,
    title: 'Cozy apartment',
    address: 'Tashkent, Yunusabad',
    coverImageUrl: null,
  ),
  startDate: DateTime(2026, 5, 12),
  endDate: DateTime(2026, 8, 30),
  status: BookingStatus.confirmed,
  amount: 1500,
  currency: 'USD',
  payFullStay: false,
  createdAt: DateTime(2026, 5, 10),
  checkout: null,
);

void main() {
  late _Repository repository;

  setUp(() {
    repository = _Repository();
  });

  blocTest<BookingsCubit, BookingsState>(
    'emits loading and then bookings on success',
    build: () {
      when(
        () => repository.getBookings(),
      ).thenAnswer((_) async => Right([_booking(1), _booking(2)]));
      return BookingsCubit(repository: repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<BookingsState>()
          .having((state) => state.isLoading, 'isLoading', isTrue)
          .having((state) => state.errorMessage, 'error cleared', isNull),
      isA<BookingsState>()
          .having((state) => state.isLoading, 'isLoading', isFalse)
          .having((state) => state.errorMessage, 'error', isNull)
          .having((state) => state.bookings.length, 'bookings', 2),
    ],
  );

  blocTest<BookingsCubit, BookingsState>(
    'emits the failure message when loading fails',
    build: () {
      when(() => repository.getBookings()).thenAnswer(
        (_) async =>
            const Left(APIFailure(message: 'server exploded', statusCode: 500)),
      );
      return BookingsCubit(repository: repository);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<BookingsState>().having(
        (state) => state.isLoading,
        'isLoading',
        isTrue,
      ),
      isA<BookingsState>()
          .having((state) => state.isLoading, 'isLoading', isFalse)
          .having((state) => state.errorMessage, 'error', contains('500'))
          .having((state) => state.bookings, 'bookings', isEmpty),
    ],
  );

  blocTest<BookingsCubit, BookingsState>(
    'keeps previously loaded bookings when a reload fails',
    build: () {
      when(() => repository.getBookings()).thenAnswer(
        (_) async => const Left(APIFailure(message: 'offline', statusCode: 0)),
      );
      return BookingsCubit(repository: repository);
    },
    seed: () => BookingsState(isLoading: false, bookings: [_booking(1)]),
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<BookingsState>().having(
        (state) => state.isLoading,
        'isLoading',
        isTrue,
      ),
      isA<BookingsState>()
          .having((state) => state.bookings.length, 'bookings kept', 1)
          .having((state) => state.errorMessage, 'error', isNotNull),
    ],
  );
}
