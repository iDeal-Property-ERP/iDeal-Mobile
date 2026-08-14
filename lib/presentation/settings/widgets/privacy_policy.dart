import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/settings/privacy_policy_screen.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      leading: Icon(
        TablerIcons.file_text,
        color: context.currentTheme.iconNeutralDefault,
      ),
      title: Text(
        context.localization.privacy_policy,
        style: AppTextStyles.p2Regular.copyWith(
          color: context.currentTheme.textNeutralPrimary,
        ),
      ),
      trailing: Icon(
        TablerIcons.chevron_right,
        color: context.currentTheme.iconNeutralDefault,
      ),
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
      },
    );
  }
}
