import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/contact_us/contact_us_screen.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/data/datasources/support_remote_data_source.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/haptic_feedback_util.dart';
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
      onTap: () => showContactOptions(context),
    );
  }

  static Future<void> showContactOptions(BuildContext context) async {
    final profile = context.read<ProfileBloc>().state.profile;
    final supportLinks = await sl<SupportRemoteDataSource>().getSupportLinks();
    if (!context.mounted) return;

    final telegramUri = _httpsUri(supportLinks.telegramUrl);
    final whatsAppUri = _httpsUri(supportLinks.whatsappUrl);

    final options = <_SupportOptionItem>[
      _SupportOptionItem(
        icon: TablerIcons.message,
        title: context.localization.contact_us,
        onTap: (sheetCtx) {
          Navigator.of(sheetCtx).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ContactUsScreen(profile: profile),
            ),
          );
        },
      ),
      if (telegramUri != null)
        _SupportOptionItem(
          icon: TablerIcons.brand_telegram,
          title: 'Telegram',
          onTap: (sheetCtx) => _openExternal(context, sheetCtx, telegramUri),
        ),
      if (whatsAppUri != null)
        _SupportOptionItem(
          icon: TablerIcons.brand_whatsapp,
          title: 'WhatsApp',
          onTap: (sheetCtx) => _openExternal(context, sheetCtx, whatsAppUri),
        ),
    ];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.currentTheme.bgSurfaceSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.currentTheme.strokeNeutralLight200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  context.localization.help_and_support,
                  style: AppTextStyles.h6Bold.copyWith(
                    color: context.currentTheme.textNeutralPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...options.map(
                (option) => _SupportOptionCard(
                  option: option,
                  onTap: () => option.onTap(sheetContext),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Uri? _httpsUri(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty
        ? uri
        : null;
  }

  static Future<void> _openExternal(
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

class _SupportOptionItem {
  const _SupportOptionItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final void Function(BuildContext sheetContext) onTap;
}

class _SupportOptionCard extends StatelessWidget {
  const _SupportOptionCard({required this.option, required this.onTap});

  final _SupportOptionItem option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: context.isDark
            ? context.currentTheme.bgSurfaceBase2
            : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: () async {
            await HapticFeedbackUtil.light();
            if (context.mounted) onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: context.currentTheme.strokeNeutralLight200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  option.icon,
                  color: context.currentTheme.iconNeutralDefault,
                  size: 22.0,
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Text(
                    option.title,
                    style: AppTextStyles.p2SemiBold.copyWith(
                      color: context.currentTheme.textNeutralPrimary,
                    ),
                  ),
                ),
                Icon(
                  TablerIcons.chevron_right,
                  color: context.currentTheme.iconNeutralDefault,
                  size: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
