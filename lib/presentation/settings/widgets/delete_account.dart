import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/delete_account/delete_account_screen.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';

class DeleteAccount extends StatelessWidget {
  const DeleteAccount({super.key});

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
        leading: Icon(TablerIcons.trash, color: foregroundColor),
        title: Text(
          context.localization.delete_account,
          style: AppTextStyles.p2Regular.copyWith(color: foregroundColor),
        ),
        trailing: Icon(TablerIcons.chevron_right, color: foregroundColor),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const DeleteAccountScreen())),
      ),
    );
  }
}
