import 'package:flutter/material.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/settings/legal_web_page_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalWebPageScreen(
      title: context.localization.privacy_policy,
      path: '/privacy-policy',
    );
  }
}
