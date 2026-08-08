import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/get_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/remove_profile_avatar.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/update_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/update_profile_avatar.dart';
import 'package:ideal_mobile/services/performance_monitoring_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProfile extends Mock implements GetProfile {}

class MockUpdateProfile extends Mock implements UpdateProfile {}

class MockUpdateProfileAvatar extends Mock implements UpdateProfileAvatar {}

class MockRemoveProfileAvatar extends Mock implements RemoveProfileAvatar {}

class MockPerformanceMonitoringService extends Mock
    implements PerformanceMonitoringService {}

void main() {
  const profile = MobileUserProfile(
    id: 1,
    firstName: 'Jessica',
    lastName: 'Fernandes',
    patronymic: null,
    email: 'jessica@example.com',
    phone: '+998901234567',
    nationality: 'Uzbek',
    avatarUrl: null,
  );

  late MockGetProfile getProfile;
  late MockUpdateProfile updateProfile;
  late MockUpdateProfileAvatar updateProfileAvatar;
  late MockRemoveProfileAvatar removeProfileAvatar;
  late MockPerformanceMonitoringService performanceService;

  ProfileBloc buildBloc() => ProfileBloc(
    getProfile: getProfile,
    updateProfile: updateProfile,
    updateProfileAvatar: updateProfileAvatar,
    removeProfileAvatar: removeProfileAvatar,
    performanceService: performanceService,
  );

  setUpAll(() {
    registerFallbackValue(profile);
    registerFallbackValue(const UpdateProfileParams(profile));
    registerFallbackValue(UpdateProfileAvatarParams(File('avatar.png')));
  });

  setUp(() {
    getProfile = MockGetProfile();
    updateProfile = MockUpdateProfile();
    updateProfileAvatar = MockUpdateProfileAvatar();
    removeProfileAvatar = MockRemoveProfileAvatar();
    performanceService = MockPerformanceMonitoringService();
  });

  group('ProfileBloc', () {
    test('starts without placeholder profile details', () {
      final bloc = buildBloc();

      expect(bloc.state, const ProfileState.initial());
      bloc.close();
    });

    blocTest<ProfileBloc, ProfileState>(
      'loads the authenticated mobile profile',
      setUp: () => when(
        () => getProfile(),
      ).thenAnswer((_) async => const Right(profile)),
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadProfileEvent()),
      expect: () => [
        isA<ProfileState>().having(
          (state) => state.isProfileLoading,
          'isProfileLoading',
          true,
        ),
        isA<ProfileState>()
            .having((state) => state.profile, 'profile', profile)
            .having((state) => state.name, 'name', 'Jessica Fernandes')
            .having(
              (state) => state.isProfileLoading,
              'isProfileLoading',
              false,
            ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'keeps existing profile data when loading fails',
      setUp: () => when(() => getProfile()).thenAnswer(
        (_) async => const Left(
          APIFailure(message: 'Profile request failed.', statusCode: 500),
        ),
      ),
      build: buildBloc,
      seed: () => const ProfileState.test(profile: profile),
      act: (bloc) => bloc.add(const LoadProfileEvent()),
      expect: () => [
        isA<ProfileState>().having(
          (state) => state.isProfileLoading,
          'isProfileLoading',
          true,
        ),
        isA<ProfileState>()
            .having((state) => state.profile, 'profile', profile)
            .having(
              (state) => state.profileError,
              'profileError',
              'Profile request failed.',
            ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'updates the state from the API response after saving',
      setUp: () {
        when(() => updateProfile(any())).thenAnswer(
          (_) async => const Right(
            MobileUserProfile(
              id: 1,
              firstName: 'Aziz',
              lastName: 'Karimov',
              patronymic: null,
              email: 'aziz@example.com',
              phone: '+998901234567',
              nationality: 'Uzbek',
              avatarUrl: null,
            ),
          ),
        );
      },
      build: buildBloc,
      seed: () => const ProfileState.test(profile: profile),
      act: (bloc) => bloc.add(const UpdateProfileEvent(profile: profile)),
      expect: () => [
        isA<ProfileState>().having(
          (state) => state.isProfileUpdating,
          'isProfileUpdating',
          true,
        ),
        isA<ProfileState>()
            .having((state) => state.name, 'name', 'Aziz Karimov')
            .having((state) => state.email, 'email', 'aziz@example.com')
            .having(
              (state) => state.isProfileUpdating,
              'isProfileUpdating',
              false,
            ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'updates the shared profile after an avatar upload',
      setUp: () => when(() => updateProfileAvatar(any())).thenAnswer(
        (_) async => const Right(
          MobileUserProfile(
            id: 1,
            firstName: 'Jessica',
            lastName: 'Fernandes',
            patronymic: null,
            email: 'jessica@example.com',
            phone: '+998901234567',
            nationality: 'Uzbek',
            avatarUrl: 'https://api.example.com/avatar.png',
          ),
        ),
      ),
      build: buildBloc,
      seed: () => const ProfileState.test(profile: profile),
      act: (bloc) =>
          bloc.add(UpdateProfileAvatarEvent(image: File('avatar.png'))),
      expect: () => [
        isA<ProfileState>().having(
          (state) => state.isAvatarUpdating,
          'isAvatarUpdating',
          true,
        ),
        isA<ProfileState>()
            .having(
              (state) => state.profile?.avatarUrl,
              'avatarUrl',
              'https://api.example.com/avatar.png',
            )
            .having(
              (state) => state.isAvatarUpdating,
              'isAvatarUpdating',
              false,
            ),
      ],
    );
  });
}
