import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_bloc.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_events.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/validators/validators.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_state_enum.dart';

class SendResetLinkButton extends StatelessWidget {
  const SendResetLinkButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoading = context.select<LoginBloc, bool>(
      (bloc) => bloc.state.isLoading,
    );
    final String email = context.select<LoginBloc, String>(
      (bloc) => bloc.state.emailPasswordLoginState?.email ?? '',
    );
    return AppButton(
      label: context.localization.send_reset_link,
      foregroundColor: context.currentTheme.textNeutralLight,
      shouldSetFullWidth: true,
      size: AppButtonSize.large,
      state: email.isNotEmpty ? AppButtonState.normal : AppButtonState.disabled,
      isLoading: isLoading,
      onPressed: () {
        FocusManager.instance.primaryFocus?.unfocus();
        final String? emailError = isEmailValid(email, context);
        if (emailError != null) {
          context.read<LoginBloc>().add(
            EmailErrorEvent(errorMessage: emailError),
          );
          return;
        }
        context.read<LoginBloc>().add(ForgotPasswordEvent());
      },
    );
  }
}
