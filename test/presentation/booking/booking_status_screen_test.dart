import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/booking/booking_status_screen.dart';
import 'package:ideal_mobile/presentation/booking/data/active_checkout_store.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/presentation/booking/domain/repositories/booking_repository.dart';
import 'package:ideal_mobile/presentation/booking/widgets/booking_status_view.dart';
import 'package:mocktail/mocktail.dart';

import '../../test_helpers.dart';

class _Repository extends Mock implements BookingRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Repository repository;
  late Completer<Either<Failure, BookingDetail>> bookingRequest;

  setUp(() async {
    await sl.reset();
    repository = _Repository();
    bookingRequest = Completer<Either<Failure, BookingDetail>>();
    when(
      () => repository.getBooking(any()),
    ).thenAnswer((_) => bookingRequest.future);
    sl
      ..registerSingleton<BookingRepository>(repository)
      ..registerSingleton<ActiveCheckoutStore>(const ActiveCheckoutStore());
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets(
    'shows a matching checkout seed while the authoritative booking is pending',
    (tester) async {
      await tester.runWidgetTest(
        child: BookingStatusScreen(
          bookingId: 12,
          initialCheckout: _checkout(bookingId: 12),
        ),
      );
      await tester.pump();

      expect(find.byType(BookingStatusView), findsOneWidget);
      expect(find.text('Checking your payment'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      verify(() => repository.getBooking(12)).called(1);
    },
  );

  testWidgets('does not render a checkout seed for a different booking', (
    tester,
  ) async {
    await tester.runWidgetTest(
      child: BookingStatusScreen(
        bookingId: 12,
        initialCheckout: _checkout(bookingId: 99),
      ),
    );
    await tester.pump();

    expect(find.byType(BookingStatusView), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    verify(() => repository.getBooking(12)).called(1);
  });
}

PaymentCheckout _checkout({required int bookingId}) => PaymentCheckout(
  bookingId: bookingId,
  checkoutId: 7,
  publicToken: 'checkout-token',
  provider: PaymentProvider.payme,
  status: PaymentCheckoutStatus.pending,
  checkoutUrl: Uri.parse('https://pay.test/checkout'),
  expiresAt: DateTime(2026, 9, 1),
);
