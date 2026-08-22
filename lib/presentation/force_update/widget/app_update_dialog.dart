import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/force_update/models/app_update_info.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateDialog extends StatefulWidget {
  const AppUpdateDialog({
    required this.updateInfo,
    this.launchUrlHandler,
    super.key,
  });

  final AppUpdateInfo updateInfo;
  final Future<bool> Function(Uri uri, LaunchMode mode)? launchUrlHandler;

  static Future<bool?> show(
    BuildContext context, {
    required AppUpdateInfo updateInfo,
    Future<bool> Function(Uri uri, LaunchMode mode)? launchUrlHandler,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xB8000000),
      builder: (dialogContext) => AppUpdateDialog(
        updateInfo: updateInfo,
        launchUrlHandler: launchUrlHandler,
      ),
    );
  }

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  bool _isLaunching = false;
  String? _errorMessage;

  Future<void> _handleUpdate() async {
    final storeUrl = widget.updateInfo.storeUrl;
    if (storeUrl == null || storeUrl.isEmpty) {
      setState(() {
        _errorMessage = context.localization.could_not_launch_store_link;
      });
      return;
    }

    final uri = Uri.tryParse(storeUrl);
    if (uri == null) {
      setState(() {
        _errorMessage = context.localization.could_not_launch_store_link;
      });
      return;
    }

    setState(() {
      _isLaunching = true;
      _errorMessage = null;
    });

    bool launched = false;
    try {
      if (widget.launchUrlHandler != null) {
        launched = await widget.launchUrlHandler!(
          uri,
          LaunchMode.externalApplication,
        );
      } else {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      launched = false;
    }

    if (!mounted) return;

    setState(() {
      _isLaunching = false;
    });

    if (launched) {
      // For normal updates, close dialog and allow user to continue.
      // For critical updates, dialog remains visible on return.
      if (widget.updateInfo.isNormal) {
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() {
        _errorMessage = context.localization.could_not_launch_store_link;
      });
      try {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(context.localization.could_not_launch_store_link),
            backgroundColor: AppColors.errorColor,
          ),
        );
      } catch (_) {}
    }
  }

  void _handleSkip() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.localization;
    final isCritical = widget.updateInfo.isCritical;

    return PopScope(
      canPop: false,
      child: Dialog(
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
              Center(
                child: Image.asset(
                  Assets.icons.loginLogo.path,
                  width: 52,
                  height: 52,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                localization.its_time_to_update,
                textAlign: TextAlign.center,
                style: AppTextStyles.h6SemiBold.copyWith(
                  color: AppColors.neutral50,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localization.update_required_description,
                textAlign: TextAlign.center,
                style: AppTextStyles.p3Regular.copyWith(
                  color: AppColors.neutral300,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.p4Regular.copyWith(
                    color: AppColors.errorColor,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: localization.update_now,
                size: AppButtonSize.medium,
                shouldSetFullWidth: true,
                isLoading: _isLaunching,
                onPressed: _isLaunching ? null : _handleUpdate,
              ),
              if (!isCritical) ...[
                const SizedBox(height: 12),
                AppButton(
                  label: localization.skip_update,
                  style: AppButtonStyle.textOrIcon,
                  size: AppButtonSize.medium,
                  shouldSetFullWidth: true,
                  foregroundColor: AppColors.neutral300,
                  onPressed: _isLaunching ? null : _handleSkip,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
