import 'package:equatable/equatable.dart';

class CurrencyRate extends Equatable {
  const CurrencyRate({
    required this.amount,
    required this.base,
    required this.date,
    required this.rates,
  });

  final double amount;
  final String base;
  final String date;
  final Map<String, double> rates;

  @override
  List<Object> get props => [amount, base, date, rates];
}
