import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/constants/analytics_constant.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ProfileSignOutButton extends StatelessWidget {
  const ProfileSignOutButton({super.key});

  static const Color _redColor = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardBg = isDark ? context.currentTheme.bgSurfaceBase2 : Colors.white;

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: () => _confirmAndSignOut(context),
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: _redColor, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(TablerIcons.logout, size: 18.0, color: _redColor),
              const SizedBox(width: 8.0),
              Text(
                context.localization.sign_out,
                style: AppTextStyles.p2Bold.copyWith(
                  color: _redColor,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.localization.sign_out),
        content: Text(context.localization.sign_out_confirmation_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.localization.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.localization.sign_out),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    Clarity.sendCustomEvent(kClarityEventSignOutClicked);
    context.read<ProfileBloc>().add(const SignOutEvent());
  }
}
