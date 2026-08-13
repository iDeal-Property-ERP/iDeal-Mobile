import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/login/models/login_details.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:ideal_mobile/shared_pref/pref_keys.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:ideal_mobile/utils/extensions/primitive_types_extensions.dart';

class GuestAccessService {
  const GuestAccessService._();

  static Future<bool> hasAuthenticatedSession() async {
    final userDetailsJson = await Prefs.getString(PrefKeys.kUserDetails);
    final userDetails = LoginDetails.fromJson(
      json.decode(userDetailsJson ?? '{}'),
    );
    final secureAccessToken = await SecureStorageService().getAccessToken();

    return secureAccessToken.haveContent() ||
        userDetails.accessToken.haveContent() ||
        userDetails.token.haveContent();
  }

  static Future<bool> requireAuthentication(
    BuildContext context, {
    Future<void> Function()? onAuthenticationRequired,
  }) async {
    if (await hasAuthenticatedSession()) return true;
    if (!context.mounted) return false;

    final shouldLogin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.localization.sign_in_required_title),
        content: Text(dialogContext.localization.sign_in_required_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.localization.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.localization.log_in),
          ),
        ],
      ),
    );

    if (shouldLogin != true || !context.mounted) return false;

    await onAuthenticationRequired?.call();
    if (!context.mounted) return false;
    await context.router.replace(LoginWithPhoneNumberRoute());
    return false;
  }
}
