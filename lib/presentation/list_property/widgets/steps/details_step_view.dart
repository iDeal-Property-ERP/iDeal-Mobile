import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_bloc.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_event.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_state.dart';
import 'package:ideal_mobile/presentation/list_property/widgets/wizard_choice_chip.dart';
import 'package:ideal_mobile/presentation/list_property/widgets/wizard_dropdown.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class DetailsStepView extends StatefulWidget {
  const DetailsStepView({super.key});

  @override
  State<DetailsStepView> createState() => _DetailsStepViewState();
}

class _DetailsStepViewState extends State<DetailsStepView> {
  late final TextEditingController _floorController;
  late final TextEditingController _totalFloorsController;
  late final TextEditingController _areaController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ListPropertyWizardBloc>().state;
    _floorController = TextEditingController(
      text: state.floor != null ? state.floor.toString() : '',
    );
    _totalFloorsController = TextEditingController(
      text: state.totalFloors?.toString() ?? '',
    );
    _areaController = TextEditingController(
      text: state.areaSqm?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _floorController.dispose();
    _totalFloorsController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListPropertyWizardBloc, ListPropertyWizardState>(
      builder: (context, state) {
        final config = state.config;
        final showError = state.showValidationErrors;

        final isTypeMissing = showError && state.propertyType == null;
        final isDistrictMissing = showError && state.districtId == null;
        final isRoomsMissing = showError && state.rooms == null;
        final isFloorMissing = showError && state.floor == null;
        final isFloorOutOfBounds =
            state.floor != null &&
            state.totalFloors != null &&
            state.floor! > state.totalFloors!;
        final isAreaMissing =
            showError && (state.areaSqm == null || state.areaSqm! <= 0);
        final isFurnishingMissing = showError && state.furnishing == null;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // Property Type Dropdown
            _FieldLabel(label: 'Property Type *', hasError: isTypeMissing),
            WizardDropdown<String>(
              value: state.propertyType,
              title: 'Property Type',
              hintText: 'Select Property Type',
              hasError: isTypeMissing,
              options: (config?.propertyTypes ?? []).map((pt) {
                return WizardDropdownOption<String>(
                  value: pt.value,
                  label: pt.label,
                );
              }).toList(),
              onChanged: (val) {
                context.read<ListPropertyWizardBloc>().add(
                  ListPropertyDetailsUpdated(propertyType: val),
                );
              },
            ),
            if (isTypeMissing)
              const _FieldErrorText(text: 'Please select a property type'),
            const SizedBox(height: 16),

            // District Dropdown
            _FieldLabel(label: 'District *', hasError: isDistrictMissing),
            WizardDropdown<int>(
              value: state.districtId,
              title: 'District',
              hintText: 'Select District',
              hasError: isDistrictMissing,
              options: (config?.districts ?? []).map((d) {
                return WizardDropdownOption<int>(value: d.id, label: d.name);
              }).toList(),
              onChanged: (val) {
                context.read<ListPropertyWizardBloc>().add(
                  ListPropertyDetailsUpdated(districtId: val),
                );
              },
            ),
            if (isDistrictMissing)
              const _FieldErrorText(text: 'Please select a district'),
            const SizedBox(height: 16),

            // Rooms Dropdown
            _FieldLabel(label: 'Rooms *', hasError: isRoomsMissing),
            WizardDropdown<int>(
              value: state.rooms,
              title: 'Number of Rooms',
              hintText: 'Select Number of Rooms',
              hasError: isRoomsMissing,
              options: [1, 2, 3, 4, 5, 6].map((roomCount) {
                return WizardDropdownOption<int>(
                  value: roomCount,
                  label: '$roomCount ${roomCount == 1 ? 'room' : 'rooms'}',
                );
              }).toList(),
              onChanged: (val) {
                context.read<ListPropertyWizardBloc>().add(
                  ListPropertyDetailsUpdated(rooms: val),
                );
              },
            ),
            if (isRoomsMissing)
              const _FieldErrorText(text: 'Please select number of rooms'),
            const SizedBox(height: 16),

            // Floor & Total Floors & Area
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(
                        label: 'Floor *',
                        hasError: isFloorMissing || isFloorOutOfBounds,
                      ),
                      _CustomTextField(
                        controller: _floorController,
                        keyboardType: TextInputType.number,
                        hintText: '1',
                        hasError: isFloorMissing || isFloorOutOfBounds,
                        onChanged: (val) =>
                            context.read<ListPropertyWizardBloc>().add(
                              ListPropertyDetailsUpdated(
                                floor: int.tryParse(val),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(
                        label: 'Total Floors',
                        hasError: isFloorOutOfBounds,
                      ),
                      _CustomTextField(
                        controller: _totalFloorsController,
                        keyboardType: TextInputType.number,
                        hintText: '9',
                        hasError: isFloorOutOfBounds,
                        onChanged: (val) =>
                            context.read<ListPropertyWizardBloc>().add(
                              ListPropertyDetailsUpdated(
                                totalFloors: int.tryParse(val),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(
                        label: 'Area (m²) *',
                        hasError: isAreaMissing,
                      ),
                      _CustomTextField(
                        controller: _areaController,
                        keyboardType: TextInputType.number,
                        hintText: '65',
                        hasError: isAreaMissing,
                        onChanged: (val) =>
                            context.read<ListPropertyWizardBloc>().add(
                              ListPropertyDetailsUpdated(
                                areaSqm: int.tryParse(val),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isFloorOutOfBounds)
              const _FieldErrorText(
                text: 'Floor cannot be greater than total floors',
              ),
            const SizedBox(height: 16),

            // Furnishing Dropdown
            _FieldLabel(label: 'Furnishing *', hasError: isFurnishingMissing),
            WizardDropdown<String>(
              value: state.furnishing,
              title: 'Furnishing',
              hintText: 'Select Furnishing',
              hasError: isFurnishingMissing,
              options: (config?.furnishings ?? []).map((f) {
                return WizardDropdownOption<String>(
                  value: f.value,
                  label: f.label,
                );
              }).toList(),
              onChanged: (val) {
                context.read<ListPropertyWizardBloc>().add(
                  ListPropertyDetailsUpdated(furnishing: val),
                );
              },
            ),
            if (isFurnishingMissing)
              const _FieldErrorText(text: 'Please select furnishing option'),
            const SizedBox(height: 16),

            // Amenities (Multi-choice chips)
            if (config != null && config.amenities.isNotEmpty) ...[
              const _FieldLabel(label: 'Amenities'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: config.amenities.map((a) {
                  final selected = state.amenities.contains(a.slug);
                  return WizardChoiceChip(
                    label: a.name,
                    selected: selected,
                    onTap: () {
                      context.read<ListPropertyWizardBloc>().add(
                        ListPropertyAmenityToggled(a.slug),
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

class _CustomTextField extends StatelessWidget {
  const _CustomTextField({
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.hasError = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
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
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: AppTextStyles.p3Medium.copyWith(color: theme.textNeutralPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.p3Regular.copyWith(
          color: theme.textNeutralSecondary,
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
