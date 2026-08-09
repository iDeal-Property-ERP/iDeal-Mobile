import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_bloc.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_event.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_state.dart';

void main() {
  late HomeBloc homeBloc;

  setUp(() {
    homeBloc = HomeBloc();
  });

  tearDown(() async {
    await homeBloc.close();
  });

  group('HomeBloc', () {
    test('initial state contains the default navigation index', () {
      expect(homeBloc.state.currentBottomNavIndex, 0);
    });

    blocTest<HomeBloc, HomeState>(
      'updates the bottom navigation index',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const BottomNavBarIndexChangedEvent(index: 2)),
      expect: () => [
        isA<HomeState>().having(
          (state) => state.currentBottomNavIndex,
          'index',
          2,
        ),
      ],
    );
  });
}
