import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_bloc.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_events.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/internet_connectivity_helper.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_state_enum.dart';

class SendOTPButton extends StatelessWidget {
  const SendOTPButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoading = context.select<LoginBloc, bool>(
      (bloc) => bloc.state.isLoading,
    );
    final String countryCode = context.select<LoginBloc, String>(
      (bloc) => bloc.state.phoneNumberLoginState.countryCode,
    );
    final String phoneNumWithCountryCode = context.select<LoginBloc, String>(
      (bloc) => bloc.state.phoneNumberLoginState.phoneNumber,
    );
    String phoneNumberOnly = '';
    if (countryCode.isNotEmpty &&
        phoneNumWithCountryCode.startsWith(countryCode) &&
        phoneNumWithCountryCode.length > countryCode.length) {
      phoneNumberOnly = phoneNumWithCountryCode.substring(
        countryCode.length,
        phoneNumWithCountryCode.length,
      );
    }

    return AppButton(
      key: keys.signInPage.sendOTPButton,
      label: context.localization.next,
      foregroundColor: context.currentTheme.textNeutralLight,
      shouldSetFullWidth: true,
      size: AppButtonSize.large,
      state: phoneNumberOnly.isNotEmpty
          ? AppButtonState.normal
          : AppButtonState.disabled,
      isLoading: isLoading,
      onPressed: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        final isConnected =
            InternetConnectivityHelper().onConnectivityChange.value;

        if (!isConnected && context.mounted) {
          context.showSnackBar(context.localization.no_internet_connection);
          return;
        }

        if (phoneNumberOnly.isNotEmpty) {
          context.read<LoginBloc>().add(
            LoginWithPhoneNumEvent(phoneNumWithCountryCode),
          );
        }
      },
    );
  }
}
