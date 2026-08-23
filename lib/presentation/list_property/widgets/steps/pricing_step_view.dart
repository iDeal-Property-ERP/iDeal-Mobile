import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_bloc.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_event.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_state.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class PricingStepView extends StatefulWidget {
  const PricingStepView({super.key});

  @override
  State<PricingStepView> createState() => _PricingStepViewState();
}

class _PricingStepViewState extends State<PricingStepView> {
  late final TextEditingController _monthlyPriceController;
  late final TextEditingController _depositController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ListPropertyWizardBloc>().state;
    _monthlyPriceController = TextEditingController(
      text: state.monthlyPrice != null
          ? state.monthlyPrice!.toStringAsFixed(0)
          : '',
    );
    _depositController = TextEditingController(
      text: state.depositAmount != null
          ? state.depositAmount!.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _monthlyPriceController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListPropertyWizardBloc, ListPropertyWizardState>(
      builder: (context, state) {
        final config = state.config;
        final theme = context.currentTheme;

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
                  child: ChoiceChip(
                    label: Text(curr),
                    selected: selected,
                    onSelected: (val) {
                      if (val) {
                        context.read<ListPropertyWizardBloc>().add(
                          ListPropertyPricingUpdated(currency: curr),
                        );
                      }
                    },
                    selectedColor: theme.bgBrandLight100,
                    backgroundColor: theme.bgSurfaceBase2,
                    labelStyle: AppTextStyles.p3Medium.copyWith(
                      color: selected
                          ? theme.textBrandPrimary
                          : theme.textNeutralPrimary,
                    ),
                    side: BorderSide(
                      color: selected
                          ? theme.bgBrandDefault
                          : theme.strokeNeutralLight200,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Monthly Rent
            const _FieldLabel(label: 'Monthly Rent Price *'),
            _PriceInputField(
              controller: _monthlyPriceController,
              currency: state.currency,
              hintText: '500',
              onChanged: (val) {
                final parsed = double.tryParse(val);
                context.read<ListPropertyWizardBloc>().add(
                  ListPropertyPricingUpdated(monthlyPrice: parsed),
                );
              },
            ),
            const SizedBox(height: 16),

            // Security Deposit
            const _FieldLabel(label: 'Security Deposit *'),
            _PriceInputField(
              controller: _depositController,
              currency: state.currency,
              hintText: '500',
              onChanged: (val) {
                final parsed = double.tryParse(val);
                context.read<ListPropertyWizardBloc>().add(
                  ListPropertyPricingUpdated(depositAmount: parsed),
                );
              },
            ),
            const SizedBox(height: 16),

            // Minimum Stay
            const _FieldLabel(label: 'Minimum Stay (months)'),
            Wrap(
              spacing: 8,
              children: (config?.minimumStays ?? [1, 3, 6, 12]).map((months) {
                final selected = state.minimumStay == months;
                return ChoiceChip(
                  label: Text('$months ${months == 1 ? 'month' : 'months'}'),
                  selected: selected,
                  onSelected: (val) {
                    if (val) {
                      context.read<ListPropertyWizardBloc>().add(
                        ListPropertyPricingUpdated(minimumStay: months),
                      );
                    }
                  },
                  selectedColor: theme.bgBrandLight100,
                  backgroundColor: theme.bgSurfaceBase2,
                  labelStyle: AppTextStyles.p3Medium.copyWith(
                    color: selected
                        ? theme.textBrandPrimary
                        : theme.textNeutralPrimary,
                  ),
                  side: BorderSide(
                    color: selected
                        ? theme.bgBrandDefault
                        : theme.strokeNeutralLight200,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Price Includes
            if (config != null && config.priceIncludes.isNotEmpty) ...[
              const _FieldLabel(label: 'Price Includes'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: config.priceIncludes.map((item) {
                  final selected = state.priceIncludes.contains(item.value);
                  return FilterChip(
                    label: Text(item.label),
                    selected: selected,
                    onSelected: (_) {
                      context.read<ListPropertyWizardBloc>().add(
                        ListPropertyPriceIncludeToggled(item.value),
                      );
                    },
                    selectedColor: theme.bgBrandLight100,
                    backgroundColor: theme.bgSurfaceBase2,
                    labelStyle: AppTextStyles.p3Medium.copyWith(
                      color: selected
                          ? theme.textBrandPrimary
                          : theme.textNeutralPrimary,
                    ),
                    side: BorderSide(
                      color: selected
                          ? theme.bgBrandDefault
                          : theme.strokeNeutralLight200,
                    ),
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
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: AppTextStyles.p3Medium.copyWith(
          color: context.currentTheme.textNeutralPrimary,
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
    this.onChanged,
  });

  final TextEditingController controller;
  final String currency;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: theme.strokeNeutralLight200),
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
          borderSide: BorderSide(color: theme.bgBrandDefault, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
