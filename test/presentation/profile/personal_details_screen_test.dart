import 'package:alchemist/alchemist.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/delete_account/delete_account_screen.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/personal_details_screen.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';
import 'package:mocktail/mocktail.dart';

import '../../flutter_test_config.dart';
import '../../test_helpers.dart';

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

const testProfile = MobileUserProfile(
  id: 1,
  firstName: 'Test',
  lastName: 'User',
  patronymic: 'Middle',
  email: 'test@example.com',
  phone: '+998901234567',
  nationality: 'Uzbek',
  avatarUrl: null,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockProfileBloc mockProfileBloc;

  setUpAll(() {
    registerFallbackValue(const UpdateProfileEvent(profile: testProfile));
  });

  setUp(() {
    mockProfileBloc = MockProfileBloc();
    when(
      () => mockProfileBloc.state,
    ).thenReturn(const ProfileState.test(profile: testProfile));
  });

  testWidgets('renders personal details fields without nationality field', (
    tester,
  ) async {
    await tester.runWidgetTest(
      providers: [BlocProvider<ProfileBloc>.value(value: mockProfileBloc)],
      child: PersonalDetailsScreen(profileBloc: mockProfileBloc),
    );

    expect(find.text('First name'), findsOneWidget);
    expect(find.text('Last name'), findsOneWidget);
    expect(find.text('Patronymic'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mobile number'), findsOneWidget);
    expect(find.text('Nationality'), findsNothing);
  });

  testWidgets('opens phone change from the read-only phone field', (
    tester,
  ) async {
    await tester.runWidgetTest(
      providers: [BlocProvider<ProfileBloc>.value(value: mockProfileBloc)],
      child: PersonalDetailsScreen(profileBloc: mockProfileBloc),
    );

    final phoneField = tester
        .widgetList<TextField>(find.byType(TextField))
        .singleWhere((field) => field.controller?.text == '+998901234567');
    expect(phoneField.readOnly, isTrue);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Change Phone Number'), findsOneWidget);
  });

  testWidgets('opens account deletion from the Edit Profile top bar', (
    tester,
  ) async {
    await tester.runWidgetTest(
      providers: [BlocProvider<ProfileBloc>.value(value: mockProfileBloc)],
      child: PersonalDetailsScreen(profileBloc: mockProfileBloc),
    );

    await tester.tap(find.byTooltip('Delete Account'));
    await tester.pumpAndSettle();

    expect(find.byType(DeleteAccountScreen), findsOneWidget);
  });

  testWidgets(
    'saving form submits updated profile while preserving nationality',
    (tester) async {
      await tester.runWidgetTest(
        providers: [BlocProvider<ProfileBloc>.value(value: mockProfileBloc)],
        child: PersonalDetailsScreen(profileBloc: mockProfileBloc),
      );

      final firstNameField = find.widgetWithText(TextFormField, 'Test');
      expect(firstNameField, findsOneWidget);

      await tester.enterText(firstNameField, 'UpdatedName');
      await tester.pumpAndSettle();

      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      verify(
        () => mockProfileBloc.add(
          UpdateProfileEvent(
            profile: testProfile.copyWith(firstName: 'UpdatedName'),
          ),
        ),
      ).called(1);
    },
  );

  testExecutable(() {
    goldenTest(
      'personal details editor',
      fileName: 'personal_details_editor',
      builder: () {
        final profileBloc = MockProfileBloc();
        when(
          () => profileBloc.state,
        ).thenReturn(const ProfileState.test(profile: testProfile));

        return GoldenTestGroup(
          columnWidthBuilder: (_) => const FixedColumnWidth(pixel5DeviceWidth),
          children: [
            createTestScenario(
              name: 'Personal details editor Light Theme',
              child: PersonalDetailsScreen(profileBloc: profileBloc),
            ),
            createTestScenario(
              name: 'Personal details editor Dark Theme',
              child: PersonalDetailsScreen(profileBloc: profileBloc),
              theme: AppThemeEnum.DarkTheme,
            ),
          ],
        );
      },
    );
  });
}
