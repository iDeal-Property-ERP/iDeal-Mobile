String formatListingMapPrice(double? price, String currency) {
  if (price == null) return '—';
  final amount = price == price.roundToDouble()
      ? price.toInt().toString()
      : price
            .toStringAsFixed(2)
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '');
  return switch (currency.trim().toUpperCase()) {
    'USD' => '\$$amount',
    'EUR' => '€$amount',
    'GBP' => '£$amount',
    'RUB' => '₽$amount',
    final code when code.isNotEmpty => '$amount $code',
    _ => amount,
  };
}
