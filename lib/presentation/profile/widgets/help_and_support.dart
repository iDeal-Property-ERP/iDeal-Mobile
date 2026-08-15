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
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';
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
      barrierColor: AppColors.black.withOpacity(0.72),
      backgroundColor: context.currentTheme.bgSurfaceBase2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Text(
                context.localization.help_and_support,
                style: AppTextStyles.h6SemiBold.copyWith(
                  color: context.currentTheme.textNeutralPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _SupportOptionsCard(options: options, sheetContext: sheetContext),
            ],
          ),
        ),
      ),
    );
  }

  Uri? _httpsUri(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
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

class _SupportOptionsCard extends StatelessWidget {
  const _SupportOptionsCard({
    required this.options,
    required this.sheetContext,
  });

  final List<_SupportOptionItem> options;
  final BuildContext sheetContext;

  @override
  Widget build(BuildContext context) {
    final cardBg = context.isDark
        ? context.currentTheme.bgSurfaceBase
        : context.currentTheme.bgNeutralLight50;

    return Material(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.currentTheme.strokeNeutralLight200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: context.currentTheme.strokeNeutralLight200,
              ),
            ListTile(
              leading: Icon(
                options[i].icon,
                color: context.currentTheme.iconNeutralDefault,
              ),
              title: Text(
                options[i].title,
                style: AppTextStyles.p2Medium.copyWith(
                  color: context.currentTheme.textNeutralPrimary,
                ),
              ),
              trailing: Icon(
                TablerIcons.chevron_right,
                color: context.currentTheme.iconNeutralDefault,
              ),
              onTap: () => options[i].onTap(sheetContext),
            ),
          ],
        ],
      ),
    );
  }
}
