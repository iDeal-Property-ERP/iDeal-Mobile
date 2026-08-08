import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/gen/assets.gen.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/checkout/bloc/checkout_bloc.dart';
import 'package:ideal_mobile/presentation/checkout/bloc/checkout_events.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class SelectPaymentMethodFromList extends StatelessWidget {
  const SelectPaymentMethodFromList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        const SizedBox(height: 12),
        const PaymentMethodOnline(),
        const SizedBox(height: 14),
        const PaymentMethodCOD(),
      ],
    );
  }
}

class PaymentMethodOnline extends StatelessWidget {
  const PaymentMethodOnline({super.key});

  @override
  Widget build(BuildContext context) {
    final isPaymentMethodOnline = context.select<CheckoutBloc, bool>(
      (bloc) => bloc.state.isPaymentMethodOnline,
    );

    final currentStepperIndex = context.select<CheckoutBloc, int>(
      (bloc) => bloc.state.stepperIndex,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isPaymentMethodOnline && currentStepperIndex != 3
              ? context.currentTheme.strokeBrandDisabled
              : context.currentTheme.strokeNeutralLight200,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: Assets.images.mastercard.image(),
        title: Text(
          'Debit/Credit Card/Bank Transfer',
          style: AppTextStyles.p3Regular.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        onTap: () => context.read<CheckoutBloc>().add(
          const SelectPaymentMethodEvent(isPaymentMethodOnline: true),
        ),
      ),
    );
  }
}

class PaymentMethodCOD extends StatelessWidget {
  const PaymentMethodCOD({super.key});

  @override
  Widget build(BuildContext context) {
    final isPaymentMethodOnline = context.select<CheckoutBloc, bool>(
      (bloc) => bloc.state.isPaymentMethodOnline,
    );

    final currentStepperIndex = context.select<CheckoutBloc, int>(
      (bloc) => bloc.state.stepperIndex,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: !isPaymentMethodOnline && currentStepperIndex != 3
              ? context.currentTheme.strokeBrandDisabled
              : context.currentTheme.strokeNeutralLight200,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        title: Text(
          context.localization.cash_on_delivery,
          style: AppTextStyles.p3Regular.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        onTap: () => context.read<CheckoutBloc>().add(
          const SelectPaymentMethodEvent(isPaymentMethodOnline: false),
        ),
      ),
    );
  }
}
