import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_bloc.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_event.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_state.dart';
import 'package:ideal_mobile/presentation/list_property/widgets/wizard_choice_chip.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class PricingStepView extends StatefulWidget {
  const PricingStepView({super.key});

  @override
  State<PricingStepView> createState() => _PricingStepViewState();
}

class _PricingStepViewState extends State<PricingStepView> {
  late final TextEditingController _monthlyPriceController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ListPropertyWizardBloc>().state;
    _monthlyPriceController = TextEditingController(
      text: state.monthlyPrice != null
          ? state.monthlyPrice!.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _monthlyPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListPropertyWizardBloc, ListPropertyWizardState>(
      builder: (context, state) {
        final config = state.config;
        final showError = state.showValidationErrors;

        final isPriceMissing =
            showError &&
            (state.monthlyPrice == null || state.monthlyPrice! <= 0);

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // Currency selector
            const _FieldLabel(label: 'Currency'),
            Row(
              children: (config?.currencies ?? ['USD', 'UZS']).map((curr) {
                final selected = state.currency == curr;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: WizardChoiceChip(
                    label: curr,
                    selected: selected,
                    onTap: () {
                      context.read<ListPropertyWizardBloc>().add(
                        ListPropertyPricingUpdated(currency: curr),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Monthly Rent
            _FieldLabel(
              label: 'Monthly Rent Price *',
              hasError: isPriceMissing,
            ),
            _PriceInputField(
              controller: _monthlyPriceController,
              currency: state.currency,
              hintText: '500',
              hasError: isPriceMissing,
              onChanged: (val) {
                final parsed = double.tryParse(val);
                context.read<ListPropertyWizardBloc>().add(
                  ListPropertyPricingUpdated(monthlyPrice: parsed),
                );
              },
            ),
            if (isPriceMissing)
              const _FieldErrorText(text: 'Please enter a monthly rent price'),
            const SizedBox(height: 20),

            // Price Includes (Multi-choice chips)
            if (config != null && config.priceIncludes.isNotEmpty) ...[
              const _FieldLabel(label: 'Price Includes'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: config.priceIncludes.map((item) {
                  final selected = state.priceIncludes.contains(item.value);
                  return WizardChoiceChip(
                    label: item.label,
                    selected: selected,
                    onTap: () {
                      context.read<ListPropertyWizardBloc>().add(
                        ListPropertyPriceIncludeToggled(item.value),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ],
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.hasError = false});

  final String label;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: AppTextStyles.p3Medium.copyWith(
          color: hasError ? theme.textErrorPrimary : theme.textNeutralPrimary,
        ),
      ),
    );
  }
}

class _FieldErrorText extends StatelessWidget {
  const _FieldErrorText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: AppTextStyles.p4Medium.copyWith(
          color: context.currentTheme.textErrorPrimary,
        ),
      ),
    );
  }
}

class _PriceInputField extends StatelessWidget {
  const _PriceInputField({
    required this.controller,
    required this.currency,
    this.hintText,
    this.hasError = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String currency;
  final String? hintText;
  final bool hasError;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: hasError
            ? theme.strokeErrorDefault
            : theme.strokeNeutralLight200,
        width: hasError ? 1.5 : 1,
      ),
    );

    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: AppTextStyles.p3Medium.copyWith(color: theme.textNeutralPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.p3Regular.copyWith(
          color: theme.textNeutralSecondary,
        ),
        suffixText: currency,
        suffixStyle: AppTextStyles.p3SemiBold.copyWith(
          color: theme.textBrandPrimary,
        ),
        filled: true,
        fillColor: theme.bgSurfaceBase2,
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: hasError ? theme.strokeErrorDefault : theme.bgBrandDefault,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
