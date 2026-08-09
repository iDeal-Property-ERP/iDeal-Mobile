import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_event.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState.initial()) {
    _setupEventListener();
  }

  void _setupEventListener() {
    on<BottomNavBarIndexChangedEvent>(_onBottomNavBarIndexChangedEvent);
  }

  void _onBottomNavBarIndexChangedEvent(
    BottomNavBarIndexChangedEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(currentBottomNavIndex: event.index));
  }
}
