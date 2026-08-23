import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_header.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

void main() {
  testWidgets('shows the styled default user image in both theme modes', (
    tester,
  ) async {
    final profileBloc = _MockProfileBloc();
    const profile = MobileUserProfile(
      id: 1,
      firstName: '',
      lastName: null,
      patronymic: null,
      phone: '+998901234567',
      nationality: null,
      avatarUrl: null,
    );
    when(
      () => profileBloc.state,
    ).thenReturn(const ProfileState.test(profile: profile));
    when(() => profileBloc.stream).thenAnswer((_) => const Stream.empty());

    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: Scaffold(
            body: BlocProvider<ProfileBloc>.value(
              value: profileBloc,
              child: const ProfileHeader(),
            ),
          ),
        ),
      );

      final placeholder = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(placeholder.bytesLoader, isA<SvgAssetLoader>());
      expect(
        (placeholder.bytesLoader as SvgAssetLoader).colorMapper,
        isNotNull,
      );
      expect(find.text('+9'), findsNothing);
    }
  });
}
