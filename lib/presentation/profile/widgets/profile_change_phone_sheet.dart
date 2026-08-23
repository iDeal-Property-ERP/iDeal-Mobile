import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/profile/bloc/phone_change_cubit.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_state_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';

class ProfileChangePhoneSheet extends StatefulWidget {
  const ProfileChangePhoneSheet({super.key});

  static Future<MobileUserProfile?> show(BuildContext context) {
    return showModalBottomSheet<MobileUserProfile>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.currentTheme.bgSurfaceSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ProfileBloc>()),
          BlocProvider(create: (_) => PhoneChangeCubit()),
        ],
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
  final _codeController = TextEditingController();
  Timer? _resendTimer;
  var _resendSeconds = 0;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPhone = context.select<ProfileBloc, String?>(
      (bloc) => bloc.state.profile?.phone,
    );
    return BlocListener<PhoneChangeCubit, PhoneChangeState>(
      listenWhen: (previous, current) =>
          previous.updatedProfile != current.updatedProfile ||
          previous.resendAfter != current.resendAfter ||
          previous.step != current.step,
      listener: (context, state) {
        final profile = state.updatedProfile;
        if (profile != null) {
          context.read<ProfileBloc>().add(SyncProfileEvent(profile: profile));
          Navigator.of(context).pop(profile);
          return;
        }
        if (state.step == PhoneChangeStep.code && state.resendAfter > 0) {
          _startResendTimer(state.resendAfter);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20.0),
            child: BlocBuilder<PhoneChangeCubit, PhoneChangeState>(
              builder: (context, state) => Column(
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
                    children: [
                      Expanded(
                        child: Text(
                          context.localization.change_phone_number,
                          style: AppTextStyles.h6Bold.copyWith(
                            color: context.currentTheme.textNeutralPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(TablerIcons.x),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  if (currentPhone != null && currentPhone.isNotEmpty) ...[
                    Text(
                      context.localization.phone_change_current_number,
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
                    const SizedBox(height: 20.0),
                  ],
                  if (state.errorMessage != null ||
                      state.noChannelsAvailable) ...[
                    Text(
                      state.noChannelsAvailable
                          ? context.localization.phone_change_no_channels
                          : state.errorMessage!,
                      style: AppTextStyles.p4Regular.copyWith(
                        color: context.currentTheme.textErrorSecondary,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                  ],
                  switch (state.step) {
                    PhoneChangeStep.number => _NumberStep(
                      controller: _phoneController,
                      isLoading: state.isLoading,
                      onSubmit: _start,
                    ),
                    PhoneChangeStep.channel => _ChannelStep(
                      phone: state.phone ?? '',
                      channels: state.channels,
                      isLoading: state.isLoading,
                      onSelect: (channel) => context
                          .read<PhoneChangeCubit>()
                          .requestOtp(state.phone ?? '', channel),
                    ),
                    PhoneChangeStep.code => _CodeStep(
                      controller: _codeController,
                      phone: state.phone ?? '',
                      channel: state.channel ?? '',
                      isConfirming: state.isConfirming,
                      resendSeconds: _resendSeconds,
                      isResending: state.isLoading,
                      onConfirm: () => context.read<PhoneChangeCubit>().confirm(
                        _codeController.text,
                      ),
                      onResend: () => context
                          .read<PhoneChangeCubit>()
                          .requestOtp(state.phone ?? '', state.channel ?? ''),
                      onEditNumber: () {
                        _codeController.clear();
                        context.read<PhoneChangeCubit>().editNumber();
                      },
                    ),
                  },
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _start() {
    final phone = _normalizePhone(_phoneController.text);
    if (!RegExp(r'^\+998\d{9}$').hasMatch(phone)) {
      context.showSnackBar(
        context.localization.invalid_mobile_number,
        isDisplayingError: true,
      );
      return;
    }
    context.read<PhoneChangeCubit>().start(phone);
  }

  String _normalizePhone(String value) {
    final compact = value.replaceAll(RegExp(r'[\s\-()]'), '');
    return compact.startsWith('+') ? compact : '+$compact';
  }

  void _startResendTimer(int seconds) {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = seconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendSeconds = 0);
      } else if (mounted) {
        setState(() => _resendSeconds -= 1);
      }
    });
  }
}

class _NumberStep extends StatelessWidget {
  const _NumberStep({
    required this.controller,
    required this.isLoading,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.localization.phone_change_new_number,
        style: AppTextStyles.p3Medium.copyWith(
          color: context.currentTheme.textNeutralPrimary,
        ),
      ),
      const SizedBox(height: 6.0),
      TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-() ]')),
        ],
        decoration: const InputDecoration(hintText: '+998 90 123 45 67'),
      ),
      const SizedBox(height: 12.0),
      Text(
        context.localization.phone_change_description,
        style: AppTextStyles.p4Regular.copyWith(
          color: context.currentTheme.textNeutralSecondary,
        ),
      ),
      const SizedBox(height: 24.0),
      AppButton(
        label: context.localization.phone_change_send_code,
        shouldSetFullWidth: true,
        size: AppButtonSize.large,
        isLoading: isLoading,
        onPressed: isLoading ? null : onSubmit,
      ),
    ],
  );
}

class _ChannelStep extends StatelessWidget {
  const _ChannelStep({
    required this.phone,
    required this.channels,
    required this.isLoading,
    required this.onSelect,
  });

  final String phone;
  final List<String> channels;
  final bool isLoading;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        context.localization.phone_change_choose_channel,
        style: AppTextStyles.p3Medium.copyWith(
          color: context.currentTheme.textNeutralPrimary,
        ),
      ),
      const SizedBox(height: 6.0),
      Text(
        phone,
        style: AppTextStyles.p3Medium.copyWith(
          color: context.currentTheme.textBrandPrimary,
        ),
      ),
      const SizedBox(height: 20.0),
      for (final channel in channels) ...[
        AppButton(
          label: channel == 'telegram'
              ? context.localization.otp_channel_telegram
              : context.localization.otp_channel_sms,
          shouldSetFullWidth: true,
          size: AppButtonSize.large,
          style: channel == 'telegram'
              ? AppButtonStyle.primary
              : AppButtonStyle.outline,
          isLoading: isLoading,
          onPressed: isLoading ? null : () => onSelect(channel),
        ),
        const SizedBox(height: 12.0),
      ],
    ],
  );
}

