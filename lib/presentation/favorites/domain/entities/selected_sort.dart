/// Ordering applied to the favorites list on the server.
enum SelectedSort {
  recent('recent'),
  priceAsc('price_asc'),
  priceDesc('price_desc');

  const SelectedSort(this.wireValue);

  final String wireValue;
}
