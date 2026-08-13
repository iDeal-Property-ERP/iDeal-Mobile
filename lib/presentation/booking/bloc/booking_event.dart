import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class BookingStarted extends BookingEvent {
  const BookingStarted(this.listingId, {this.initialOptions});

  final int listingId;
  final BookingOptions? initialOptions;

  @override
  List<Object?> get props => [listingId, initialOptions];
}

class BookingRangeChanged extends BookingEvent {
  const BookingRangeChanged(this.range);

  final BookingDateRange range;

  @override
  List<Object> get props => [range];
}

class BookingPaymentChoiceChanged extends BookingEvent {
  const BookingPaymentChoiceChanged(this.choice);

  final BookingPaymentChoice choice;

  @override
  List<Object> get props => [choice];
}

class BookingProviderChanged extends BookingEvent {
  const BookingProviderChanged(this.provider);

  final PaymentProvider provider;

  @override
  List<Object> get props => [provider];
}

class BookingQuoteRequested extends BookingEvent {
  const BookingQuoteRequested();
}

class BookingCheckoutRequested extends BookingEvent {
  const BookingCheckoutRequested();
}

class BookingStatusRequested extends BookingEvent {
  const BookingStatusRequested(this.bookingId);

  final int bookingId;

  @override
  List<Object> get props => [bookingId];
}
