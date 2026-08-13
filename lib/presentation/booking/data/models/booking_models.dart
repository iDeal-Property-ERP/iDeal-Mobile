import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class BookingEligibilityModel {
  const BookingEligibilityModel._();

  static BookingEligibility fromJson(DataMap json) => BookingEligibility(
    eligible: json['eligible'] == true,
    reason: _nullableString(json['reason']),
    minimumStayMonths: _nullableInt(json['minimum_stay_months']) ?? 1,
    earliestStartDate: _nullableDate(json['earliest_start_date']),
    latestEndDate: _nullableDate(json['latest_end_date']),
    blockedRanges: _mapList(json['blocked_ranges'])
        .map(
          (range) => BookingDateRange(
            startDate: _requiredDate(range, 'start_date'),
            endDate: _requiredDate(range, 'end_date'),
          ),
        )
        .toList(growable: false),
    providers: _stringList(json['providers'])
        .map(_paymentProvider)
        .whereType<PaymentProvider>()
        .toList(growable: false),
  );
}

class BookingOptionsModel {
  const BookingOptionsModel._();

  static BookingOptions fromJson(DataMap json) => BookingOptions(
    listingId: _requiredInt(json, 'listing_id'),
    monthlyRent: _requiredDouble(json, 'monthly_rent'),
    depositAmount: _requiredDouble(json, 'deposit_amount'),
    currency: _requiredString(json, 'currency'),
    eligibility: BookingEligibilityModel.fromJson(json),
  );
}

class BookingQuoteModel {
  const BookingQuoteModel._();

  static BookingQuote fromJson(DataMap json) {
    final options = _requiredMap(json, 'options');
    return BookingQuote(
      id: _requiredInt(json, 'id'),
      listingId: _requiredInt(json, 'listing_id'),
      startDate: _requiredDate(json, 'start_date'),
      endDate: _requiredDate(json, 'end_date'),
      currency: _requiredString(json, 'currency'),
      monthlyRent: _requiredDouble(json, 'monthly_rent'),
      depositAmount: _requiredDouble(json, 'deposit_amount'),
      periods: _mapList(json['periods'])
          .map(
            (period) => BookingPeriod(
              startDate: _requiredDate(period, 'start_date'),
              endDate: _requiredDate(period, 'end_date'),
              amount: _requiredDouble(period, 'amount'),
            ),
          )
          .toList(growable: false),
      firstMonth: _paymentOption(_requiredMap(options, 'first_month')),
      fullStay: _paymentOption(_requiredMap(options, 'full_stay')),
      expiresAt: _requiredDateTime(json, 'expires_at'),
    );
  }
}

class PaymentCheckoutModel {
  const PaymentCheckoutModel._();

  static PaymentCheckout fromJson(DataMap json, {int? bookingId}) {
    final rawProvider = _requiredString(json, 'provider');
    final provider = _paymentProvider(rawProvider);
    if (provider == null) throw const FormatException('Invalid provider.');

    return PaymentCheckout(
      bookingId: bookingId ?? _requiredInt(json, 'booking_id'),
      checkoutId: _requiredInt(json, 'checkout_id'),
      publicToken: _requiredString(json, 'public_token'),
      provider: provider,
      status: _checkoutStatus(_requiredString(json, 'status')),
      checkoutUrl: Uri.parse(_requiredString(json, 'checkout_url')),
      expiresAt: _requiredDateTime(json, 'expires_at'),
    );
  }
}

class BookingDetailModel {
  const BookingDetailModel._();

  static BookingDetail fromJson(DataMap json) {
    final listing = _requiredMap(json, 'listing');
    final checkoutJson = _nullableMap(json['checkout']);
    return BookingDetail(
      id: _requiredInt(json, 'id'),
      listing: BookingListingSummary(
        id: _requiredInt(listing, 'id'),
        title: _requiredString(listing, 'title'),
        address: _requiredString(listing, 'address'),
        coverImageUrl: _nullableString(listing['cover_image_url']),
      ),
      startDate: _requiredDate(json, 'start_date'),
      endDate: _requiredDate(json, 'end_date'),
      status: _bookingStatus(_requiredString(json, 'status')),
      amount: _requiredDouble(json, 'amount'),
      currency: _requiredString(json, 'currency'),
      payFullStay: json['pay_full_stay'] == true,
      createdAt: _requiredDateTime(json, 'created_at'),
      checkout: checkoutJson == null
          ? null
          : PaymentCheckoutModel.fromJson(
              checkoutJson,
              bookingId: _requiredInt(json, 'id'),
            ),
    );
  }
}

BookingPaymentOption _paymentOption(DataMap json) => BookingPaymentOption(
  rentAmount: _requiredDouble(json, 'rent_amount'),
  totalAmount: _requiredDouble(json, 'total_amount'),
);

PaymentProvider? _paymentProvider(String value) => switch (value) {
  'payme' => PaymentProvider.payme,
  'click' => PaymentProvider.click,
  'stripe' => PaymentProvider.stripe,
  _ => null,
};

PaymentCheckoutStatus _checkoutStatus(String value) => switch (value) {
  'pending' => PaymentCheckoutStatus.pending,
  'succeeded' => PaymentCheckoutStatus.succeeded,
  'failed' => PaymentCheckoutStatus.failed,
  'expired' => PaymentCheckoutStatus.expired,
  'reconciliation_required' => PaymentCheckoutStatus.reconciliationRequired,
  _ => throw const FormatException('Invalid checkout status.'),
};

BookingStatus _bookingStatus(String value) => switch (value) {
  'requested' => BookingStatus.requested,
  'approved' => BookingStatus.approved,
  'rejected' => BookingStatus.rejected,
  'cancelled' => BookingStatus.cancelled,
  'payment_pending' => BookingStatus.paymentPending,
  'confirmed' => BookingStatus.confirmed,
  'payment_failed' => BookingStatus.paymentFailed,
  'payment_expired' => BookingStatus.paymentExpired,
  'reconciliation_required' => BookingStatus.reconciliationRequired,
  _ => throw const FormatException('Invalid booking status.'),
};

List<DataMap> _mapList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<String>().toList(growable: false);
}

DataMap _requiredMap(DataMap json, String key) {
  final value = _nullableMap(json[key]);
  if (value == null) throw FormatException('Invalid $key.');
  return value;
}

DataMap? _nullableMap(dynamic value) {
  if (value is! Map) return null;
  return Map<String, dynamic>.from(value);
}

String _requiredString(DataMap json, String key) {
  final value = _nullableString(json[key]);
  if (value == null || value.isEmpty) throw FormatException('Invalid $key.');
  return value;
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final result = value.toString().trim();
  return result.isEmpty ? null : result;
}

int _requiredInt(DataMap json, String key) {
  final value = _nullableInt(json[key]);
  if (value == null) throw FormatException('Invalid $key.');
  return value;
}

int? _nullableInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double _requiredDouble(DataMap json, String key) {
  final value = json[key];
  if (value is num) return value.toDouble();
  final parsed = double.tryParse(value?.toString() ?? '');
  if (parsed == null) throw FormatException('Invalid $key.');
  return parsed;
}

DateTime _requiredDate(DataMap json, String key) {
  final value = _nullableDate(json[key]);
  if (value == null) throw FormatException('Invalid $key.');
  return DateTime(value.year, value.month, value.day);
}

DateTime? _nullableDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

DateTime _requiredDateTime(DataMap json, String key) {
  final value = DateTime.tryParse(json[key]?.toString() ?? '');
  if (value == null) throw FormatException('Invalid $key.');
  return value;
}
