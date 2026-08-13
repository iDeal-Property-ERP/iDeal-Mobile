import 'dart:convert';

import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';

class ActiveCheckoutStore {
  const ActiveCheckoutStore();

  static const _key = 'booking.active_checkout';

  Future<void> save(PaymentCheckout checkout) => Prefs.setString(
    _key,
    jsonEncode({
      'booking_id': checkout.bookingId,
      'public_token': checkout.publicToken,
      'checkout_id': checkout.checkoutId,
      'provider': checkout.provider.name,
      'status': checkout.status.name,
      'checkout_url': checkout.checkoutUrl.toString(),
      'expires_at': checkout.expiresAt.toIso8601String(),
    }),
  );

  Future<ActiveCheckout?> read() async {
    final encoded = await Prefs.getString(_key);
    if (encoded == null) return null;
    try {
      final json = jsonDecode(encoded);
      if (json is! Map) return null;
      final bookingId = json['booking_id'];
      final token = json['public_token'];
      final checkoutId = json['checkout_id'];
      final provider = json['provider'];
      final status = json['status'];
      final url = json['checkout_url'];
      final expiresAt = json['expires_at'];
      if (bookingId is! int || token is! String || token.isEmpty) return null;
      if (checkoutId is! int ||
          provider is! String ||
          status is! String ||
          url is! String ||
          expiresAt is! String) {
        return ActiveCheckout.legacy(bookingId: bookingId, publicToken: token);
      }
      final paymentProvider = PaymentProvider.values.byName(provider);
      final checkoutStatus = PaymentCheckoutStatus.values.byName(status);
      return ActiveCheckout(
        checkout: PaymentCheckout(
          bookingId: bookingId,
          checkoutId: checkoutId,
          publicToken: token,
          provider: paymentProvider,
          status: checkoutStatus,
          checkoutUrl: Uri.parse(url),
          expiresAt: DateTime.parse(expiresAt),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() => Prefs.remove(_key);
}

class ActiveCheckout {
  ActiveCheckout({required PaymentCheckout checkout})
    : checkout = checkout,
      bookingId = checkout.bookingId,
      publicToken = checkout.publicToken;
  const ActiveCheckout.legacy({
    required this.bookingId,
    required this.publicToken,
  }) : checkout = null;

  final PaymentCheckout? checkout;
  final int bookingId;
  final String publicToken;
}
