import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/booking/data/active_checkout_store.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  const store = ActiveCheckoutStore();
  final checkout = PaymentCheckout(
    bookingId: 12,
    checkoutId: 7,
    publicToken: 'token',
    provider: PaymentProvider.payme,
    status: PaymentCheckoutStatus.pending,
    checkoutUrl: Uri.parse('https://pay.test/checkout'),
    expiresAt: DateTime(2026, 9),
  );

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({});
    Prefs.init();
  });

  test('round-trips enough checkout data for a pending status seed', () async {
    await store.save(checkout);
    final active = await store.read();
    expect(active?.checkout, checkout);
  });

  test(
    'malformed checkout falls back safely while legacy remains pollable',
    () async {
      await Prefs.setString('booking.active_checkout', '{not-json');
      expect(await store.read(), isNull);
      await Prefs.setString(
        'booking.active_checkout',
        '{"booking_id":12,"public_token":"token"}',
      );
      final legacy = await store.read();
      expect(legacy?.bookingId, 12);
      expect(legacy?.publicToken, 'token');
      expect(legacy?.checkout, isNull);
    },
  );
}
