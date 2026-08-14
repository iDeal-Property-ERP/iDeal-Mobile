import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:url_launcher/url_launcher.dart';

class SslFailedButton extends StatelessWidget {
  const SslFailedButton({super.key});

  static const _appStoreUrl = 'https://apps.apple.com/app/';
  static const _playStoreUrl = 'https://play.google.com/store/apps/details?id=';

  @override
  Widget build(BuildContext context) {
    return AppButton(
      foregroundColor: context.currentTheme.textNeutralLight,
      label: context.localization.update_app,
      size: AppButtonSize.extraLarge,
      shouldSetFullWidth: true,
      onPressed: () async {
        await _launchAppStore(context);
      },
    );
  }

  Future<void> _launchAppStore(BuildContext context) async {
    Uri url;

    if (Platform.isIOS) {
      url = Uri.parse(_appStoreUrl);
    } else if (Platform.isAndroid) {
      url = Uri.parse(_playStoreUrl);
    } else {
      context.showSnackBar(context.localization.platform_not_supported);
      return;
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      context.showSnackBar(context.localization.could_not_launch_store_link);
    }
  }
}
