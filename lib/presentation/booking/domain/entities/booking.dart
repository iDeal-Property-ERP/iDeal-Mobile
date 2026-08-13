import 'package:equatable/equatable.dart';

enum PaymentProvider { payme, click, stripe }

enum BookingPaymentChoice { firstMonth, fullStay }

class BookingDateRange extends Equatable {
  const BookingDateRange({required this.startDate, required this.endDate});

  final DateTime startDate;
  final DateTime endDate;

  bool contains(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return !date.isBefore(startDate) && !date.isAfter(endDate);
  }

  @override
  List<Object> get props => [startDate, endDate];
}

class BookingEligibility extends Equatable {
  const BookingEligibility({
    required this.eligible,
    required this.reason,
    required this.minimumStayMonths,
    required this.earliestStartDate,
    required this.latestEndDate,
    required this.blockedRanges,
    required this.providers,
  });

  const BookingEligibility.ineligible({String? reason})
    : this(
        eligible: false,
        reason: reason,
        minimumStayMonths: 1,
        earliestStartDate: null,
        latestEndDate: null,
        blockedRanges: const [],
        providers: const [],
      );

  final bool eligible;
  final String? reason;
  final int minimumStayMonths;
  final DateTime? earliestStartDate;
  final DateTime? latestEndDate;
  final List<BookingDateRange> blockedRanges;
  final List<PaymentProvider> providers;

  bool isBlocked(DateTime day) => blockedRanges.any(
    (range) => range.contains(DateTime(day.year, day.month, day.day)),
  );

  @override
  List<Object?> get props => [
    eligible,
    reason,
    minimumStayMonths,
    earliestStartDate,
    latestEndDate,
    blockedRanges,
    providers,
  ];
}

class BookingOptions extends Equatable {
  const BookingOptions({
    required this.listingId,
    required this.monthlyRent,
    required this.depositAmount,
    required this.currency,
    required this.eligibility,
  });

  final int listingId;
  final double monthlyRent;
  final double depositAmount;
  final String currency;
  final BookingEligibility eligibility;

  @override
  List<Object> get props => [
    listingId,
    monthlyRent,
    depositAmount,
    currency,
    eligibility,
  ];
}

class BookingPeriod extends Equatable {
  const BookingPeriod({
    required this.startDate,
    required this.endDate,
    required this.amount,
  });

  final DateTime startDate;
  final DateTime endDate;
  final double amount;

  @override
  List<Object> get props => [startDate, endDate, amount];
}

class BookingPaymentOption extends Equatable {
  const BookingPaymentOption({
    required this.rentAmount,
    required this.totalAmount,
  });

  final double rentAmount;
  final double totalAmount;

  @override
  List<Object> get props => [rentAmount, totalAmount];
}

class BookingQuote extends Equatable {
  const BookingQuote({
    required this.id,
    required this.listingId,
    required this.startDate,
    required this.endDate,
    required this.currency,
    required this.monthlyRent,
    required this.depositAmount,
    required this.periods,
    required this.firstMonth,
    required this.fullStay,
    required this.expiresAt,
  });

  final int id;
  final int listingId;
  final DateTime startDate;
  final DateTime endDate;
  final String currency;
  final double monthlyRent;
  final double depositAmount;
  final List<BookingPeriod> periods;
  final BookingPaymentOption firstMonth;
  final BookingPaymentOption fullStay;
  final DateTime expiresAt;

  @override
  List<Object> get props => [
    id,
    listingId,
    startDate,
    endDate,
    currency,
    monthlyRent,
    depositAmount,
    periods,
    firstMonth,
    fullStay,
    expiresAt,
  ];
}

enum PaymentCheckoutStatus {
  pending,
  succeeded,
  failed,
  expired,
  reconciliationRequired,
}

class PaymentCheckout extends Equatable {
  const PaymentCheckout({
    required this.bookingId,
    required this.checkoutId,
    required this.publicToken,
    required this.provider,
    required this.status,
    required this.checkoutUrl,
    required this.expiresAt,
  });

  final int bookingId;
  final int checkoutId;
  final String publicToken;
  final PaymentProvider provider;
  final PaymentCheckoutStatus status;
  final Uri checkoutUrl;
  final DateTime expiresAt;

  @override
  List<Object> get props => [
    bookingId,
    checkoutId,
    publicToken,
    provider,
    status,
    checkoutUrl,
    expiresAt,
  ];
}

enum BookingStatus {
  requested,
  approved,
  rejected,
  cancelled,
  paymentPending,
  confirmed,
  paymentFailed,
  paymentExpired,
  reconciliationRequired,
}

class BookingListingSummary extends Equatable {
  const BookingListingSummary({
    required this.id,
    required this.title,
    required this.address,
    required this.coverImageUrl,
  });

  final int id;
  final String title;
  final String address;
  final String? coverImageUrl;

  @override
  List<Object?> get props => [id, title, address, coverImageUrl];
}

class BookingDetail extends Equatable {
  const BookingDetail({
    required this.id,
    required this.listing,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.amount,
    required this.currency,
    required this.payFullStay,
    required this.createdAt,
    required this.checkout,
  });

  final int id;
  final BookingListingSummary listing;
  final DateTime startDate;
  final DateTime endDate;
  final BookingStatus status;
  final double amount;
  final String currency;
  final bool payFullStay;
  final DateTime createdAt;
  final PaymentCheckout? checkout;

  @override
  List<Object?> get props => [
    id,
    listing,
    startDate,
    endDate,
    status,
    amount,
    currency,
    payFullStay,
    createdAt,
    checkout,
  ];
}
