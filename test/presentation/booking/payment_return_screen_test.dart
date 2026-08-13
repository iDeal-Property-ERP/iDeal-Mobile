import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/booking/data/active_checkout_store.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/presentation/booking/payment_return_screen.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:mocktail/mocktail.dart';

import '../../test_helpers.dart';

class _ActiveCheckoutStore extends Mock implements ActiveCheckoutStore {}

class _StackRouter extends Mock implements StackRouter {}

class _PageRouteInfo extends Fake implements PageRouteInfo<Object?> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _ActiveCheckoutStore checkoutStore;
  late _StackRouter router;

  setUpAll(() {
    registerFallbackValue(_PageRouteInfo());
  });

  setUp(() async {
    await sl.reset();
    checkoutStore = _ActiveCheckoutStore();
    router = _StackRouter();
    when(() => router.replace(any())).thenAnswer((_) async => null);
    sl.registerSingleton<ActiveCheckoutStore>(checkoutStore);
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('routes a matching full checkout to its seeded booking status', (
    tester,
  ) async {
    final checkout = _checkout();
    when(
      () => checkoutStore.read(),
    ).thenAnswer((_) async => ActiveCheckout(checkout: checkout));

    await _pumpReturnScreen(
      tester,
      router,
      checkoutToken: checkout.publicToken,
    );

    final route = _redirectedStatusRoute(router);
    expect(route.args?.bookingId, checkout.bookingId);
    expect(route.args?.initialCheckout, checkout);
  });

  testWidgets('routes a matching legacy checkout without a seed', (
    tester,
  ) async {
    when(() => checkoutStore.read()).thenAnswer(
      (_) async => const ActiveCheckout.legacy(
        bookingId: 12,
        publicToken: 'legacy-token',
      ),
    );

    await _pumpReturnScreen(tester, router, checkoutToken: 'legacy-token');

    final route = _redirectedStatusRoute(router);
    expect(route.args?.bookingId, 12);
    expect(route.args?.initialCheckout, isNull);
  });

  testWidgets('shows the unverified state when the return token mismatches', (
    tester,
  ) async {
    when(
      () => checkoutStore.read(),
    ).thenAnswer((_) async => ActiveCheckout(checkout: _checkout()));

    await _pumpReturnScreen(tester, router, checkoutToken: 'other-token');

    expect(
      find.text(
        'We could not match this return link to an active checkout. '
        'The link itself is not proof of payment.',
      ),
      findsOneWidget,
    );
    verifyNever(() => router.replace(any()));
  });
}

Future<void> _pumpReturnScreen(
  WidgetTester tester,
  StackRouter router, {
  required String checkoutToken,
}) async {
  await tester.runWidgetTest(
    child: StackRouterScope(
      controller: router,
      stateHash: 0,
      child: PaymentReturnScreen(checkoutToken: checkoutToken),
    ),
  );
  await tester.pump();
  await tester.pump();
}

BookingStatusRoute _redirectedStatusRoute(_StackRouter router) {
  final redirect = verify(() => router.replace(captureAny())).captured.single;
  return redirect as BookingStatusRoute;
}

PaymentCheckout _checkout() => PaymentCheckout(
  bookingId: 12,
  checkoutId: 7,
  publicToken: 'checkout-token',
  provider: PaymentProvider.payme,
  status: PaymentCheckoutStatus.pending,
  checkoutUrl: Uri.parse('https://pay.test/checkout'),
  expiresAt: DateTime(2026, 9, 1),
);
