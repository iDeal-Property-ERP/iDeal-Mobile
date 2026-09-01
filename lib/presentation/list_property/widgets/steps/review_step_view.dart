import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_bloc.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_event.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_state.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ReviewStepView extends StatelessWidget {
  const ReviewStepView({super.key});

  void _showPublicOfferDialog(BuildContext context, String body) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Public Offer Agreement'),
        content: SingleChildScrollView(
          child: Text(
            body.isNotEmpty ? body : 'Standard owner public offer terms.',
            style: AppTextStyles.p3Regular,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListPropertyWizardBloc, ListPropertyWizardState>(
      builder: (context, state) {
        final theme = context.currentTheme;
        final config = state.config;
        final showError = state.showValidationErrors;
        final isOfferMissing = showError && !state.acceptOffer;

        final districtName =
            config?.districts
                .firstWhere(
                  (d) => d.id == state.districtId,
                  orElse: () => config.districts.first,
                )
                .name ??
            '';

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // Details Summary Card
            _SummaryCard(
              title: 'Property Details',
              icon: TablerIcons.building,
              onEdit: () => context.read<ListPropertyWizardBloc>().add(
                const ListPropertyStepChanged(0),
              ),
              children: [
                _SummaryRow(
                  label: 'Type',
                  value: (state.propertyType ?? 'apartment')
                      .replaceAll('_', ' ')
                      .toUpperCase(),
                ),
                _SummaryRow(label: 'District', value: districtName),
                if (state.landmark != null && state.landmark!.trim().isNotEmpty)
                  _SummaryRow(
                    label: context.localization.list_property_landmark,
                    value: state.landmark!.trim(),
                  ),
                _SummaryRow(
                  label: 'Rooms / Floor',
                  value: [
                    '${state.rooms ?? 0} rooms',
                    'floor ${state.floor ?? 0}',
                    if (state.totalFloors != null) 'total ${state.totalFloors}',
                  ].join(', '),
                ),
                _SummaryRow(label: 'Area', value: '${state.areaSqm ?? 0} m²'),
                _SummaryRow(
                  label: 'Furnishing',
                  value: (state.furnishing ?? 'unfurnished')
                      .replaceAll('_', ' ')
                      .toUpperCase(),
                ),
                if (state.amenities.isNotEmpty)
                  _SummaryRow(
                    label: 'Amenities',
                    value: '${state.amenities.length} selected',
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Photos Summary Card
            _SummaryCard(
              title: 'Photos (${state.imagePaths.length})',
              icon: TablerIcons.photo,
              onEdit: () => context.read<ListPropertyWizardBloc>().add(
                const ListPropertyStepChanged(1),
              ),
              children: [
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.imagePaths.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(state.imagePaths[idx]),
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Pricing Summary Card
            _SummaryCard(
              title: 'Pricing',
              icon: TablerIcons.coin,
              onEdit: () => context.read<ListPropertyWizardBloc>().add(
                const ListPropertyStepChanged(2),
              ),
              children: [
                _SummaryRow(
                  label: 'Monthly Rent',
                  value:
                      '${state.monthlyPrice?.toStringAsFixed(0) ?? '0'} '
                      '${state.currency}',
                ),
                if (state.priceIncludes.isNotEmpty)
                  _SummaryRow(
                    label: 'Includes',
                    value: state.priceIncludes.join(', '),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Contact Summary Card
            _SummaryCard(
              title: 'Contact Info',
              icon: TablerIcons.user,
              onEdit: () => context.read<ListPropertyWizardBloc>().add(
                const ListPropertyStepChanged(3),
              ),
              children: [
                _SummaryRow(
                  label: 'Owner Name',
                  value: '${state.firstName} ${state.lastName ?? ''}'.trim(),
                ),
                if (state.phone != null && state.phone!.isNotEmpty)
                  _SummaryRow(label: 'Phone', value: state.phone!),
                if (state.email != null && state.email!.isNotEmpty)
                  _SummaryRow(label: 'Email', value: state.email!),
              ],
            ),
            const SizedBox(height: 20),

            // Public Offer Checkbox
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.bgSurfaceBase2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isOfferMissing
                      ? theme.strokeErrorDefault
                      : (state.acceptOffer
                            ? theme.bgBrandDefault
                            : theme.strokeNeutralLight200),
                  width: isOfferMissing ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: state.acceptOffer,
                        activeColor: theme.bgBrandDefault,
                        onChanged: (val) {
                          context.read<ListPropertyWizardBloc>().add(
                            ListPropertyAcceptOfferToggled(
                              accepted: val ?? false,
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            context.read<ListPropertyWizardBloc>().add(
                              ListPropertyAcceptOfferToggled(
                                accepted: !state.acceptOffer,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'I accept the public offer and confirm I am the '
                              'owner or authorized representative of this '
                              'property.',
                              style: AppTextStyles.p3Medium.copyWith(
                                color: isOfferMissing
                                    ? theme.textErrorPrimary
                                    : theme.textNeutralPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (config?.publicOffer.body != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 48, bottom: 4),
                      child: GestureDetector(
                        onTap: () => _showPublicOfferDialog(
                          context,
                          config!.publicOffer.body ?? '',
                        ),
                        child: Text(
                          'Read public offer terms',
                          style: AppTextStyles.p4Medium.copyWith(
                            color: theme.textBrandPrimary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isOfferMissing)
              const Padding(
                padding: EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  'Please accept the public offer agreement to proceed',
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.icon,
    required this.onEdit,
    required this.children,
  });

  final String title;
  final IconData icon;
  final VoidCallback onEdit;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.bgSurfaceBase2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.strokeNeutralLight200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: theme.textBrandPrimary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppTextStyles.p2Medium.copyWith(
                      color: theme.textNeutralPrimary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onEdit,
                child: Text(
                  'Edit',
                  style: AppTextStyles.p4Medium.copyWith(
                    color: theme.textBrandPrimary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.p3Regular.copyWith(
              color: theme.textNeutralSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.p3Medium.copyWith(
                color: theme.textNeutralPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
