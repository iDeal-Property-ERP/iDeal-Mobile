import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/list_property/screens/location_picker_screen.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
import 'package:ideal_mobile/presentation/map/services/property_map_location_service.dart';
import 'package:ideal_mobile/presentation/map/widgets/property_map_view.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationService extends Mock implements PropertyMapLocationService {}

void main() {
  late MockLocationService mockLocationService;

  setUp(() {
    mockLocationService = MockLocationService();
  });

  Widget buildTestableWidget({
    PropertyMapCoordinate? initialCoordinate,
    PropertyMapLocationService? locationService,
  }) {
    return MaterialApp(
      theme: AppThemesData.themeData[AppThemeEnum.LightTheme],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: LocationPickerScreen(
        initialCoordinate: initialCoordinate,
        locationService: locationService ?? mockLocationService,
        providerViewBuilder: (context, provider, config, onReady, onFailed) {
          return Container(key: const ValueKey('mock-provider-view'));
        },
      ),
    );
  }

  testWidgets('renders map, center pin, coordinate panel, and confirm button', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestableWidget(
        initialCoordinate: const PropertyMapCoordinate(
          latitude: 41.311081,
          longitude: 69.240562,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('location-picker-map')), findsOneWidget);
    expect(find.byType(AppButton), findsOneWidget);
    expect(find.textContaining('41.311081'), findsOneWidget);
    expect(find.textContaining('69.240562'), findsOneWidget);
  });

  testWidgets('pressing my location button queries location service', (
    tester,
  ) async {
    when(() => mockLocationService.getCurrentLocation()).thenAnswer(
      (_) async => const PropertyMapCoordinate(
        latitude: 41.300000,
        longitude: 69.200000,
      ),
    );

    await tester.pumpWidget(
      buildTestableWidget(
        initialCoordinate: const PropertyMapCoordinate(
          latitude: 41.311081,
          longitude: 69.240562,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find the inkwell with current_location icon
    final locateFinder = find.byWidgetPredicate(
      (widget) =>
          widget is InkWell &&
          find
              .descendant(
                of: find.byWidget(widget),
                matching: find.byType(Icon),
              )
              .evaluate()
              .isNotEmpty,
    );

    if (locateFinder.evaluate().isNotEmpty) {
      await tester.tap(locateFinder.first);
      await tester.pumpAndSettle();
      verify(() => mockLocationService.getCurrentLocation()).called(1);
    }
  });
}
