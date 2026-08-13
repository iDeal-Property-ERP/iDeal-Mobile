import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class BookingRepository {
  ResultFuture<BookingOptions> getOptions(int listingId);

  ResultFuture<BookingQuote> createQuote({
    required int listingId,
    required DateTime startDate,
    required DateTime endDate,
  });

  ResultFuture<PaymentCheckout> createCheckout({
    required int quoteId,
    required PaymentProvider provider,
    required bool payFullStay,
    required String idempotencyKey,
  });

  ResultFuture<BookingDetail> getBooking(int bookingId);

  ResultFuture<List<BookingDetail>> getBookings();
}
