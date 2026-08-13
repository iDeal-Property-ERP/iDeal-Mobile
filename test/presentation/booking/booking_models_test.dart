import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/booking/bloc/booking_state.dart';
import 'package:ideal_mobile/presentation/booking/data/models/booking_models.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';

void main() {
  test('booking eligibility parses providers and inclusive blocked ranges', () {
    final eligibility = BookingEligibilityModel.fromJson({
      'eligible': true,
      'reason': null,
      'minimum_stay_months': 1,
      'earliest_start_date': '2026-09-01',
      'latest_end_date': '2027-08-31',
      'blocked_ranges': [
        {'start_date': '2026-09-15', 'end_date': '2026-09-18'},
      ],
      'providers': ['payme', 'click', 'stripe'],
    });

    expect(eligibility.providers, PaymentProvider.values);
    expect(eligibility.isBlocked(DateTime(2026, 9, 15)), isTrue);
    expect(eligibility.isBlocked(DateTime(2026, 9, 18)), isTrue);
    expect(eligibility.isBlocked(DateTime(2026, 9, 19)), isFalse);
  });

  test('quote exposes only server-calculated payment options', () {
    final quote = BookingQuoteModel.fromJson({
      'id': 7,
      'listing_id': 12,
      'start_date': '2026-09-10',
      'end_date': '2026-12-09',
      'currency': 'USD',
      'monthly_rent': '850.00',
      'deposit_amount': '850.00',
      'periods': [
        {
          'start_date': '2026-09-10',
          'end_date': '2026-10-09',
          'amount': '850.00',
        },
      ],
      'options': {
        'first_month': {'rent_amount': '850.00', 'total_amount': '1700.00'},
        'full_stay': {'rent_amount': '2550.00', 'total_amount': '3400.00'},
      },
      'expires_at': '2026-08-12T12:10:00Z',
    });

    expect(quote.firstMonth.totalAmount, 1700);
    expect(quote.fullStay.totalAmount, 3400);
    expect(quote.periods.single.amount, 850);
  });

  test('first-month payment is the default choice', () {
    expect(const BookingState().paymentChoice, BookingPaymentChoice.firstMonth);
  });
}
