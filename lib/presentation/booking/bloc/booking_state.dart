import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';

enum BookingFlowStatus {
  initial,
  loading,
  ready,
  quoting,
  quoted,
  creatingCheckout,
  checkoutReady,
  polling,
  confirmed,
  failed,
  expired,
  reconciliationRequired,
  error,
}

class BookingState extends Equatable {
  const BookingState({
    this.status = BookingFlowStatus.initial,
    this.listingId,
    this.options,
    this.optionsConfirmed = false,
    this.range,
    this.quote,
    this.paymentChoice = BookingPaymentChoice.firstMonth,
    this.provider,
    this.checkout,
    this.booking,
    this.errorMessage,
  });

  final BookingFlowStatus status;
  final int? listingId;
  final BookingOptions? options;
  final bool optionsConfirmed;
  final BookingDateRange? range;
  final BookingQuote? quote;
  final BookingPaymentChoice paymentChoice;
  final PaymentProvider? provider;
  final PaymentCheckout? checkout;
  final BookingDetail? booking;
  final String? errorMessage;

  bool get isBusy =>
      status == BookingFlowStatus.loading ||
      status == BookingFlowStatus.quoting ||
      status == BookingFlowStatus.creatingCheckout ||
      status == BookingFlowStatus.polling;

  BookingState copyWith({
    BookingFlowStatus? status,
    int? listingId,
    BookingOptions? options,
    bool? optionsConfirmed,
    BookingDateRange? range,
    BookingQuote? quote,
    BookingPaymentChoice? paymentChoice,
    PaymentProvider? provider,
    PaymentCheckout? checkout,
    BookingDetail? booking,
    String? errorMessage,
    bool clearQuote = false,
    bool clearError = false,
  }) => BookingState(
    status: status ?? this.status,
    listingId: listingId ?? this.listingId,
    options: options ?? this.options,
    optionsConfirmed: optionsConfirmed ?? this.optionsConfirmed,
    range: range ?? this.range,
    quote: clearQuote ? null : quote ?? this.quote,
    paymentChoice: paymentChoice ?? this.paymentChoice,
    provider: provider ?? this.provider,
    checkout: checkout ?? this.checkout,
    booking: booking ?? this.booking,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    listingId,
    options,
    optionsConfirmed,
    range,
    quote,
    paymentChoice,
    provider,
    checkout,
    booking,
    errorMessage,
  ];
}
