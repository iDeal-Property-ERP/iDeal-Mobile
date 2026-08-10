import 'package:alchemist/alchemist.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chat_badge_cubit.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_bloc.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_event.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_state.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_bloc.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_event.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_state.dart';
import 'package:ideal_mobile/presentation/home/home_screen.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_state.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_badge_cubit.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/get_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/remove_profile_avatar.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/update_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/update_profile_avatar.dart';
import 'package:ideal_mobile/services/performance_monitoring_service.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';

import '../../../integration_test/mock_firebase_performance.dart';
import '../../flutter_test_config.dart';
import '../../test_helpers.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class MockListingsBloc extends MockBloc<ListingsEvent, ListingsState>
    implements ListingsBloc {}

class MockChatsBloc extends MockBloc<ChatsEvent, ChatsState>
    implements ChatsBloc {}

class MockChatBadgeCubit extends MockCubit<int> implements ChatBadgeCubit {}

class MockNotificationBadgeCubit extends MockCubit<int>
    implements NotificationBadgeCubit {}

class MockGetProfile extends Mock implements GetProfile {}

class MockUpdateProfile extends Mock implements UpdateProfile {}

class MockUpdateProfileAvatar extends Mock implements UpdateProfileAvatar {}

class MockRemoveProfileAvatar extends Mock implements RemoveProfileAvatar {}

const _testProfile = MobileUserProfile(
  id: 1,
  firstName: 'Test',
  lastName: 'User',
  patronymic: null,
  email: 'test@example.com',
  phone: '+998901234567',
  nationality: null,
  avatarUrl: null,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockFirebasePerformance mockFirebasePerformance;

  setUpAll(() async {
    mockFirebasePerformance = MockFirebasePerformance();
    sl.allowReassignment = true;
    sl.registerLazySingleton<PerformanceMonitoringService>(
      () => PerformanceMonitoringService(performance: mockFirebasePerformance),
    );

    final notificationBadgeCubit = MockNotificationBadgeCubit();
    when(() => notificationBadgeCubit.state).thenReturn(0);
    if (sl.isRegistered<NotificationBadgeCubit>()) {
      sl.unregister<NotificationBadgeCubit>();
    }
    sl.registerSingleton<NotificationBadgeCubit>(notificationBadgeCubit);
    final getProfile = MockGetProfile();
    when(() => getProfile()).thenAnswer((_) async => const Right(_testProfile));
    sl.registerLazySingleton<GetProfile>(() => getProfile);
    sl.registerLazySingleton<UpdateProfile>(MockUpdateProfile.new);
    sl.registerLazySingleton<UpdateProfileAvatar>(MockUpdateProfileAvatar.new);
    sl.registerLazySingleton<RemoveProfileAvatar>(MockRemoveProfileAvatar.new);
    setupFirebaseCoreMocks();
    await Firebase.initializeApp(
      name: 'tenantIdTest',
      options: const FirebaseOptions(
        apiKey: 'apiKey',
        appId: 'appId',
        messagingSenderId: 'messagingSenderId',
        projectId: 'projectId',
      ),
    );
  });

  // Widget tests
  group('Home Page', () {
    testWidgets('home page', (tester) async {
      //arrange
      final homeBloc = MockHomeBloc();
      when(() => homeBloc.state).thenReturn(HomeState.test());
      final listingsBloc = MockListingsBloc();
      when(() => listingsBloc.state).thenReturn(ListingsState.test());
      final chatsBloc = MockChatsBloc();
      when(() => chatsBloc.state).thenReturn(const ChatsState.initial());
      final chatBadgeCubit = MockChatBadgeCubit();
      when(() => chatBadgeCubit.state).thenReturn(0);

      //act
      await tester.runWidgetTest(
        providers: [
          BlocProvider<HomeBloc>.value(value: homeBloc),
          BlocProvider<ListingsBloc>.value(value: listingsBloc),
        ],
        child: HomeScreenWrapper(
          chatsBloc: chatsBloc,
          chatBadgeCubit: chatBadgeCubit,
        ),
      );

      // assert
      expect(find.byType(HomeScreenWrapper), findsOneWidget);
      final nav = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(nav.items, hasLength(3));
    });

    // Golden test cases
    testExecutable(() {
      goldenTest(
        'Home page UI test',
        fileName: 'home_screen',
        pumpBeforeTest: precacheImages,
        builder: () {
          //arrange
          final homeBloc = MockHomeBloc();
          when(() => homeBloc.state).thenReturn(HomeState.test());
          final listingsBloc = MockListingsBloc();
          when(() => listingsBloc.state).thenReturn(ListingsState.test());
          final chatsBloc = MockChatsBloc();
          when(() => chatsBloc.state).thenReturn(const ChatsState.initial());
          final chatBadgeCubit = MockChatBadgeCubit();
          when(() => chatBadgeCubit.state).thenReturn(0);

          // act, assert
          return GoldenTestGroup(
            columnWidthBuilder: (_) =>
                const FixedColumnWidth(pixel5DeviceWidth),
            children: [
              createTestScenario(
                name: 'home_screen Light Theme',
                providers: [
                  BlocProvider<HomeBloc>.value(value: homeBloc),
                  BlocProvider<ListingsBloc>.value(value: listingsBloc),
                ],
                child: HomeScreenWrapper(
                  chatsBloc: chatsBloc,
                  chatBadgeCubit: chatBadgeCubit,
                ),
              ),
              createTestScenario(
                name: 'home_screen Dark Theme',
                providers: [
                  BlocProvider<HomeBloc>.value(value: homeBloc),
                  BlocProvider<ListingsBloc>.value(value: listingsBloc),
                ],
                child: HomeScreenWrapper(
                  chatsBloc: chatsBloc,
                  chatBadgeCubit: chatBadgeCubit,
                ),
                theme: AppThemeEnum.DarkTheme,
              ),
            ],
          );
        },
      );
    });
  });
}
