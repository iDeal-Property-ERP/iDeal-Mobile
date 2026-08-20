import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';

class ChannelPickerSheet extends StatelessWidget {
  const ChannelPickerSheet({
    required this.phoneNumber,
    this.availableChannels = const [telegramChannel, smsChannel],
    super.key,
  });

  static const telegramChannel = 'telegram';
  static const smsChannel = 'sms';

  final String phoneNumber;
  final List<String> availableChannels;

  @override
  Widget build(BuildContext context) {
    final hasTelegram = availableChannels.contains(telegramChannel);
    final hasSms = availableChannels.contains(smsChannel);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.currentTheme.strokeNeutralLight200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.localization.sign_in,
              style: AppTextStyles.h3.copyWith(
                color: context.currentTheme.textNeutralPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.localization.otp_channel_confirmation,
              style: AppTextStyles.p2Medium.copyWith(
                color: context.currentTheme.textNeutralSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              phoneNumber,
              style: AppTextStyles.p2Medium.copyWith(
                color: context.currentTheme.textBrandPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (hasTelegram)
              AppButton(
                label: context.localization.otp_channel_telegram,
                foregroundColor: context.currentTheme.textNeutralWhite,
                shouldSetFullWidth: true,
                size: AppButtonSize.large,
                onPressed: () => Navigator.of(context).pop(telegramChannel),
              ),
            if (hasTelegram && hasSms) const SizedBox(height: 12),
            if (hasSms)
              AppButton(
                label: context.localization.otp_channel_sms,
                style: hasTelegram
                    ? AppButtonStyle.outline
                    : AppButtonStyle.primary,
                foregroundColor: hasTelegram
                    ? null
                    : context.currentTheme.textNeutralWhite,
                shouldSetFullWidth: true,
                size: AppButtonSize.large,
                onPressed: () => Navigator.of(context).pop(smsChannel),
              ),
          ],
        ),
      ),
    );
  }
}
