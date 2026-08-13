import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/booking/booking_intent_service.dart';
import 'package:ideal_mobile/presentation/booking/domain/entities/booking.dart';
import 'package:ideal_mobile/presentation/chat/bloc/open_conversation_cubit.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/services/guest_access_service.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_state_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingDetailBottomBar extends StatelessWidget {
  const ListingDetailBottomBar({
    super.key,
    required this.detail,
    this.actionsEnabled = true,
    this.openConversationCubit,
    this.onBook,
  });

  final ListingDetail detail;

  /// Preview details are display-only until the authoritative detail arrives.
  final bool actionsEnabled;
  final OpenConversationCubit? openConversationCubit;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    final canBook = actionsEnabled && detail.booking.eligible;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.currentTheme.bgSurfaceBase2,
        border: Border(
          top: BorderSide(color: context.currentTheme.strokeNeutralLight100),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatPrice(detail.price, detail.currency),
                    style: AppTextStyles.h5Bold.copyWith(
                      color: context.currentTheme.textNeutralPrimary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    context.localization.listings_per_month,
                    style: AppTextStyles.p3Regular.copyWith(
                      color: context.currentTheme.textNeutralSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (canBook) ...[
                AppButton(
                  key: keys.listingDetail.bookButton,
                  size: AppButtonSize.large,
                  label: context.localization.booking_book_and_pay,
                  leftIcon: TablerIcons.calendar_check,
                  shouldSetFullWidth: true,
                  borderRadius: 12,
                  onPressed: onBook ?? () => _openBooking(context),
                ),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: Center(child: _messageButton(context)),
                    ),
                  ),
                  if (detail.contactPhone != null) ...[
                    const SizedBox(width: 12),
                    _CallButton(
                      key: keys.listingDetail.callButton,
                      label: context.localization.listing_detail_call,
                      phone: detail.contactPhone!,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openBooking(BuildContext context) async {
    if (!await GuestAccessService.hasAuthenticatedSession()) {
      await GuestAccessService.requireAuthentication(
        context,
        onAuthenticationRequired: () => BookingIntentService.save(detail.id),
      );
      return;
    }
    if (!context.mounted) return;
    final options = _initialOptions();
    await context.pushRoute(
      BookingRoute(listingId: detail.id, initialOptions: options),
    );
  }

  Future<void> _openConversation(BuildContext context) async {
    if (!await GuestAccessService.requireAuthentication(context)) return;
    if (!context.mounted) return;

    await context.read<OpenConversationCubit>().open(detail.id);
  }

  Widget _messageButton(BuildContext context) {
    if (!actionsEnabled || !detail.canMessage) {
      return _buildMessageButton(context, isEnabled: false, isLoading: false);
    }

    final listener = BlocConsumer<OpenConversationCubit, OpenConversationState>(
      listener: _listenToConversation,
      builder: (context, state) {
        final isLoading = _isLoading(state);
        return _buildMessageButton(
          context,
          isEnabled: !isLoading,
          isLoading: isLoading,
        );
      },
    );

    final cubit = openConversationCubit;
    if (cubit != null) {
      return BlocProvider<OpenConversationCubit>.value(
        value: cubit,
        child: listener,
      );
    }

    return BlocProvider<OpenConversationCubit>(
      create: (_) => OpenConversationCubit(),
      child: listener,
    );
  }

  Widget _buildMessageButton(
    BuildContext context, {
    required bool isEnabled,
    required bool isLoading,
  }) {
    final canMessage = detail.canMessage;
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: canMessage
          ? context.localization.listing_detail_message
          : context.localization.listing_detail_message_unavailable,
      child: AppButton(
        key: keys.listingDetail.messageButton,
        style: detail.booking.eligible
            ? AppButtonStyle.secondary
            : AppButtonStyle.primary,
        size: AppButtonSize.large,
        label: context.localization.listing_detail_message,
        leftIcon: TablerIcons.message,
        shouldSetFullWidth: true,
        borderRadius: 12,
        state: canMessage ? AppButtonState.normal : AppButtonState.disabled,
        isLoading: isLoading,
        foregroundColor: canMessage && !detail.booking.eligible
            ? context.currentTheme.textNeutralWhite
            : null,
        backgroundColor: canMessage && !detail.booking.eligible
            ? context.currentTheme.bgBrandDefault
            : null,
        onPressed: isEnabled
            ? () async {
                await _openConversation(context);
              }
            : null,
      ),
    );
  }

  void _listenToConversation(
    BuildContext context,
    OpenConversationState state,
  ) {
    if (state.status == OpenConversationStatus.success) {
      final conversationId = state.conversationId;
      if (conversationId is int && context.mounted) {
        context.pushRoute(
          ChatConversationRoute(conversationId: conversationId),
        );
      }
    } else if (state.status == OpenConversationStatus.failure) {
      final message = state.errorMessage;
      if (message is String && message.isNotEmpty) {
        context.showSnackBar(message);
      }
    }
  }

  bool _isLoading(OpenConversationState state) =>
      state.status == OpenConversationStatus.loading;

  BookingOptions? _initialOptions() {
    final rent = detail.price;
    final deposit = detail.depositAmount;
    if (rent == null || deposit == null || !detail.booking.eligible) {
      return null;
    }
    return BookingOptions(
      listingId: detail.id,
      monthlyRent: rent,
      depositAmount: deposit,
      currency: detail.currency,
      eligibility: detail.booking,
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({super.key, required this.label, required this.phone});

  final String label;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: context.currentTheme.bgSurfaceBase2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final uri = Uri.parse('tel:$phone');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              context.showSnackBar(
                context.localization.opps_something_went_wrong,
              );
            }
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.currentTheme.strokeNeutralLight100,
              ),
            ),
            child: Icon(
              TablerIcons.phone,
              size: 20,
              color: context.currentTheme.textNeutralPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

String _formatPrice(double? price, String currency) {
  if (price == null) return '—';

  final amount = price == price.roundToDouble()
      ? price.toInt().toString()
      : price.toString();

  return currency == 'USD' ? '\$$amount' : '$amount $currency';
}
