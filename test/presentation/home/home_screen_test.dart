import 'package:alchemist/alchemist.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chat_badge_cubit.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_bloc.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_event.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_state.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_bloc.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_event.dart';
import 'package:ideal_mobile/presentation/favorites/bloc/selected_state.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_bloc.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_event.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_state.dart';
import 'package:ideal_mobile/presentation/home/home_screen.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_screen_body.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_state.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_card.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_shimmer.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_empty_view.dart';
import 'package:ideal_mobile/presentation/notifications/bloc/notification_badge_cubit.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/get_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/remove_profile_avatar.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/update_profile.dart';
import 'package:ideal_mobile/presentation/profile/domain/usecases/update_profile_avatar.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';
import 'package:ideal_mobile/widgets/styling/app_theme_data.dart';
import 'package:mocktail/mocktail.dart';

import '../../flutter_test_config.dart';
import '../../test_helpers.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class MockListingsBloc extends MockBloc<ListingsEvent, ListingsState>
    implements ListingsBloc {}

class MockChatsBloc extends MockBloc<ChatsEvent, ChatsState>
    implements ChatsBloc {}

class MockSelectedBloc extends MockBloc<SelectedEvent, SelectedState>
    implements SelectedBloc {}

class MockChatBadgeCubit extends MockCubit<int> implements ChatBadgeCubit {}

class MockNotificationBadgeCubit extends MockCubit<int>
    implements NotificationBadgeCubit {}

class MockStackRouter extends Mock implements StackRouter {}

