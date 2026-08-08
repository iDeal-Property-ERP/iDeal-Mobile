import 'package:ideal_mobile/utils/currency_converter/data/models/currency_rate_model.dart';
import 'package:ideal_mobile/utils/typedef.dart';

const CurrencyRateModel sampleCurrencyRateData = CurrencyRateModel(
  amount: 1.0,
  base: 'USD',
  date: '2024-12-08',
  rates: {
    'AUD': 1.7546,
    'BGN': 1.9558,
    'BRL': 6.185,
    'CAD': 1.623,
    'CHF': 0.9365,
    'CNY': 8.2333,
    'CZK': 24.21,
    'DKK': 7.4689,
    'GBP': 0.8727,
    'HKD': 9.0652,
    'HUF': 381.78,
    'IDR': 19414,
    'ILS': 3.7632,
    'INR': 104.73,
    'ISK': 148.8,
    'JPY': 180.76,
    'KRW': 1714.82,
    'MXN': 21.191,
    'MYR': 4.7873,
    'NOK': 11.755,
    'NZD': 2.0158,
    'PHP': 68.719,
    'PLN': 4.2323,
    'RON': 5.0928,
    'SEK': 10.959,
    'SGD': 1.5084,
    'THB': 37.095,
    'TRY': 49.507,
    'USD': 1.1645,
    'ZAR': 19.7169,
  },
);

CurrencyRateModel getSampleCurrencyRate({
  String base = 'USD',
  DataMap? specificRates,
}) {
  return CurrencyRateModel(
    amount: 1.0,
    base: base,
    date: '2024-12-08',
    rates: specificRates != null
        ? Map<String, double>.from(specificRates)
        : sampleCurrencyRateData.rates,
  );
}
