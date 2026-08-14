import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/login/models/login_details.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:ideal_mobile/shared_pref/pref_keys.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:ideal_mobile/utils/extensions/primitive_types_extensions.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';

class GuestAccessService {
  const GuestAccessService._();

  static Future<bool> hasAuthenticatedSession() async {
    final userDetailsJson = await Prefs.getString(PrefKeys.kUserDetails);
    final userDetails = LoginDetails.fromJson(
      json.decode(userDetailsJson ?? '{}'),
    );
    final secureAccessToken = await SecureStorageService().getAccessToken();

    return secureAccessToken.haveContent() ||
        userDetails.accessToken.haveContent();
  }

  static Future<bool> requireAuthentication(
    BuildContext context, {
    Future<void> Function()? onAuthenticationRequired,
  }) async {
    if (await hasAuthenticatedSession()) return true;
    if (!context.mounted) return false;

    final shouldLogin = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0xB8000000),
      builder: (dialogContext) => const _GuestAuthenticationDialog(),
    );

    if (shouldLogin != true || !context.mounted) return false;

    await onAuthenticationRequired?.call();
    if (!context.mounted) return false;
    await context.router.replace(const LoginWithPhoneNumberRoute());
    return false;
  }
}

class _GuestAuthenticationDialog extends StatelessWidget {
  const _GuestAuthenticationDialog();

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgSurfaceSheetDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.dark400),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 32,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(Assets.icons.loginLogo.path, width: 52, height: 52),
            const SizedBox(height: 20),
            Text(
              localization.sign_in_required_title,
              style: AppTextStyles.h6SemiBold.copyWith(
                color: AppColors.neutral50,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localization.sign_in_required_message,
              style: AppTextStyles.p3Regular.copyWith(
                color: AppColors.neutral300,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: localization.guest_access_sign_in,
              size: AppButtonSize.large,
              shouldSetFullWidth: true,
              rightIcon: TablerIcons.arrow_right,
              foregroundColor: AppColors.white,
              backgroundColor: AppColors.brand600,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: localization.guest_access_keep_browsing,
              style: AppButtonStyle.outline,
              size: AppButtonSize.large,
              shouldSetFullWidth: true,
              foregroundColor: AppColors.neutral100,
              backgroundColor: AppColors.dark900,
              borderColor: AppColors.dark400,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}
