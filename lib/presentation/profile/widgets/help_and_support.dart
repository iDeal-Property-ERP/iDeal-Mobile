import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/contact_us/contact_us_screen.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/utils/app_flavor_env.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupport extends StatelessWidget {
  const HelpAndSupport({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: context.currentTheme.bgSurfaceBase2,
      leading: Icon(
        TablerIcons.lifebuoy,
        color: context.currentTheme.iconNeutralDefault,
      ),
      title: Text(
        context.localization.help_and_support,
        style: AppTextStyles.h6SemiBold.copyWith(
          color: context.currentTheme.textNeutralPrimary,
        ),
      ),
      trailing: Icon(
        TablerIcons.chevron_right,
        color: context.currentTheme.iconNeutralDefault,
      ),
      onTap: () => _showContactOptions(context),
    );
  }

  Future<void> _showContactOptions(BuildContext context) async {
    final profile = context.read<ProfileBloc>().state.profile;
    final telegramUri = _httpsUri(AppConfig.supportTelegramUrl);
    final whatsAppUri = _httpsUri(AppConfig.supportWhatsAppUrl);

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.localization.help_and_support,
                style: AppTextStyles.h6SemiBold.copyWith(
                  color: context.currentTheme.textNeutralPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(TablerIcons.message),
                title: Text(context.localization.contact_us),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ContactUsScreen(profile: profile),
                    ),
                  );
                },
              ),
              if (telegramUri != null)
                ListTile(
                  leading: const Icon(TablerIcons.brand_telegram),
                  title: const Text('Telegram'),
                  onTap: () =>
                      _openExternal(context, sheetContext, telegramUri),
                ),
              if (whatsAppUri != null)
                ListTile(
                  leading: const Icon(TablerIcons.brand_whatsapp),
                  title: const Text('WhatsApp'),
                  onTap: () =>
                      _openExternal(context, sheetContext, whatsAppUri),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Uri? _httpsUri(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty
        ? uri
        : null;
  }

  Future<void> _openExternal(
    BuildContext context,
    BuildContext sheetContext,
    Uri uri,
  ) async {
    Navigator.of(sheetContext).pop();
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (context.mounted && !launched) {
      context.showSnackBar(
        context.localization.opps_something_went_wrong,
        isDisplayingError: true,
      );
    }
  }
}
