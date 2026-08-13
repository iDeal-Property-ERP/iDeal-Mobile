import 'package:dartz/dartz.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/booking/data/datasources/booking_remote_data_source.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/presentation/booking/domain/repositories/booking_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class BookingRepositoryImpl implements BookingRepository {
  const BookingRepositoryImpl(this._remote);

  final BookingRemoteDataSource _remote;

  @override
  ResultFuture<BookingOptions> getOptions(int listingId) =>
      _run(() => _remote.getOptions(listingId));

  @override
  ResultFuture<BookingQuote> createQuote({
    required int listingId,
    required DateTime startDate,
    required DateTime endDate,
  }) => _run(
    () => _remote.createQuote(
      listingId: listingId,
      startDate: startDate,
      endDate: endDate,
    ),
  );

  @override
  ResultFuture<PaymentCheckout> createCheckout({
    required int quoteId,
    required PaymentProvider provider,
    required bool payFullStay,
    required String idempotencyKey,
  }) => _run(
    () => _remote.createCheckout(
      quoteId: quoteId,
      provider: provider,
      payFullStay: payFullStay,
      idempotencyKey: idempotencyKey,
    ),
  );

  @override
  ResultFuture<BookingDetail> getBooking(int bookingId) =>
      _run(() => _remote.getBooking(bookingId));

  @override
  ResultFuture<List<BookingDetail>> getBookings() => _run(_remote.getBookings);

  Future<Either<Failure, T>> _run<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on APIException catch (error) {
      return Left(APIFailure.fromException(error));
    }
  }
}
