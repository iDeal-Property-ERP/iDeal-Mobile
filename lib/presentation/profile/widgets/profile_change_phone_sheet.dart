import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';

class ProfileChangePhoneSheet extends StatefulWidget {
  const ProfileChangePhoneSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.currentTheme.bgSurfaceSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: const ProfileChangePhoneSheet(),
      ),
    );
  }

  @override
  State<ProfileChangePhoneSheet> createState() =>
      _ProfileChangePhoneSheetState();
}

class _ProfileChangePhoneSheetState extends State<ProfileChangePhoneSheet> {
  final _phoneController = TextEditingController();
  var _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPhone =
        context.watch<ProfileBloc>().state.profile?.phone ?? '';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: context.currentTheme.strokeNeutralLight200,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.localization.change_phone_number,
                    style: AppTextStyles.h6Bold.copyWith(
                      color: context.currentTheme.textNeutralPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(TablerIcons.x),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              if (currentPhone.isNotEmpty) ...[
                Text(
                  'Hozirgi raqam:',
                  style: AppTextStyles.p4Medium.copyWith(
                    color: context.currentTheme.textNeutralSecondary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  currentPhone,
                  style: AppTextStyles.p2SemiBold.copyWith(
                    color: context.currentTheme.textNeutralPrimary,
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
              Text(
                'Yangi telefon raqami',
                style: AppTextStyles.p3Medium.copyWith(
                  color: context.currentTheme.textNeutralPrimary,
                ),
              ),
              const SizedBox(height: 6.0),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+998 90 123 45 67',
                  filled: true,
                  fillColor: context.isDark
                      ? context.currentTheme.bgSurfaceBase2
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: context.currentTheme.strokeNeutralLight200,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: context.currentTheme.strokeNeutralLight200,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                'Yangi raqamni tasdiqlash uchun SMS orqali bir martalik '
                'tasdiqlash kodi yuboriladi.',
                style: AppTextStyles.p4Regular.copyWith(
                  color: context.currentTheme.textNeutralSecondary,
                ),
              ),
              const SizedBox(height: 24.0),
              AppButton(
                label: 'Tasdiqlash kodini olish',
                shouldSetFullWidth: true,
                size: AppButtonSize.large,
                isLoading: _isLoading,
                onPressed: () {
                  final text = _phoneController.text.trim();
                  if (text.isEmpty) {
                    context.showSnackBar(
                      'Iltimos, telefon raqamini kiriting',
                      isDisplayingError: true,
                    );
                    return;
                  }
                  setState(() => _isLoading = true);
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) {
                      setState(() => _isLoading = false);
                      Navigator.of(context).pop();
                      context.showSnackBar('Tasdiqlash kodi yuborildi: $text');
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
