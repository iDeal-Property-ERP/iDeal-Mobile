import 'package:ideal_mobile/utils/currency_converter/domain/entities/currency_rate.dart';
import 'package:ideal_mobile/utils/typedef.dart';

mixin CurrencyConverterRepository {
  ResultFuture<CurrencyRate> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  });
}
