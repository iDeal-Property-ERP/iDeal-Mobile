import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_bloc.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_event.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_state.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class DetailsStepView extends StatefulWidget {
  const DetailsStepView({super.key});

  @override
  State<DetailsStepView> createState() => _DetailsStepViewState();
}

class _DetailsStepViewState extends State<DetailsStepView> {
  late final TextEditingController _nameController;
  late final TextEditingController _floorController;
  late final TextEditingController _totalFloorsController;
  late final TextEditingController _areaController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ListPropertyWizardBloc>().state;
    _nameController = TextEditingController(text: state.name);
    _floorController = TextEditingController(text: state.floor.toString());
    _totalFloorsController = TextEditingController(
      text: state.totalFloors?.toString() ?? '',
    );
    _areaController = TextEditingController(
      text: state.areaSqm?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: state.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _floorController.dispose();
    _totalFloorsController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
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
            // Property Type
            Text(
              'Property Type',
              style: AppTextStyles.p3Medium.copyWith(
                color: theme.textNeutralPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (config?.propertyTypes ?? []).map((pt) {
                final selected = state.propertyType == pt.value;
                return ChoiceChip(
                  label: Text(pt.label),
                  selected: selected,
                  onSelected: (val) {
                    if (val) {
                      context.read<ListPropertyWizardBloc>().add(
                        ListPropertyDetailsUpdated(propertyType: pt.value),
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

            // Listing Title
            const _FieldLabel(label: 'Listing Title *'),
            _CustomTextField(
              controller: _nameController,
              hintText: 'e.g. Modern 2-room apartment near metro',
              onChanged: (val) => context.read<ListPropertyWizardBloc>().add(
                ListPropertyDetailsUpdated(name: val),
              ),
            ),
            const SizedBox(height: 16),

            // District Dropdown
            const _FieldLabel(label: 'District *'),
            if (config != null && config.districts.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.bgSurfaceBase2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.strokeNeutralLight200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: state.districtId ?? config.districts.first.id,
                    isExpanded: true,
                    dropdownColor: theme.bgSurfaceBase,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.textNeutralSecondary,
                    ),
                    items: config.districts.map((d) {
                      return DropdownMenuItem<int>(
                        value: d.id,
                        child: Text(
                          '${d.name}, ${d.city}',
                          style: AppTextStyles.p3Medium.copyWith(
                            color: theme.textNeutralPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        context.read<ListPropertyWizardBloc>().add(
                          ListPropertyDetailsUpdated(districtId: val),
                        );
                      }
                    },
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Rooms Chips
            const _FieldLabel(label: 'Rooms *'),
            Wrap(
              spacing: 8,
              children: [1, 2, 3, 4, 5, 6].map((roomCount) {
                final selected = state.rooms == roomCount;
                return ChoiceChip(
                  label: Text('$roomCount'),
                  selected: selected,
                  onSelected: (val) {
                    if (val) {
                      context.read<ListPropertyWizardBloc>().add(
                        ListPropertyDetailsUpdated(rooms: roomCount),
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

            // Floor & Total Floors & Area
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel(label: 'Floor *'),
                      _CustomTextField(
                        controller: _floorController,
                        keyboardType: TextInputType.number,
                        hintText: '1',
                        onChanged: (val) =>
                            context.read<ListPropertyWizardBloc>().add(
                              ListPropertyDetailsUpdated(
                                floor: int.tryParse(val) ?? 0,
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
                      const _FieldLabel(label: 'Total Floors'),
                      _CustomTextField(
                        controller: _totalFloorsController,
                        keyboardType: TextInputType.number,
                        hintText: '9',
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
                      const _FieldLabel(label: 'Area (m²) *'),
                      _CustomTextField(
                        controller: _areaController,
                        keyboardType: TextInputType.number,
                        hintText: '65',
                        onChanged: (val) =>
                            context.read<ListPropertyWizardBloc>().add(
                              ListPropertyDetailsUpdated(
                                areaSqm: int.tryParse(val) ?? 0,
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Furnishing
            const _FieldLabel(label: 'Furnishing'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (config?.furnishings ?? []).map((f) {
                final selected = state.furnishing == f.value;
                return ChoiceChip(
                  label: Text(f.label),
                  selected: selected,
                  onSelected: (val) {
                    if (val) {
                      context.read<ListPropertyWizardBloc>().add(
                        ListPropertyDetailsUpdated(furnishing: f.value),
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

            // Amenities
            if (config != null && config.amenities.isNotEmpty) ...[
              const _FieldLabel(label: 'Amenities'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: config.amenities.map((a) {
                  final selected = state.amenities.contains(a.slug);
                  return FilterChip(
                    label: Text(a.name),
                    selected: selected,
                    onSelected: (_) {
                      context.read<ListPropertyWizardBloc>().add(
                        ListPropertyAmenityToggled(a.slug),
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
              const SizedBox(height: 16),
            ],

            // Description
            const _FieldLabel(label: 'Description'),
            _CustomTextField(
              controller: _descriptionController,
              maxLines: 4,
              hintText: 'Tell renters what makes your place special...',
              onChanged: (val) => context.read<ListPropertyWizardBloc>().add(
                ListPropertyDetailsUpdated(description: val),
              ),
            ),
            const SizedBox(height: 24),
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

class _CustomTextField extends StatelessWidget {
  const _CustomTextField({
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final int maxLines;
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
      keyboardType: keyboardType,
      maxLines: maxLines,
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
