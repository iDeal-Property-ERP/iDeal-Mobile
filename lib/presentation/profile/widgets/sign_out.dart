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
import 'package:ideal_mobile/widgets/styling/app_colors.dart';

class SignOut extends StatelessWidget {
  const SignOut({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final backgroundColor = isDark
        ? AppColors.redError950
        : context.currentTheme.bgErrorLight50;
    final foregroundColor = isDark
        ? AppColors.redError100
        : context.currentTheme.textErrorPrimary;

    return Material(
      color: backgroundColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.currentTheme.strokeErrorDefault),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(TablerIcons.arrow_left_from_arc, color: foregroundColor),
        title: Text(
          context.localization.sign_out,
          style: AppTextStyles.p2Regular.copyWith(color: foregroundColor),
        ),
        onTap: () => _confirmAndSignOut(context),
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