class _CodeStep extends StatelessWidget {
  const _CodeStep({
    required this.controller,
    required this.phone,
    required this.channel,
    required this.isConfirming,
    required this.resendSeconds,
    required this.isResending,
    required this.onConfirm,
    required this.onResend,
    required this.onEditNumber,
  });

  final TextEditingController controller;
  final String phone;
  final String channel;
  final bool isConfirming;
  final int resendSeconds;
  final bool isResending;
  final VoidCallback onConfirm;
  final VoidCallback onResend;
  final VoidCallback onEditNumber;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        context.localization.phone_change_code_sent(phone),
        style: AppTextStyles.p4Regular.copyWith(
          color: context.currentTheme.textNeutralSecondary,
        ),
      ),
      const SizedBox(height: 4.0),
      Text(
        channel == 'telegram'
            ? context.localization.otp_channel_telegram
            : context.localization.otp_channel_sms,
        style: AppTextStyles.p4Medium.copyWith(
          color: context.currentTheme.textBrandPrimary,
        ),
      ),
      const SizedBox(height: 20.0),
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        maxLength: 6,
        autofocus: true,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: context.localization.enter_otp,
          counterText: '',
        ),
        onSubmitted: (_) => onConfirm(),
      ),
      const SizedBox(height: 16.0),
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => AppButton(
          label: context.localization.verify,
          shouldSetFullWidth: true,
          size: AppButtonSize.large,
          state: value.text.length == 6
              ? AppButtonState.normal
              : AppButtonState.disabled,
          isLoading: isConfirming,
          onPressed: onConfirm,
        ),
      ),
      const SizedBox(height: 8.0),
      AppButton(
        label: resendSeconds > 0
            ? context.localization.phone_change_resend_in(resendSeconds)
            : context.localization.resend,
        shouldSetFullWidth: true,
        size: AppButtonSize.large,
        style: AppButtonStyle.textOrIcon,
        state: resendSeconds == 0
            ? AppButtonState.normal
            : AppButtonState.disabled,
        isLoading: isResending,
        onPressed: resendSeconds == 0 && !isResending ? onResend : null,
      ),
      AppButton(
        label: context.localization.edit,
        shouldSetFullWidth: true,
        size: AppButtonSize.large,
        style: AppButtonStyle.textOrIcon,
        onPressed: onEditNumber,
      ),
    ],
  );
}
