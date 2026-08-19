import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_card_image.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/utils/extensions/date_time_extensions.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking});

  final BookingDetail booking;

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    final statusStyle = _statusStyle(context, booking.status);

    return Material(
      color: theme.bgSurfaceBase2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.strokeNeutralLight200),
      ),
      child: InkWell(
        onTap: () =>
            context.router.push(BookingStatusRoute(bookingId: booking.id)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: .start,
            children: [
              SizedBox(
                height: 88,
                width: 88,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ListingCardImage(
                    imageUrl: booking.listing.coverImageUrl,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    Text(
                      booking.listing.title,
                      style: AppTextStyles.p2Medium.copyWith(
                        color: theme.textNeutralPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      booking.listing.address,
                      style: AppTextStyles.p3Regular.copyWith(
                        color: theme.textNeutralSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(
                          TablerIcons.calendar,
                          size: 16,
                          color: theme.iconNeutralDefault,
                        ),
                        const SizedBox(width: 6.0),
                        Expanded(
                          child: Text(
                            '${booking.startDate.format()} – '
                            '${booking.endDate.format()}',
                            style: AppTextStyles.p3Medium.copyWith(
                              color: theme.textNeutralPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_amount(booking.amount)} ${booking.currency}',
                            style: AppTextStyles.p3SemiBold.copyWith(
                              color: theme.textNeutralPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusStyle.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            statusStyle.label,
                            style: AppTextStyles.p3SemiBold.copyWith(
                              color: statusStyle.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _BookingStatusStyle _statusStyle(BuildContext context, BookingStatus status) {
    final theme = context.currentTheme;
    final localization = context.localization;
    return switch (status) {
      BookingStatus.confirmed => _BookingStatusStyle(
        color: theme.textSuccessPrimary,
        label: localization.booking_status_confirmed,
      ),
      BookingStatus.approved => _BookingStatusStyle(
        color: theme.textSuccessPrimary,
        label: localization.booking_status_approved,
      ),
      BookingStatus.requested => _BookingStatusStyle(
        color: theme.textBrandPrimary,
        label: localization.booking_status_requested,
      ),
      BookingStatus.paymentPending => _BookingStatusStyle(
        color: theme.textBrandPrimary,
        label: localization.booking_status_payment_pending,
      ),
      BookingStatus.rejected => _BookingStatusStyle(
        color: theme.textErrorPrimary,
        label: localization.booking_status_rejected,
      ),
      BookingStatus.cancelled => _BookingStatusStyle(
        color: theme.textErrorPrimary,
        label: localization.booking_status_cancelled,
      ),
      BookingStatus.paymentFailed => _BookingStatusStyle(
        color: theme.textErrorPrimary,
        label: localization.booking_status_payment_failed,
      ),
      BookingStatus.paymentExpired => _BookingStatusStyle(
        color: theme.textErrorPrimary,
        label: localization.booking_status_payment_expired,
      ),
      BookingStatus.reconciliationRequired => _BookingStatusStyle(
        color: theme.textWarningPrimary,
        label: localization.booking_status_reconciliation_required,
      ),
    };
  }
}

class _BookingStatusStyle {
  const _BookingStatusStyle({required this.color, required this.label});

  final Color color;
  final String label;
}

String _amount(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);
