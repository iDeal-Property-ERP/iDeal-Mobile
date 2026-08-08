import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/checkout/bloc/checkout_bloc.dart';
import 'package:ideal_mobile/presentation/checkout/bloc/checkout_events.dart';
import 'package:ideal_mobile/presentation/checkout/constants/analytics_constant.dart';
import 'package:ideal_mobile/presentation/checkout/widget/custom_stepper.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';

class ShippingDetailsButton extends StatelessWidget {
  const ShippingDetailsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: context.localization.add_shipping_details,
      foregroundColor: context.currentTheme.textNeutralLight,
      size: AppButtonSize.extraLarge,
      onPressed: () {
        final currentStepperIndex = context
            .read<CheckoutBloc>()
            .state
            .stepperIndex;
        Clarity.sendCustomEvent(kClarityEventShippingDetailStepChecked);
        if (currentStepperIndex < CustomStepper.steps(context).length - 1) {
          context.read<CheckoutBloc>().add(
            StepperIndexUpdateEvent(index: currentStepperIndex + 1),
          );
        }
      },
    );
  }
}
