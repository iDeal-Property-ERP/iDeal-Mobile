import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/booking/bloc/booking_bloc.dart';
import 'package:ideal_mobile/presentation/booking/bloc/booking_event.dart';
import 'package:ideal_mobile/presentation/booking/bloc/booking_state.dart';
import 'package:ideal_mobile/presentation/booking/data/active_checkout_store.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/presentation/booking/domain/repositories/booking_repository.dart';
import 'package:mocktail/mocktail.dart';

class _Repository extends Mock implements BookingRepository {}

const _options = BookingOptions(
  listingId: 12,
  monthlyRent: 500,
  depositAmount: 500,
  currency: 'USD',
  eligibility: BookingEligibility(
    eligible: true,
    reason: null,
    minimumStayMonths: 1,
    earliestStartDate: null,
    latestEndDate: null,
    blockedRanges: [],
    providers: [PaymentProvider.payme],
  ),
);

void main() {
  blocTest<BookingBloc, BookingState>(
    'uses a matching seed only until options are freshly confirmed',
    build: () {
      final repository = _Repository();
      when(
        () => repository.getOptions(12),
      ).thenAnswer((_) async => const Right<Failure, BookingOptions>(_options));
      return BookingBloc(
        repository: repository,
        activeCheckoutStore: const ActiveCheckoutStore(),
      );
    },
    act: (bloc) => bloc.add(const BookingStarted(12, initialOptions: _options)),
    expect: () => [
      isA<BookingState>()
          .having((state) => state.options, 'seed shown', _options)
          .having((state) => state.optionsConfirmed, 'writes gated', isFalse),
      isA<BookingState>().having(
        (state) => state.optionsConfirmed,
        'fresh options confirm writes',
        isTrue,
      ),
    ],
  );

  blocTest<BookingBloc, BookingState>(
    'ignores an options seed whose listing ID mismatches the route',
    build: () {
      final repository = _Repository();
      when(
        () => repository.getOptions(12),
      ).thenAnswer((_) async => const Right<Failure, BookingOptions>(_options));
      return BookingBloc(
        repository: repository,
        activeCheckoutStore: const ActiveCheckoutStore(),
      );
    },
    act: (bloc) => bloc.add(
      BookingStarted(
        12,
        initialOptions: BookingOptions(
          listingId: 99,
          monthlyRent: 1,
          depositAmount: 1,
          currency: 'USD',
          eligibility: _options.eligibility,
        ),
      ),
    ),
    expect: () => [
      isA<BookingState>().having(
        (state) => state.status,
        'cold route loads',
        BookingFlowStatus.loading,
      ),
      isA<BookingState>().having(
        (state) => state.options,
        'fresh only',
        _options,
      ),
    ],
  );
}
