import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/personal_details_screen.dart';
import 'package:mocktail/mocktail.dart';

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
}
