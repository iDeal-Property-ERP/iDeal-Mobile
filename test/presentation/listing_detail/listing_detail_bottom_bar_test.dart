import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/presentation/chat/bloc/open_conversation_cubit.dart';
import 'package:ideal_mobile/presentation/listing_detail/widgets/listing_detail_bottom_bar.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_state_enum.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_helpers.dart';
import 'listing_detail_test_helpers.dart';

class MockOpenConversationCubit extends MockCubit<OpenConversationState>
    implements OpenConversationCubit {}

class MockSharedPreferencesAsync extends Mock
    implements SharedPreferencesAsync {}

const secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('disables messaging and hides calling without contact data', (
    tester,
  ) async {
    await tester.runWidgetTest(
      child: ListingDetailBottomBar(detail: buildListingDetail()),
    );

    final messageButton = tester.widget<AppButton>(
      find.byKey(keys.listingDetail.messageButton),
    );

    expect(messageButton.onPressed, isNull);
    expect(messageButton.state, AppButtonState.disabled);
    expect(
      find.bySemanticsLabel('Messaging is unavailable for this listing'),
      findsOneWidget,
    );
    expect(find.byKey(keys.listingDetail.callButton), findsNothing);
  });

  testWidgets('shows the call button when contact data is available', (
    tester,
  ) async {
    await tester.runWidgetTest(
      child: ListingDetailBottomBar(
        detail: buildListingDetail(contactPhone: '+998 90 123 45 67'),
      ),
    );

    expect(find.byKey(keys.listingDetail.callButton), findsOneWidget);
  });

  testWidgets('enabled messaging dispatches the listing id', (tester) async {
    final cubit = MockOpenConversationCubit();
    final prefs = MockSharedPreferencesAsync();
    when(() => cubit.state).thenReturn(const OpenConversationState());
    when(() => cubit.open(any())).thenAnswer((_) async {});
    when(() => prefs.getString(any())).thenAnswer((_) async => null);
    Prefs.setMockPrefs(prefs);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          secureStorageChannel,
          (_) async => 'test-token',
        );

    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(secureStorageChannel, null);
    });

    await tester.runWidgetTest(
      child: ListingDetailBottomBar(
        detail: buildListingDetail(canMessage: true),
        openConversationCubit: cubit,
      ),
    );

    final messageButton = tester.widget<AppButton>(
      find.byKey(keys.listingDetail.messageButton),
    );
    expect(messageButton.onPressed, isNotNull);

    await tester.tap(find.byKey(keys.listingDetail.messageButton));
    await tester.pump();

    verify(() => cubit.open(12)).called(1);
  });
}
