import 'package:flutter/material.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/settings/legal_web_page_screen.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalWebPageScreen(
      title: context.localization.terms_and_conditions,
      path: '/tos',
    );
  }
}
