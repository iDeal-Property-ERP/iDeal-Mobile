import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/booking/booking_intent_service.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_bloc.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_events.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_state.dart';
import 'package:ideal_mobile/presentation/login/screens/phone_num_otp_screen/widgets/otp_input_field.dart';
import 'package:ideal_mobile/presentation/login/screens/phone_num_otp_screen/widgets/otp_verification_button.dart';
import 'package:ideal_mobile/presentation/login/widgets/login_app_bar.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

@RoutePage()
class PhoneNumberOTPScreen extends StatefulWidget {
  const PhoneNumberOTPScreen({super.key, required this.loginBloc});

  final LoginBloc loginBloc;

  static const kResendOTPMaxSeconds = 60;

  @override
  PhoneNumberOTPScreenState createState() => PhoneNumberOTPScreenState();
}

class PhoneNumberOTPScreenState extends State<PhoneNumberOTPScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          widget.loginBloc.add(PhoneOtpTextChangeEvent(phoneOtpText: ''));
          widget.loginBloc.add(
            IsResendOTPEnabledEvent(isResendOTPEnabled: false),
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: const LoginAppBar(removeLeading: false),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocProvider<LoginBloc>.value(
              value: widget.loginBloc,
              child: const _PhoneNumberOTPScreenBody(),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneNumberOTPScreenBody extends StatelessWidget {
  const _PhoneNumberOTPScreenBody();

  @override
  Widget build(BuildContext context) {
    final String phoneNumber = context
        .read<LoginBloc>()
        .state
        .phoneNumberLoginState
        .phoneNumber;
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) async {
        if (state is NavigateToHomeScreenState) {
          final resumed = await BookingIntentService.resumeAfterAuthentication(
            context,
          );
          if (!resumed && context.mounted) context.router.popUntilRoot();
        }
      },
      child: Column(
        children: [
          Text(
            context.localization.enter_otp,
            textAlign: .center,
            style: AppTextStyles.h2Bold.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${context.localization.sent_code_info} '
            '$phoneNumber',
            textAlign: .center,
            style: AppTextStyles.p2Medium.copyWith(
              color: context.currentTheme.textNeutralSecondary,
            ),
          ),
          const SizedBox(height: 20),
          const OTPCodeInputField(),
          const SizedBox(height: 32),
          const OTPVerificationButton(),
        ],
      ),
    );
  }
}
