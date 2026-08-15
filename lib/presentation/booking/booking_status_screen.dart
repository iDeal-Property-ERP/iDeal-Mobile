import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/booking/bloc/booking_bloc.dart';
import 'package:ideal_mobile/presentation/booking/bloc/booking_event.dart';
import 'package:ideal_mobile/presentation/booking/bloc/booking_state.dart';
import 'package:ideal_mobile/presentation/booking/data/active_checkout_store.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/presentation/booking/domain/repositories/booking_repository.dart';
import 'package:ideal_mobile/presentation/booking/widgets/booking_status_view.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';

@RoutePage()
class BookingStatusScreen extends StatefulWidget {
  const BookingStatusScreen({
    super.key,
    @PathParam('bookingId') required this.bookingId,
    this.initialCheckout,
  });

  final int bookingId;
  final PaymentCheckout? initialCheckout;

  @override
  State<BookingStatusScreen> createState() => _BookingStatusScreenState();
}

class _BookingStatusScreenState extends State<BookingStatusScreen>
    with WidgetsBindingObserver {
  late final BookingBloc _bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bloc = BookingBloc(
      repository: sl<BookingRepository>(),
      activeCheckoutStore: sl<ActiveCheckoutStore>(),
      initialState: widget.initialCheckout?.bookingId == widget.bookingId
          ? BookingState(
              status: BookingFlowStatus.checkoutReady,
              checkout: widget.initialCheckout,
            )
          : const BookingState(),
    )..add(BookingStatusRequested(widget.bookingId));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _bloc.add(BookingStatusRequested(widget.bookingId));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_bloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<BookingBloc>.value(
    value: _bloc,
    child: Scaffold(
      appBar: AppTopBar.page(title: context.localization.booking_status_title),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if ((state.status == BookingFlowStatus.polling ||
                  state.status == BookingFlowStatus.initial) &&
              state.checkout == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return BookingStatusView(
            state: state,
            onRefresh: () =>
                _bloc.add(BookingStatusRequested(widget.bookingId)),
          );
        },
      ),
    ),
  );
}
