import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_bloc.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_event.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_state.dart';
import 'package:ideal_mobile/presentation/list_property/domain/entities/property_upload_config.dart';
import 'package:ideal_mobile/presentation/list_property/widgets/steps/location_step_view.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';
import 'package:mocktail/mocktail.dart';

class MockListPropertyWizardBloc
    extends MockBloc<ListPropertyWizardEvent, ListPropertyWizardState>
    implements ListPropertyWizardBloc {}

void main() {
  late MockListPropertyWizardBloc mockBloc;

  const sampleConfig = PropertyUploadConfig(
    propertyTypes: [ChoiceOption(value: 'apartment', label: 'Apartment')],
    districts: [
      DistrictOption(id: 1, name: 'Chilanzar', city: 'Tashkent'),
      DistrictOption(id: 2, name: 'Yunusabad', city: 'Tashkent'),
    ],
    furnishings: [ChoiceOption(value: 'furnished', label: 'Furnished')],
    amenities: [AmenityOption(slug: 'wifi', name: 'Wi-Fi', icon: 'wifi')],
    minimumStays: [1, 3, 6, 12],
    priceIncludes: [ChoiceOption(value: 'internet', label: 'Internet')],
    currencies: ['USD'],
    publicOffer: PublicOfferDetail(id: 1, version: '1.0', body: 'Terms'),
  );

  setUp(() {
    mockBloc = MockListPropertyWizardBloc();
  });

  Widget buildTestableWidget(ListPropertyWizardState state) {
    when(() => mockBloc.state).thenReturn(state);

    return MaterialApp(
      theme: AppThemesData.themeData[AppThemeEnum.LightTheme],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BlocProvider<ListPropertyWizardBloc>.value(
          value: mockBloc,
          child: const LocationStepView(),
        ),
      ),
    );
  }

  testWidgets('renders fields and map picker placeholder in initial state', (
    tester,
  ) async {
    const state = ListPropertyWizardState(config: sampleConfig, currentStep: 1);

    await tester.pumpWidget(buildTestableWidget(state));
    await tester.pumpAndSettle();

    expect(find.text('District *'), findsOneWidget);
    expect(find.text('Street Address'), findsOneWidget);
    expect(find.text('Landmark'), findsOneWidget);
    expect(find.text('Map Location *'), findsOneWidget);
    expect(find.text('Select on map'), findsOneWidget);
  });

  testWidgets('shows validation errors when showValidationErrors is true', (
    tester,
  ) async {
    const state = ListPropertyWizardState(
      config: sampleConfig,
      currentStep: 1,
      showValidationErrors: true,
    );

    await tester.pumpWidget(buildTestableWidget(state));
    await tester.pumpAndSettle();

    expect(find.text('Please select a district'), findsOneWidget);
    expect(
      find.text('Please select the property location on the map.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'renders coordinates badge and change button when location is set',
    (tester) async {
      const state = ListPropertyWizardState(
        config: sampleConfig,
        currentStep: 1,
        districtId: 1,
        latitude: 41.311081,
        longitude: 69.240562,
      );

      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pumpAndSettle();

      expect(find.textContaining('41.31108'), findsOneWidget);
      expect(find.textContaining('69.24056'), findsOneWidget);
      expect(find.text('Change location'), findsOneWidget);
    },
  );
}
