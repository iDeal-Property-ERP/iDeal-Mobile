import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';

class ListingMapResult extends Equatable {
  const ListingMapResult({
    required this.items,
    required this.count,
    required this.truncated,
  });

  final List<ListingCard> items;
  final int count;
  final bool truncated;

  @override
  List<Object> get props => [items, count, truncated];
}
