import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/notifications/data/models/notifications_page_model.dart';

void main() {
  test('parses a notifications pagination envelope', () {
    final page = NotificationsPageModel.fromJson({
      'success': true,
      'message': 'OK',
      'data': {
        'count': 3,
        'num_pages': 2,
        'per_page': 2,
        'page': {
          'number': 1,
          'object_list': [_notification(1), _notification(2)],
        },
      },
    });

    expect(page.count, 3);
    expect(page.numPages, 2);
    expect(page.perPage, 2);
    expect(page.pageNumber, 1);
    expect(page.items.map((item) => item.id), [1, 2]);
    expect(page.hasMore, isTrue);
  });

  test('reports no more pages on the last page', () {
    final page = NotificationsPageModel.fromJson({
      'data': {
        'count': 1,
        'num_pages': 1,
        'per_page': 20,
        'page': {
          'number': 1,
          'object_list': [_notification(1)],
        },
      },
    });

    expect(page.hasMore, isFalse);
  });

  test('uses an empty item list when object_list is missing', () {
    final page = NotificationsPageModel.fromJson({
      'data': {
        'count': 0,
        'num_pages': 0,
        'per_page': 20,
        'page': {'number': 1},
      },
    });

    expect(page.items, isEmpty);
  });
}

Map<String, dynamic> _notification(int id) => {
  'id': id,
  'type': 'general',
  'category': 'general',
  'title': 'Notice $id',
  'body': null,
  'related_object_type': null,
  'related_object_id': null,
  'is_read': true,
  'read_at': null,
  'created_at': '2026-08-09T10:00:00Z',
  'updated_at': '2026-08-09T10:00:00Z',
};
