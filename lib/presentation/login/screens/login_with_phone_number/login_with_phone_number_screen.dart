import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/i18n/app_localizations.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/booking/booking_intent_service.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_bloc.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_events.dart';
import 'package:ideal_mobile/presentation/login/bloc/login_state.dart';
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/widgets/channel_picker_sheet.dart';
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/widgets/heading_welcome_widget.dart';
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/widgets/language_selector.dart';
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/widgets/phone_number_text_field.dart';
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/widgets/send_otp_button.dart';
import 'package:ideal_mobile/presentation/login/screens/login_with_phone_number/widgets/terms_agreement_notice.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/shared_pref/pref_keys.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/extensions/primitive_types_extensions.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';

@RoutePage()
class LoginWithPhoneNumberScreen extends StatefulWidget {
  const LoginWithPhoneNumberScreen({super.key});

  static const kHorizontalPadding = 16.0;

  @override
  State<LoginWithPhoneNumberScreen> createState() =>
      _LoginWithPhoneNumberScreenState();
}

class _LoginWithPhoneNumberScreenState
    extends State<LoginWithPhoneNumberScreen> {
  late final AppLocalizations appLocalizations = context.localization;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(localizations: appLocalizations),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: const Scaffold(body: LoginWithPhoneNumberBody()),
      ),
    );
  }
}

class LoginWithPhoneNumberBody extends StatelessWidget {
  const LoginWithPhoneNumberBody({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<LoginBloc>().add(const ResetPhoneNumberStateEvent());
        }
      },
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) async {
          if (state is AuthenticationExceptionState) {
            _showAuthenticationError(state, context);
          } else if (state is NavigateToHomeScreenState) {
            final resumed =
                await BookingIntentService.resumeAfterAuthentication(context);
            if (!resumed && context.mounted) {
              await context.router.replace(const HomeRoute());
            }
          }
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: LoginWithPhoneNumberScreen.kHorizontalPadding,
                ),
                child: Column(
                  children: [
                    const _LoginTopBar(),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight > 56
                            ? constraints.maxHeight - 56
                            : 0,
                      ),
                      child: Center(
                        child: BlocListener<LoginBloc, LoginState>(
                          listener: (context, state) async {
                            if (state is NavigateToOTPScreenState) {
                              unawaited(
                                context.pushRoute(
                                  PhoneNumberOTPRoute(
                                    loginBloc: context.read<LoginBloc>(),
                                  ),
                                ),
                              );
                            } else if (state
                                is PromptOtpChannelSelectionState) {
                              final selectedChannel =
                                  await showModalBottomSheet<String>(
                                    context: context,
                                    isScrollControlled: true,
                                    barrierColor: AppColors.black.withOpacity(
                                      0.72,
                                    ),
                                    backgroundColor:
                                        context.currentTheme.bgSurfaceBase2,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(24),
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    builder: (_) => ChannelPickerSheet(
                                      phoneNumber: state
                                          .phoneNumberLoginState
                                          .phoneNumber,
                                      availableChannels: state.channels,
                                    ),
                                  );

                              if (!context.mounted || selectedChannel == null) {
                                return;
                              }

                              final loginBloc = context.read<LoginBloc>();
                              loginBloc.add(
                                SelectOtpChannelEvent(channel: selectedChannel),
                              );
                              loginBloc.add(const RequestPhoneOtpEvent());
                            }
                          },
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HeadingWelcomeWidget(),
                              SizedBox(height: 30),
                              PhoneNumberTextField(),
                              SizedBox(height: 8),
                              TermsAgreementNotice(),
                              SizedBox(height: 30),
                              SendOTPButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAuthenticationError(
    AuthenticationExceptionState state,
    BuildContext context,
  ) {
    final String? error = state.errorMessage;
    context.showSnackBar(
      error.isNullOrEmpty()
          ? context.localization.opps_something_went_wrong
          : error!,
    );
  }
}

class _LoginTopBar extends StatelessWidget {
  const _LoginTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const LanguageSelector(),
        TextButton(
          onPressed: () => _skipLogin(context),
          child: Text(context.localization.skip),
        ),
      ],
    );
  }

  Future<void> _skipLogin(BuildContext context) async {
    await Prefs.setBool(PrefKeys.kSkippedLogin, value: true);
    if (context.mounted) {
      await context.router.replace(const HomeRoute());
    }
  }
}
