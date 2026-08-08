import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/my_orders/bloc/my_order_bloc.dart';
import 'package:ideal_mobile/presentation/my_orders/bloc/my_order_event.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';

class OrderDetailActionButtons extends StatelessWidget {
  const OrderDetailActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final isGenerating = context.select<MyOrderBloc, bool>(
      (bloc) => bloc.state.isGeneratingInvoice,
    );

    return Column(
      children: [
        AppButton(
          onPressed: isGenerating
              ? null
              : () {
                  context.read<MyOrderBloc>().add(const GenerateInvoiceEvent());
                },
          label: context.localization.generate_invoice,
          foregroundColor: context.currentTheme.textNeutralLight,
          size: AppButtonSize.extraLarge,
          shouldSetFullWidth: true,
          isLoading: isGenerating,
        ),
        const SizedBox(height: 24),
        AppButton(
          label: context.localization.cancel_order,
          style: AppButtonStyle.outline,
          shouldSetFullWidth: true,
          borderColor: context.currentTheme.strokeErrorDisabled,
          foregroundColor: context.currentTheme.textErrorSecondary,
          size: AppButtonSize.extraLarge,
          onPressed: () =>
              context.showSnackBar(context.localization.cancel_order),
        ),
      ],
    );
  }
}