class FakePageRouteInfo extends Fake implements PageRouteInfo<Object?> {}

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
  setUpAll(() async {
    registerFallbackValue(FakePageRouteInfo());
    sl.allowReassignment = true;

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
      final selectedBloc = MockSelectedBloc();
      when(() => selectedBloc.state).thenReturn(SelectedState.test());
      final listingsBloc = MockListingsBloc();
      when(
        () => listingsBloc.state,
      ).thenReturn(ListingsState.test(hasLoadedListings: true));
      final chatsBloc = MockChatsBloc();
      when(() => chatsBloc.state).thenReturn(const ChatsState.initial());
      final chatBadgeCubit = MockChatBadgeCubit();
      when(() => chatBadgeCubit.state).thenReturn(0);

      //act
      await tester.runWidgetTest(
        providers: [
          BlocProvider<HomeBloc>.value(value: homeBloc),
          BlocProvider<SelectedBloc>.value(value: selectedBloc),
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
      expect(nav.items, hasLength(4));
      expect(nav.items.map((item) => item.label).toList(), [
        'Home',
        'Selected',
        'Chats',
        'Profile',
      ]);
    });

    testWidgets('shows listing placeholders before the first response', (
      tester,
    ) async {
      final homeBloc = MockHomeBloc();
      when(() => homeBloc.state).thenReturn(HomeState.test());
      final selectedBloc = MockSelectedBloc();
      when(() => selectedBloc.state).thenReturn(SelectedState.test());
      final listingsBloc = MockListingsBloc();
      when(() => listingsBloc.state).thenReturn(ListingsState.test());
      final chatsBloc = MockChatsBloc();
      when(() => chatsBloc.state).thenReturn(const ChatsState.initial());
      final chatBadgeCubit = MockChatBadgeCubit();
      when(() => chatBadgeCubit.state).thenReturn(0);

      await tester.runWidgetTest(
        providers: [
          BlocProvider<HomeBloc>.value(value: homeBloc),
          BlocProvider<SelectedBloc>.value(value: selectedBloc),
          BlocProvider<ListingsBloc>.value(value: listingsBloc),
        ],
        child: HomeScreenWrapper(
          chatsBloc: chatsBloc,
          chatBadgeCubit: chatBadgeCubit,
        ),
      );

      expect(find.byType(ListingCardShimmerGrid), findsOneWidget);
      expect(find.byType(ListingsEmptyView), findsNothing);
    });

    testWidgets('shows empty state after an empty listings response', (
      tester,
    ) async {
      final homeBloc = MockHomeBloc();
      when(() => homeBloc.state).thenReturn(HomeState.test());
      final selectedBloc = MockSelectedBloc();
      when(() => selectedBloc.state).thenReturn(SelectedState.test());
      final listingsBloc = MockListingsBloc();
      when(
        () => listingsBloc.state,
      ).thenReturn(ListingsState.test(hasLoadedListings: true));
      final chatsBloc = MockChatsBloc();
      when(() => chatsBloc.state).thenReturn(const ChatsState.initial());
      final chatBadgeCubit = MockChatBadgeCubit();
      when(() => chatBadgeCubit.state).thenReturn(0);

      await tester.runWidgetTest(
        providers: [
          BlocProvider<HomeBloc>.value(value: homeBloc),
          BlocProvider<SelectedBloc>.value(value: selectedBloc),
          BlocProvider<ListingsBloc>.value(value: listingsBloc),
        ],
        child: HomeScreenWrapper(
          chatsBloc: chatsBloc,
          chatBadgeCubit: chatBadgeCubit,
        ),
      );

      expect(find.byType(ListingCardShimmerGrid), findsNothing);
      expect(find.byType(ListingsEmptyView), findsOneWidget);
    });

    testWidgets('uses localized tab labels in exact order', (tester) async {
      Future<void> pumpForLocale(Locale locale) async {
        final homeBloc = MockHomeBloc();
        when(() => homeBloc.state).thenReturn(HomeState.test());
        final selectedBloc = MockSelectedBloc();
        when(() => selectedBloc.state).thenReturn(SelectedState.test());
        final listingsBloc = MockListingsBloc();
        when(
          () => listingsBloc.state,
        ).thenReturn(ListingsState.test(hasLoadedListings: true));
        final chatsBloc = MockChatsBloc();
        when(() => chatsBloc.state).thenReturn(const ChatsState.initial());
        final chatBadgeCubit = MockChatBadgeCubit();
        when(() => chatBadgeCubit.state).thenReturn(0);

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<HomeBloc>.value(value: homeBloc),
              BlocProvider<SelectedBloc>.value(value: selectedBloc),
              BlocProvider<ListingsBloc>.value(value: listingsBloc),
            ],
            child: MaterialApp(
              locale: locale,
              debugShowCheckedModeBanner: false,
              theme: AppThemesData.themeData[AppThemeEnum.LightTheme],
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: HomeScreenWrapper(
                chatsBloc: chatsBloc,
                chatBadgeCubit: chatBadgeCubit,
              ),
            ),
          ),
        );
        await tester.pump();
      }

      await pumpForLocale(const Locale('en'));
      expect(
        find.descendant(
          of: find.byType(AppSliverTopBar),
          matching: find.text('Home'),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .items
            .map((item) => item.label)
            .toList(),
        ['Home', 'Selected', 'Chats', 'Profile'],
      );

      await pumpForLocale(const Locale('ru'));
      expect(
        find.descendant(
          of: find.byType(AppSliverTopBar),
          matching: find.text('Главная'),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .items
            .map((item) => item.label)
            .toList(),
        ['Главная', 'Избранное', 'Чаты', 'Профиль'],
      );

      await pumpForLocale(const Locale('uz'));
      expect(
        find.descendant(
          of: find.byType(AppSliverTopBar),
          matching: find.text('Bosh sahifa'),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .items
            .map((item) => item.label)
            .toList(),
        ['Bosh sahifa', 'Tanlanganlar', 'Suhbatlar', 'Profil'],
      );
    });

    testWidgets('dispatches notification action to the notifications route', (
      tester,
    ) async {
      final router = MockStackRouter();
      when(() => router.push(any())).thenAnswer((_) async => null);
      final listingsBloc = MockListingsBloc();
      when(
        () => listingsBloc.state,
      ).thenReturn(ListingsState.test(hasLoadedListings: true));

      await tester.runWidgetTest(
        providers: [BlocProvider<ListingsBloc>.value(value: listingsBloc)],
        child: StackRouterScope(
          controller: router,
          stateHash: 0,
          child: const Scaffold(body: HomeScreenBody()),
        ),
      );

      await tester.tap(find.byTooltip('Notifications'));
      await tester.pump();

      final route = verify(() => router.push(captureAny())).captured.single;
      expect(route, isA<NotificationsRoute>());
    });

    testWidgets('keeps the logo, title, and action fixed while scrolling', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(411, 896);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final listingsBloc = MockListingsBloc();
      when(() => listingsBloc.state).thenReturn(
        ListingsState.test(
          items: List<ListingCard>.generate(
            8,
            (index) => _homeTestListing(index + 1),
          ),
          hasLoadedListings: true,
          hasReachedMax: true,
        ),
      );

      await tester.runWidgetTest(
        providers: [BlocProvider<ListingsBloc>.value(value: listingsBloc)],
        child: const Scaffold(body: HomeScreenBody()),
      );

      final logo = find.descendant(
        of: find.byType(AppSliverTopBar),
        matching: find.byType(Image),
      );
      final title = find.descendant(
        of: find.byType(AppSliverTopBar),
        matching: find.text('Home'),
      );
      final action = find.byTooltip('Notifications');
      expect(logo, findsOneWidget);
      final logoCenterBefore = tester.getCenter(logo);
      final titleCenterBefore = tester.getCenter(title);
      final actionCenterBefore = tester.getCenter(action);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(tester.getCenter(logo), logoCenterBefore);
      expect(tester.getCenter(title), titleCenterBefore);
      expect(tester.getCenter(action), actionCenterBefore);
    });

    testWidgets('requests the next Home page near the bottom', (tester) async {
      tester.view.physicalSize = const Size(411, 896);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final listingsBloc = MockListingsBloc();
      when(() => listingsBloc.state).thenReturn(
        ListingsState.test(
          items: List<ListingCard>.generate(
            30,
            (index) => _homeTestListing(index + 1),
          ),
          page: 1,
          numPages: 2,
          count: 31,
          hasLoadedListings: true,
        ),
      );

      await tester.runWidgetTest(
        providers: [BlocProvider<ListingsBloc>.value(value: listingsBloc)],
        child: const Scaffold(body: HomeScreenBody()),
      );
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -10000));
      await tester.pump();

      verify(() => listingsBloc.add(const LoadMoreListingsEvent())).called(1);
    });

    testWidgets('refreshes Selected when the tab becomes active', (
      tester,
    ) async {
      final homeBloc = HomeBloc();
      final selectedBloc = MockSelectedBloc();
      when(() => selectedBloc.state).thenReturn(SelectedState.test());
      final listingsBloc = MockListingsBloc();
      when(
        () => listingsBloc.state,
      ).thenReturn(ListingsState.test(hasLoadedListings: true));
      final chatsBloc = MockChatsBloc();
      when(() => chatsBloc.state).thenReturn(const ChatsState.initial());
      final chatBadgeCubit = MockChatBadgeCubit();
      when(() => chatBadgeCubit.state).thenReturn(0);

      await tester.runWidgetTest(
        providers: [
          BlocProvider<HomeBloc>.value(value: homeBloc),
          BlocProvider<SelectedBloc>.value(value: selectedBloc),
          BlocProvider<ListingsBloc>.value(value: listingsBloc),
        ],
        child: HomeScreenWrapper(
          chatsBloc: chatsBloc,
          chatBadgeCubit: chatBadgeCubit,
        ),
      );

      homeBloc.add(const BottomNavBarIndexChangedEvent(index: 1));
      await tester.pump();

      verify(
        () => selectedBloc.add(const LoadSelectedEvent(refresh: true)),
      ).called(1);
    });

    testWidgets('retains the home feed scroll position across tab switches', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(411, 896);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final homeBloc = HomeBloc();
      addTearDown(homeBloc.close);
      final selectedBloc = MockSelectedBloc();
      when(() => selectedBloc.state).thenReturn(SelectedState.test());
      final listingsBloc = MockListingsBloc();
      when(() => listingsBloc.state).thenReturn(
        ListingsState.test(
          items: List<ListingCard>.generate(
            8,
            (index) => _homeTestListing(index + 1),
          ),
          hasLoadedListings: true,
          hasReachedMax: true,
        ),
      );
      final chatsBloc = MockChatsBloc();
      when(() => chatsBloc.state).thenReturn(const ChatsState.initial());
      final chatBadgeCubit = MockChatBadgeCubit();
      when(() => chatBadgeCubit.state).thenReturn(0);

      await tester.runWidgetTest(
        providers: [
          BlocProvider<HomeBloc>.value(value: homeBloc),
          BlocProvider<SelectedBloc>.value(value: selectedBloc),
          BlocProvider<ListingsBloc>.value(value: listingsBloc),
        ],
        child: HomeScreenWrapper(
          chatsBloc: chatsBloc,
          chatBadgeCubit: chatBadgeCubit,
        ),
      );

      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, -280));
      await tester.pump();
      final positionBeforeSwitch = tester
          .state<ScrollableState>(scrollable)
          .position
          .pixels;
      expect(positionBeforeSwitch, greaterThan(0));

      homeBloc.add(const BottomNavBarIndexChangedEvent(index: 1));
      await tester.pump();
      homeBloc.add(const BottomNavBarIndexChangedEvent(index: 0));
      await tester.pump();

      final positionAfterSwitch = tester
          .state<ScrollableState>(scrollable)
          .position
          .pixels;
      expect(positionAfterSwitch, positionBeforeSwitch);
      expect(find.byType(HomeScreenBody), findsOneWidget);
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
          final selectedBloc = MockSelectedBloc();
          when(() => selectedBloc.state).thenReturn(SelectedState.test());
          final listingsBloc = MockListingsBloc();
          when(
            () => listingsBloc.state,
          ).thenReturn(ListingsState.test(hasLoadedListings: true));
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
                  BlocProvider<SelectedBloc>.value(value: selectedBloc),
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
                  BlocProvider<SelectedBloc>.value(value: selectedBloc),
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

ListingCard _homeTestListing(int id) => ListingCard(
  id: id,
  propertyId: id + 100,
  title: 'Listing $id',
  district: 'Yunusobod',
  address: 'Address $id',
  propertyType: 'apartment',
  rooms: 2,
  areaSqm: 68,
  floor: 4,
  totalFloors: 9,
  furnishing: 'furnished',
  price: 520,
  currency: 'USD',
  tariff: 'comfort',
  isVerified: true,
  isFeatured: false,
  score: 9.2,
  reviewCount: 14,
  coverImageUrl: null,
  mapLat: null,
  mapLon: null,
);
