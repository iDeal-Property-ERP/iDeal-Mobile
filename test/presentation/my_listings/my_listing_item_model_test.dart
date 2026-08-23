import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/my_listings/data/models/my_listing_item_model.dart';

void main() {
  test('retains all responsive cover image URLs from the My Listings API', () {
    final item = MyListingItemModel.fromJson({
      'id': 42,
      'property_id': 7,
      'title': 'My home',
      'status': 'approved',
      'status_display': 'Approved',
      'cover_image_url': 'https://cdn.example/original.jpg',
      'cover_preview_url': 'https://cdn.example/preview.webp',
      'cover_display_url': 'https://cdn.example/display.webp',
    });

    expect(item.coverImageUrl, 'https://cdn.example/original.jpg');
    expect(item.coverPreviewUrl, 'https://cdn.example/preview.webp');
    expect(item.coverDisplayUrl, 'https://cdn.example/display.webp');
  });
}
