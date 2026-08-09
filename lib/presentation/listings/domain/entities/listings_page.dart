import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';

class ListingsPage extends Equatable {
  const ListingsPage({
    required this.items,
    required this.count,
    required this.numPages,
    required this.perPage,
    required this.pageNumber,
  });

  final List<ListingCard> items;
  final int count;
  final int numPages;
  final int perPage;
  final int pageNumber;

  bool get hasMore => pageNumber < numPages;

  @override
  List<Object> get props => [items, count, numPages, perPage, pageNumber];
}
