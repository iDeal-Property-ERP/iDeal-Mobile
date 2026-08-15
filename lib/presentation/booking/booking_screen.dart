import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/booking/bloc/booking_bloc.dart';
import 'package:ideal_mobile/presentation/booking/bloc/booking_event.dart';
import 'package:ideal_mobile/presentation/booking/bloc/booking_state.dart';
import 'package:ideal_mobile/presentation/booking/data/active_checkout_store.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/presentation/booking/domain/repositories/booking_repository.dart';
import 'package:ideal_mobile/presentation/booking/widgets/booking_status_view.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class BookingScreen extends StatefulWidget {
  const BookingScreen({
    super.key,
    @PathParam('listingId') required this.listingId,
    this.initialOptions,
  });

  final int listingId;
  final BookingOptions? initialOptions;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with WidgetsBindingObserver {
  late final BookingBloc _bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bloc =
        BookingBloc(
          repository: sl<BookingRepository>(),
          activeCheckoutStore: sl<ActiveCheckoutStore>(),
        )..add(
          BookingStarted(
            widget.listingId,
            initialOptions: widget.initialOptions?.listingId == widget.listingId
                ? widget.initialOptions
                : null,
          ),
        );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final bookingId = _bloc.state.checkout?.bookingId;
      if (bookingId != null) _bloc.add(BookingStatusRequested(bookingId));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_bloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookingBloc>.value(
      value: _bloc,
      child: BlocConsumer<BookingBloc, BookingState>(
        listener: _listen,
        builder: (context, state) => Scaffold(
          appBar: AppTopBar.page(title: context.localization.booking_title),
          body: _body(context, state),
        ),
      ),
    );
  }

  Future<void> _listen(BuildContext context, BookingState state) async {
    if (state.status == BookingFlowStatus.checkoutReady &&
        state.checkout != null &&
        state.booking == null) {
      final launched = await launchUrl(
        state.checkout!.checkoutUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        context.showSnackBar(
          context.localization.booking_checkout_launch_failed,
          isDisplayingError: true,
        );
      }
    }
    final message = state.errorMessage;
    if (state.status == BookingFlowStatus.error &&
        message != null &&
        context.mounted) {
      context.showSnackBar(message, isDisplayingError: true);
    }
  }

  Widget _body(BuildContext context, BookingState state) {
    if (state.status == BookingFlowStatus.loading ||
        state.status == BookingFlowStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.checkout != null || state.booking != null) {
      return BookingStatusView(
        state: state,
        onRefresh: state.checkout == null
            ? null
            : () => context.read<BookingBloc>().add(
                BookingStatusRequested(state.checkout!.bookingId),
              ),
      );
    }

    final options = state.options;
    if (options == null) {
      return _ErrorView(
        message: state.errorMessage,
        onRetry: () =>
            context.read<BookingBloc>().add(BookingStarted(widget.listingId)),
      );
    }
    if (!options.eligibility.eligible) {
      return _UnavailableView(reason: options.eligibility.reason);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (!state.optionsConfirmed && state.errorMessage != null) ...[
          Text(
            state.errorMessage!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          TextButton(
            onPressed: () => context.read<BookingBloc>().add(
              BookingStarted(
                widget.listingId,
                initialOptions:
                    widget.initialOptions?.listingId == widget.listingId
                    ? widget.initialOptions
                    : null,
              ),
            ),
            child: Text(context.localization.retry),
          ),
        ],
        Text(
          context.localization.booking_choose_dates,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          context.localization.booking_dates_inclusive,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: state.isBusy || !state.optionsConfirmed
              ? null
              : () => _chooseRange(context, options.eligibility),
          icon: const Icon(TablerIcons.calendar),
          label: Text(
            state.range == null
                ? context.localization.booking_select_dates
                : '${_date(state.range!.startDate)} – '
                      '${_date(state.range!.endDate)}',
          ),
        ),
        const SizedBox(height: 12),
        _QuickDurations(
          minimumMonths: options.eligibility.minimumStayMonths,
          enabled: state.range != null && state.optionsConfirmed,
          onSelected: (months) => _applyDuration(
            context,
            state.range!.startDate,
            months,
            options.eligibility,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed:
              state.range == null || state.isBusy || !state.optionsConfirmed
              ? null
              : () => context.read<BookingBloc>().add(
                  const BookingQuoteRequested(),
                ),
          child: state.status == BookingFlowStatus.quoting
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.localization.booking_get_quote),
        ),
        if (state.quote != null) ...[
          const SizedBox(height: 24),
          _QuoteCard(state: state),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(context.localization.booking_pay_full_stay),
            subtitle: Text(context.localization.booking_pay_full_stay_note),
            value: state.paymentChoice == BookingPaymentChoice.fullStay,
            onChanged: state.isBusy || !state.optionsConfirmed
                ? null
                : (value) => context.read<BookingBloc>().add(
                    BookingPaymentChoiceChanged(
                      value
                          ? BookingPaymentChoice.fullStay
                          : BookingPaymentChoice.firstMonth,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            context.localization.booking_payment_method,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.eligibility.providers
                .map(
                  (provider) => ChoiceChip(
                    selected: state.provider == provider,
                    label: Text(_providerLabel(provider)),
                    onSelected: state.isBusy || !state.optionsConfirmed
                        ? null
                        : (_) => context.read<BookingBloc>().add(
                            BookingProviderChanged(provider),
                          ),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed:
                state.provider == null ||
                    state.isBusy ||
                    !state.optionsConfirmed
                ? null
                : () => context.read<BookingBloc>().add(
                    const BookingCheckoutRequested(),
                  ),
            icon: const Icon(TablerIcons.external_link),
            label: state.status == BookingFlowStatus.creatingCheckout
                ? Text(context.localization.booking_preparing_checkout)
                : Text(context.localization.booking_continue_to_payment),
          ),
          const SizedBox(height: 8),
          Text(
            context.localization.booking_hosted_payment_note,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Future<void> _chooseRange(
    BuildContext context,
    BookingEligibility eligibility,
  ) async {
    final now = DateTime.now();
    final firstDate =
        eligibility.earliestStartDate ?? DateTime(now.year, now.month, now.day);
    final lastDate =
        eligibility.latestEndDate ?? DateTime(now.year + 3, now.month, now.day);
    final start = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: _firstAvailable(firstDate, lastDate, eligibility),
      selectableDayPredicate: (day) => !eligibility.isBlocked(day),
      helpText: context.localization.booking_choose_start_date,
    );
    if (start == null || !context.mounted) return;
    final minimumEnd = _endForMonths(start, eligibility.minimumStayMonths);
    if (minimumEnd.isAfter(lastDate)) {
      context.showSnackBar(
        context.localization.booking_range_unavailable,
        isDisplayingError: true,
      );
      return;
    }
    final end = await showDatePicker(
      context: context,
      firstDate: minimumEnd,
      lastDate: lastDate,
      initialDate: minimumEnd,
      selectableDayPredicate: (day) =>
          !eligibility.isBlocked(day) &&
          !_crossesBlockedDate(start, day, eligibility),
      helpText: context.localization.booking_choose_end_date,
    );
    if (end == null || !context.mounted) return;
    context.read<BookingBloc>().add(
      BookingRangeChanged(BookingDateRange(startDate: start, endDate: end)),
    );
  }

  void _applyDuration(
    BuildContext context,
    DateTime start,
    int months,
    BookingEligibility eligibility,
  ) {
    final end = _endForMonths(start, months);
    if ((eligibility.latestEndDate?.isBefore(end) ?? false) ||
        _crossesBlockedDate(start, end, eligibility)) {
      context.showSnackBar(
        context.localization.booking_range_unavailable,
        isDisplayingError: true,
      );
      return;
    }
    context.read<BookingBloc>().add(
      BookingRangeChanged(BookingDateRange(startDate: start, endDate: end)),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final quote = state.quote!;
    final option = state.paymentChoice == BookingPaymentChoice.fullStay
        ? quote.fullStay
        : quote.firstMonth;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.localization.booking_price_summary,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _AmountRow(
              label: context.localization.booking_deposit,
              amount: quote.depositAmount,
              currency: quote.currency,
            ),
            const SizedBox(height: 8),
            _AmountRow(
              label: context.localization.booking_rent,
              amount: option.rentAmount,
              currency: quote.currency,
            ),
            const Divider(height: 24),
            _AmountRow(
              label: context.localization.booking_total_due_now,
              amount: option.totalAmount,
              currency: quote.currency,
              emphasized: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.amount,
    required this.currency,
    this.emphasized = false,
  });

  final String label;
  final double amount;
  final String currency;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(label)),
      Text(
        '${_amount(amount)} $currency',
        style: emphasized
            ? Theme.of(context).textTheme.titleMedium
            : Theme.of(context).textTheme.bodyMedium,
      ),
    ],
  );
}

class _QuickDurations extends StatelessWidget {
  const _QuickDurations({
    required this.minimumMonths,
    required this.enabled,
    required this.onSelected,
  });

  final int minimumMonths;
  final bool enabled;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final values = <int>{
      minimumMonths,
      1,
      3,
      6,
      12,
    }.where((value) => value >= minimumMonths).toList()..sort();
    return Wrap(
      spacing: 8,
      children: values
          .map(
            (months) => ActionChip(
              onPressed: enabled ? () => onSelected(months) : null,
              label: Text(context.localization.booking_months(months)),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _UnavailableView extends StatelessWidget {
  const _UnavailableView({this.reason});

  final String? reason;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(TablerIcons.calendar_off, size: 56),
          const SizedBox(height: 16),
          Text(
            context.localization.booking_unavailable,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (reason != null) ...[
            const SizedBox(height: 8),
            Text(reason!, textAlign: TextAlign.center),
          ],
        ],
      ),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message ?? context.localization.opps_something_went_wrong,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(context.localization.listing_detail_retry),
          ),
        ],
      ),
    ),
  );
}

DateTime _firstAvailable(
  DateTime first,
  DateTime last,
  BookingEligibility eligibility,
) {
  var candidate = first;
  while (!candidate.isAfter(last) && eligibility.isBlocked(candidate)) {
    candidate = candidate.add(const Duration(days: 1));
  }
  return candidate.isAfter(last) ? first : candidate;
}

bool _crossesBlockedDate(
  DateTime start,
  DateTime end,
  BookingEligibility eligibility,
) => eligibility.blockedRanges.any(
  (blocked) =>
      !blocked.endDate.isBefore(start) && !blocked.startDate.isAfter(end),
);

DateTime _endForMonths(DateTime start, int months) {
  final anniversary = _addMonths(start, months);
  return anniversary.subtract(const Duration(days: 1));
}

DateTime _addMonths(DateTime value, int months) {
  final totalMonths = value.year * 12 + value.month - 1 + months;
  final year = totalMonths ~/ 12;
  final month = totalMonths % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, value.day.clamp(1, lastDay));
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}.'
    '${value.month.toString().padLeft(2, '0')}.${value.year}';

String _amount(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);

String _providerLabel(PaymentProvider provider) => switch (provider) {
  PaymentProvider.payme => 'Payme',
  PaymentProvider.click => 'Click',
  PaymentProvider.stripe => 'Stripe',
};
