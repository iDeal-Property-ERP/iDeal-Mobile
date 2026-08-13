import 'package:dio/dio.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/booking/data/models/booking_models.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class BookingRemoteDataSource {
  Future<BookingOptions> getOptions(int listingId);

  Future<BookingQuote> createQuote({
    required int listingId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<PaymentCheckout> createCheckout({
    required int quoteId,
    required PaymentProvider provider,
    required bool payFullStay,
    required String idempotencyKey,
  });

  Future<BookingDetail> getBooking(int bookingId);

  Future<List<BookingDetail>> getBookings();
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  const BookingRemoteDataSourceImpl(this._dio);

  static const _bookingsPath = '/mobile/bookings/';

  final Dio _dio;

  @override
  Future<BookingOptions> getOptions(int listingId) async {
    final response = await _request(
      () => _dio.get('/mobile/home/listings/$listingId/booking-options/'),
    );
    return _parse(response, BookingOptionsModel.fromJson);
  }

  @override
  Future<BookingQuote> createQuote({
    required int listingId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _request(
      () => _dio.post(
        '${_bookingsPath}quotes/',
        data: {
          'listing_id': listingId,
          'start_date': _date(startDate),
          'end_date': _date(endDate),
        },
      ),
    );
    return _parse(response, BookingQuoteModel.fromJson);
  }

  @override
  Future<PaymentCheckout> createCheckout({
    required int quoteId,
    required PaymentProvider provider,
    required bool payFullStay,
    required String idempotencyKey,
  }) async {
    final response = await _request(
      () => _dio.post(
        '${_bookingsPath}checkouts/',
        data: {
          'quote_id': quoteId,
          'provider': provider.name,
          'pay_full_stay': payFullStay,
        },
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      ),
    );
    return _parse(response, PaymentCheckoutModel.fromJson);
  }

  @override
  Future<BookingDetail> getBooking(int bookingId) async {
    final response = await _request(
      () => _dio.get('$_bookingsPath$bookingId/'),
    );
    return _parse(response, BookingDetailModel.fromJson);
  }

  @override
  Future<List<BookingDetail>> getBookings() async {
    final response = await _request(() => _dio.get(_bookingsPath));
    final value = _data(response);
    if (value is! List) {
      throw APIException(
        message: 'Bookings were not returned.',
        statusCode: response.statusCode ?? 500,
      );
    }
    try {
      return value
          .whereType<Map>()
          .map(
            (item) =>
                BookingDetailModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    } on FormatException catch (error) {
      throw APIException(
        message: error.message,
        statusCode: response.statusCode ?? 500,
      );
    }
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw APIException(
        message:
            _message(error.response?.data) ??
            error.message ??
            'Request failed.',
        statusCode: error.response?.statusCode ?? 505,
      );
    } catch (error) {
      if (error is APIException) rethrow;
      throw APIException(message: error.toString(), statusCode: 505);
    }
  }

  T _parse<T>(Response<dynamic> response, T Function(DataMap) parser) {
    final value = _data(response);
    if (value is! Map) {
      throw APIException(
        message: 'Response data was not returned.',
        statusCode: response.statusCode ?? 500,
      );
    }
    try {
      return parser(Map<String, dynamic>.from(value));
    } on FormatException catch (error) {
      throw APIException(
        message: error.message,
        statusCode: response.statusCode ?? 500,
      );
    }
  }

  dynamic _data(Response<dynamic> response) {
    final body = response.data;
    if (body is! Map || body['success'] != true) {
      throw APIException(
        message: _message(body) ?? 'Request failed.',
        statusCode: response.statusCode ?? 500,
      );
    }
    return body['data'];
  }

  String? _message(dynamic value) {
    if (value is! Map) return value?.toString();
    final message = value['message'];
    return message is String && message.trim().isNotEmpty ? message : null;
  }
}

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
