import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_event.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_state.dart';
import 'package:ideal_mobile/presentation/chat/chats_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../test_helpers.dart';
import 'chat_test_helpers.dart';

ChatsFeedState _feed({
  required int startId,
  int length = 30,
  bool archived = false,
  bool isLoadingMore = false,
  String? errorMessage,
  int? failedPage,
}) {
  return ChatsFeedState(
    items: [
      for (var index = 0; index < length; index++)
        buildChatConversation(
          id: startId - index,
          isArchived: archived,
          coverImageUrl: null,
        ),
    ],
    page: 1,
    numPages: 2,
    count: length + 1,
    hasLoaded: true,
    isLoadingMore: isLoadingMore,
    errorMessage: errorMessage,
    failedPage: failedPage,
  );
}

Future<void> _pump(WidgetTester tester, MockChatsBloc bloc) async {
  tester.view.physicalSize = const Size(411, 896);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.runWidgetTest(child: ChatsScreen(bloc: bloc));
}

void main() {
  testWidgets('bottom scrolling requests the next Active page', (tester) async {
    final bloc = mockChatsBloc(
      ChatsState.test(activeFeed: _feed(startId: 100)),
    );
    await _pump(tester, bloc);

    await tester.drag(
      find.byType(CustomScrollView).hitTestable(),
      const Offset(0, -10000),
    );
    await tester.pump();

    verify(
      () => bloc.add(const ChatsLoadMoreRequested(ChatsTab.active)),
    ).called(1);
  });

  testWidgets('bottom scrolling requests the next Archived page', (
    tester,
  ) async {
    final bloc = mockChatsBloc(
      ChatsState.test(
        selectedTab: ChatsTab.archived,
        activeFeed: _feed(startId: 100),
        archivedFeed: _feed(startId: 200, archived: true),
      ),
    );
    await _pump(tester, bloc);

    await tester.drag(
      find.byType(CustomScrollView).hitTestable(),
      const Offset(0, -10000),
    );
    await tester.pump();

    verify(
      () => bloc.add(const ChatsLoadMoreRequested(ChatsTab.archived)),
    ).called(1);
  });

  testWidgets('tabs retain independent feed scroll positions', (tester) async {
    final controller = StreamController<ChatsState>.broadcast();
    addTearDown(controller.close);
    final initial = ChatsState.test(
      activeFeed: _feed(startId: 100),
      archivedFeed: _feed(startId: 200, archived: true),
    );
    final bloc = MockChatsBloc();
    whenListen(bloc, controller.stream, initialState: initial);
    await _pump(tester, bloc);

    var scrollable = find.byType(Scrollable).hitTestable();
    await tester.drag(scrollable, const Offset(0, -600));
    await tester.pump();
    final activeOffset = tester
        .state<ScrollableState>(scrollable)
        .position
        .pixels;
    expect(activeOffset, greaterThan(0));

    await tester.tap(find.text('Archived').hitTestable());
    controller.add(initial.copyWith(selectedTab: ChatsTab.archived));
    await tester.pump();
    verify(() => bloc.add(const ChatsTabSelected(ChatsTab.archived))).called(1);

    scrollable = find.byType(Scrollable).hitTestable();
    expect(tester.state<ScrollableState>(scrollable).position.pixels, 0);
    await tester.drag(scrollable, const Offset(0, -900));
    await tester.pump();
    final archivedOffset = tester
        .state<ScrollableState>(scrollable)
        .position
        .pixels;
    expect(archivedOffset, greaterThan(activeOffset));

    controller.add(initial.copyWith(selectedTab: ChatsTab.active));
    await tester.pump();
    scrollable = find.byType(Scrollable).hitTestable();
    expect(
      tester.state<ScrollableState>(scrollable).position.pixels,
      activeOffset,
    );

    controller.add(initial.copyWith(selectedTab: ChatsTab.archived));
    await tester.pump();
    scrollable = find.byType(Scrollable).hitTestable();
    expect(
      tester.state<ScrollableState>(scrollable).position.pixels,
      archivedOffset,
    );
  });

  testWidgets('shows a loading footer and retries the failed page', (
    tester,
  ) async {
    final bloc = mockChatsBloc(
      ChatsState.test(
        activeFeed: _feed(
          startId: 100,
          length: 2,
          isLoadingMore: true,
          errorMessage: 'network failure',
          failedPage: 2,
        ),
      ),
    );
    await _pump(tester, bloc);

    expect(find.text('Loading more chats'), findsOneWidget);
    expect(find.text("Couldn't load chats. Please try again."), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();

    verify(
      () => bloc.add(const ChatsLoadMoreRequested(ChatsTab.active)),
    ).called(1);
  });
}
