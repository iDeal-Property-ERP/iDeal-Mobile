import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/listings/data/models/home_banner_model.dart';

void main() {
  group('HomeBannerModel', () {
    test('parses from valid JSON correctly', () {
      final json = {
        'id': 1,
        'title': '100% Actual Listings',
        'description': 'Whatever you see is available.',
        'icon': 'circle_check',
        'tag': 'iDeal Guarantee',
        'sort_order': 1,
      };

      final model = HomeBannerModel.fromJson(json);

      expect(model.id, 1);
      expect(model.title, '100% Actual Listings');
      expect(model.description, 'Whatever you see is available.');
      expect(model.icon, TablerIcons.circle_check);
      expect(model.tag, 'iDeal Guarantee');
      expect(model.sortOrder, 1);
    });

    test('handles nullable tag and fallback icon', () {
      final json = {
        'id': 2,
        'title': 'Custom Title',
        'description': 'Custom Description',
        'icon': 'unknown_icon',
        'tag': null,
        'sort_order': 2,
      };

      final model = HomeBannerModel.fromJson(json);

      expect(model.id, 2);
      expect(model.title, 'Custom Title');
      expect(model.tag, isNull);
      expect(model.icon, TablerIcons.circle_check);
      expect(model.sortOrder, 2);
    });

    test('resolves known icon strings to TablerIcons', () {
      expect(
        HomeBannerModel.resolveIcon('circle_check'),
        TablerIcons.circle_check,
      );
      expect(
        HomeBannerModel.resolveIcon('shield_check'),
        TablerIcons.shield_check,
      );
      expect(
        HomeBannerModel.resolveIcon('calendar_event'),
        TablerIcons.calendar_event,
      );
      expect(
        HomeBannerModel.resolveIcon('file_certificate'),
        TablerIcons.file_certificate,
      );
      expect(HomeBannerModel.resolveIcon('sparkles'), TablerIcons.sparkles);
      expect(HomeBannerModel.resolveIcon('unknown'), TablerIcons.circle_check);
    });
  });
}
