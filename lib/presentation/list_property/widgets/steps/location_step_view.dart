import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_bloc.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_event.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_state.dart';
import 'package:ideal_mobile/presentation/list_property/screens/location_picker_screen.dart';
import 'package:ideal_mobile/presentation/list_property/widgets/wizard_dropdown.dart';
import 'package:ideal_mobile/presentation/map/widgets/property_map_view.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class LocationStepView extends StatefulWidget {
  const LocationStepView({super.key});

  @override
  State<LocationStepView> createState() => _LocationStepViewState();
}

class _LocationStepViewState extends State<LocationStepView> {
  late final TextEditingController _addressController;
  late final TextEditingController _landmarkController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ListPropertyWizardBloc>().state;
    _addressController = TextEditingController(text: state.address ?? '');
    _landmarkController = TextEditingController(text: state.landmark ?? '');
  }

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker(
    BuildContext context,
    ListPropertyWizardState state,
  ) async {
    final initialCoordinate = state.latitude != null && state.longitude != null
        ? PropertyMapCoordinate(
            latitude: state.latitude!,
            longitude: state.longitude!,
          )
        : null;

    final result = await Navigator.of(context).push<PropertyMapCoordinate>(
      MaterialPageRoute(
        builder: (ctx) =>
            LocationPickerScreen(initialCoordinate: initialCoordinate),
      ),
    );

    if (result != null && mounted) {
      context.read<ListPropertyWizardBloc>().add(
        ListPropertyLocationUpdated(
          latitude: result.latitude,
          longitude: result.longitude,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListPropertyWizardBloc, ListPropertyWizardState>(
      builder: (context, state) {
        final config = state.config;
        final showError = state.showValidationErrors;
        final theme = context.currentTheme;

        final isDistrictMissing = showError && state.districtId == null;
        final isCoordinatesMissing =
            showError && (state.latitude == null || state.longitude == null);

        final isLandmarkWordsExceeded =
            state.landmark != null &&
            state.landmark!
                    .trim()
                    .split(RegExp(r'\s+'))
                    .where((w) => w.isNotEmpty)
                    .length >
                5;
        final isLandmarkLengthExceeded =
            state.landmark != null && state.landmark!.trim().length > 100;
        final hasLandmarkError =
            isLandmarkWordsExceeded || isLandmarkLengthExceeded;

        final hasCoordinates =
            state.latitude != null && state.longitude != null;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
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
                  ListPropertyLocationUpdated(districtId: val),
                );
              },
            ),
            if (isDistrictMissing)
              const _FieldErrorText(text: 'Please select a district'),
            const SizedBox(height: 16),

            // Street Address (Optional)
            _FieldLabel(label: context.localization.list_property_address),
            _CustomTextField(
              controller: _addressController,
              hintText: context.localization.list_property_address_hint,
              maxLength: 255,
              onChanged: (val) => context.read<ListPropertyWizardBloc>().add(
                ListPropertyLocationUpdated(address: val),
              ),
            ),
            const SizedBox(height: 16),

            // Landmark (Optional)
            _FieldLabel(
              label: context.localization.list_property_landmark,
              hasError: hasLandmarkError,
            ),
            _CustomTextField(
              controller: _landmarkController,
              hintText: context.localization.list_property_landmark_hint,
              maxLength: 100,
              hasError: hasLandmarkError,
              onChanged: (val) => context.read<ListPropertyWizardBloc>().add(
                ListPropertyLocationUpdated(landmark: val),
              ),
            ),
            if (isLandmarkWordsExceeded)
              _FieldErrorText(
                text: context.localization.list_property_landmark_words_error,
              ),
            const SizedBox(height: 16),

            // Map Location Card
            _FieldLabel(
              label: '${context.localization.list_property_map_location} *',
              hasError: isCoordinatesMissing,
            ),
            GestureDetector(
              onTap: () => _openMapPicker(context, state),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: theme.bgSurfaceBase2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCoordinatesMissing
                        ? theme.strokeErrorDefault
                        : (hasCoordinates
                              ? theme.bgBrandDefault
                              : theme.strokeNeutralLight200),
                    width: isCoordinatesMissing ? 1.5 : 1,
                  ),
                ),
                child: hasCoordinates
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 140,
                            child: AbsorbPointer(
                              child: PropertyMapView(
                                markers: [
                                  PropertyMapMarker(
                                    id: 1,
                                    latitude: state.latitude!,
                                    longitude: state.longitude!,
                                  ),
                                ],
                                initialCamera: CameraTarget(
                                  latitude: state.latitude!,
                                  longitude: state.longitude!,
                                  zoom: 14,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  TablerIcons.map_pin,
                                  size: 18,
                                  color: theme.textBrandPrimary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${state.latitude!.toStringAsFixed(5)}, '
                                    '${state.longitude!.toStringAsFixed(5)}',
                                    style: AppTextStyles.p3Medium.copyWith(
                                      color: theme.textNeutralPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  context
                                      .localization
                                      .list_property_change_location,
                                  style: AppTextStyles.p4Medium.copyWith(
                                    color: theme.textBrandPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.bgSurfaceBase,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                TablerIcons.map_2,
                                size: 28,
                                color: isCoordinatesMissing
                                    ? theme.textErrorPrimary
                                    : theme.textBrandPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.localization.list_property_select_on_map,
                              style: AppTextStyles.p2Medium.copyWith(
                                color: isCoordinatesMissing
                                    ? theme.textErrorPrimary
                                    : theme.textNeutralPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context
                                  .localization
                                  .list_property_map_location_hint,
                              style: AppTextStyles.p4Regular.copyWith(
                                color: theme.textNeutralSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            if (isCoordinatesMissing)
              _FieldErrorText(
                text: context.localization.list_property_location_required,
              ),
            const SizedBox(height: 24),
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
    this.maxLength,
    this.hasError = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? hintText;
  final int? maxLength;
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
      maxLength: maxLength,
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
