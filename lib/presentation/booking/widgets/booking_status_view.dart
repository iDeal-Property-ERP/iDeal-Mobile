import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/booking/bloc/booking_state.dart';

class BookingStatusView extends StatelessWidget {
  const BookingStatusView({super.key, required this.state, this.onRefresh});

  final BookingState state;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final config = _config(context);
    final booking = state.booking;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(config.icon, size: 64, color: config.color),
            const SizedBox(height: 20),
            Text(
              config.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              config.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (booking != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        booking.listing.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(booking.listing.address),
                      const Divider(height: 24),
                      Text(
                        '${_date(booking.startDate)} – '
                        '${_date(booking.endDate)}',
                      ),
                      const SizedBox(height: 6),
                      Text('${_amount(booking.amount)} ${booking.currency}'),
                    ],
                  ),
                ),
              ),
            ],
            if (onRefresh != null &&
                state.status == BookingFlowStatus.checkoutReady) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRefresh,
                icon: const Icon(TablerIcons.refresh),
                label: Text(context.localization.booking_check_status),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _StatusConfig _config(BuildContext context) => switch (state.status) {
    BookingFlowStatus.confirmed => _StatusConfig(
      icon: TablerIcons.circle_check,
      color: Colors.green,
      title: context.localization.booking_confirmed_title,
      message: context.localization.booking_confirmed_message,
    ),
    BookingFlowStatus.failed => _StatusConfig(
      icon: TablerIcons.circle_x,
      color: Colors.red,
      title: context.localization.booking_failed_title,
      message: context.localization.booking_failed_message,
    ),
    BookingFlowStatus.expired => _StatusConfig(
      icon: TablerIcons.clock_x,
      color: Colors.orange,
      title: context.localization.booking_expired_title,
      message: context.localization.booking_expired_message,
    ),
    BookingFlowStatus.reconciliationRequired => _StatusConfig(
      icon: TablerIcons.alert_triangle,
      color: Colors.orange,
      title: context.localization.booking_review_title,
      message: context.localization.booking_review_message,
    ),
    _ => _StatusConfig(
      icon: TablerIcons.clock_hour_4,
      color: Theme.of(context).colorScheme.primary,
      title: context.localization.booking_pending_title,
      message: context.localization.booking_pending_message,
    ),
  };
}

class _StatusConfig {
  const _StatusConfig({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}.'
    '${value.month.toString().padLeft(2, '0')}.${value.year}';

String _amount(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);
