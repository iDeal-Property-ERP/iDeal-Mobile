import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/force_update/models/app_update_info.dart';

void main() {
  group('AppUpdateType', () {
    test('fromString parses known types case-insensitively', () {
      expect(AppUpdateType.fromString('critical'), AppUpdateType.critical);
      expect(AppUpdateType.fromString('CRITICAL'), AppUpdateType.critical);
      expect(AppUpdateType.fromString('normal'), AppUpdateType.normal);
      expect(AppUpdateType.fromString('NORMAL'), AppUpdateType.normal);
      expect(AppUpdateType.fromString('none'), AppUpdateType.none);
      expect(AppUpdateType.fromString('NONE'), AppUpdateType.none);
      expect(AppUpdateType.fromString('unknown'), AppUpdateType.none);
      expect(AppUpdateType.fromString(null), AppUpdateType.none);
      expect(AppUpdateType.fromString(''), AppUpdateType.none);
    });
  });

  group('AppUpdateInfo', () {
    test('fromJson parses full critical payload', () {
      final json = {
        'update_type': 'critical',
        'current_version': '0.1.0',
        'latest_version': '1.0.0',
        'store_url': 'https://play.google.com/store/apps/details?id=com.ideal',
      };

      final info = AppUpdateInfo.fromJson(json);

      expect(info.updateType, AppUpdateType.critical);
      expect(info.isCritical, isTrue);
      expect(info.isNormal, isFalse);
      expect(info.hasUpdate, isTrue);
      expect(info.currentVersion, '0.1.0');
      expect(info.latestVersion, '1.0.0');
      expect(
        info.storeUrl,
        'https://play.google.com/store/apps/details?id=com.ideal',
      );
    });

    test('fromJson parses normal payload with null or empty fields', () {
      final json = {
        'update_type': 'normal',
        'current_version': '0.1.0',
        'latest_version': '  ',
        'store_url': null,
      };

      final info = AppUpdateInfo.fromJson(json);

      expect(info.updateType, AppUpdateType.normal);
      expect(info.isNormal, isTrue);
      expect(info.isCritical, isFalse);
      expect(info.hasUpdate, isTrue);
      expect(info.latestVersion, isNull);
      expect(info.storeUrl, isNull);
    });

    test('AppUpdateInfo.none creates default none instance', () {
      final info = AppUpdateInfo.none(currentVersion: '1.2.3');

      expect(info.updateType, AppUpdateType.none);
      expect(info.currentVersion, '1.2.3');
      expect(info.latestVersion, isNull);
      expect(info.storeUrl, isNull);
      expect(info.hasUpdate, isFalse);
    });

    test('Equatable equality works correctly', () {
      const info1 = AppUpdateInfo(
        updateType: AppUpdateType.normal,
        currentVersion: '0.1.0',
        latestVersion: '1.0.0',
        storeUrl: 'https://store.url',
      );
      const info2 = AppUpdateInfo(
        updateType: AppUpdateType.normal,
        currentVersion: '0.1.0',
        latestVersion: '1.0.0',
        storeUrl: 'https://store.url',
      );
      const info3 = AppUpdateInfo(
        updateType: AppUpdateType.critical,
        currentVersion: '0.1.0',
        latestVersion: '1.0.0',
        storeUrl: 'https://store.url',
      );

      expect(info1, equals(info2));
      expect(info1, isNot(equals(info3)));
    });
  });
}
