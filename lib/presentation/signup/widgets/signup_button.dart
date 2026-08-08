import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_bloc.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_events.dart';
import 'package:ideal_mobile/presentation/login/enum/enum_login_type.dart';
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/login_with_phone_number_screen.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';

class SignupButton extends StatelessWidget {
  const SignupButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LoginWithPhoneNumberScreen.kHorizontalPadding,
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          AppButton(
            label: context.localization.next,
            shouldSetFullWidth: true,
            style: AppButtonStyle.outline,
            size: AppButtonSize.large,
            onPressed: () {
              context.read<LoginBloc>().add(
                SelectLoginSignupTypeEvent(LoginType.PHONE),
              );
              context.pushRoute(LoginWithPhoneNumberRoute());
            },
          ),
        ],
      ),
    );
  }
}
