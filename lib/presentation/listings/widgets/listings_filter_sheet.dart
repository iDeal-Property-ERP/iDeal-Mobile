import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/widgets/district_picker_sheet.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_date_filter_field.dart';
import 'package:ideal_mobile/utils/haptic_feedback_util.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';
import 'package:ideal_mobile/widgets/styling/input_decorations.dart';

class _RoomPreset {
  const _RoomPreset({required this.label, this.min, this.max});

  final String label;
  final int? min;
  final int? max;

  bool isSelected(int? draftMin, int? draftMax) {
    if (min == 5 && max == null) {
      return draftMin == 5 && draftMax == null;
    }
    return draftMin == min && draftMax == max;
  }
}

const _roomPresets = <_RoomPreset>[
  _RoomPreset(label: '1', min: 1, max: 1),
  _RoomPreset(label: '2', min: 2, max: 2),
  _RoomPreset(label: '3', min: 3, max: 3),
  _RoomPreset(label: '4', min: 4, max: 4),
  _RoomPreset(label: '5+', min: 5),
];

Future<ListingFilters?> showListingsFilterSheet(
  BuildContext context, {
  ListingFilters? initialFilters,
  ListingFilterOptions? filterOptions,
  bool applyToListingsBloc = true,
}) async {
  final bloc = applyToListingsBloc ? context.read<ListingsBloc>() : null;
  final currentFilters = initialFilters ?? bloc?.state.filters;
  final currentOptions = filterOptions ?? bloc?.state.filterOptions;
  assert(currentFilters != null && currentOptions != null);

  final draggableController = DraggableScrollableController();

  final result = await showModalBottomSheet<ListingFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.currentTheme.bgSurfaceSheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (_) => DraggableScrollableSheet(
      controller: draggableController,
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.45, 0.85, 0.95],
      builder: (context, scrollController) => ListingsFilterSheet(
        initialFilters: currentFilters!,
        filterOptions: currentOptions!,
        scrollController: scrollController,
        draggableController: draggableController,
      ),
    ),
  );
  if (result != null && bloc != null && result != bloc.state.filters) {
    bloc.add(ApplyListingFiltersEvent(result));
  }
  return result;
}

class ListingsFilterSheet extends StatefulWidget {
  const ListingsFilterSheet({
    super.key,
    required this.initialFilters,
    required this.filterOptions,
    this.scrollController,
    this.draggableController,
  });

  final ListingFilters initialFilters;
  final ListingFilterOptions filterOptions;
  final ScrollController? scrollController;
  final DraggableScrollableController? draggableController;

  @override
  State<ListingsFilterSheet> createState() => _ListingsFilterSheetState();
}

class _ListingsFilterSheetState extends State<ListingsFilterSheet> {
  late ListingFilters _draft;
  late String _currency;
  late final TextEditingController _priceMinController;
  late final TextEditingController _priceMaxController;

  static const double _defaultUsdMax = 3000.0;
  static const double _defaultUzsMax = 40000000.0;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialFilters;
    _currency = _draft.currency ?? 'USD';
    _priceMinController = TextEditingController(
      text: _formatPriceValue(_draft.priceMin, _currency),
    );
    _priceMaxController = TextEditingController(
      text: _formatPriceValue(_draft.priceMax, _currency),
    );
  }

  @override
  void dispose() {
    _priceMinController.dispose();
    _priceMaxController.dispose();
    super.dispose();
  }

  void _expandSheetIfNeeded() {
    if (widget.draggableController != null &&
        widget.draggableController!.isAttached) {
      final currentSize = widget.draggableController!.size;
      if (currentSize < 0.95) {
        widget.draggableController!.animateTo(
          0.95,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  double get _maxPriceBound {
    if (_currency == 'UZS') {
      return (widget.filterOptions.priceMax != null &&
              widget.filterOptions.priceMax! > 100000)
          ? widget.filterOptions.priceMax!
          : _defaultUzsMax;
    }
    return (widget.filterOptions.priceMax != null &&
            widget.filterOptions.priceMax! < 100000)
        ? widget.filterOptions.priceMax!
        : _defaultUsdMax;
  }

  double get _minPriceBound => 0.0;

  double get _priceStep => _currency == 'USD' ? 50.0 : 500000.0;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    if (keyboardInset > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _expandSheetIfNeeded();
      });
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(context),
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: _buildForm(context, widget.filterOptions),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      decoration: BoxDecoration(
        color: context.currentTheme.strokeNeutralLight200,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ListingFilterOptions filterOptions) {
    final sections = <Widget>[];

    if (filterOptions.districts.isNotEmpty) {
      sections.addAll([
        _buildSectionHeader(
          context,
          icon: TablerIcons.map_pin,
          title: context.localization.listings_filter_district,
        ),
        _buildDistrictSelector(context, filterOptions.districts),
        const SizedBox(height: 16),
      ]);
    }

    if (filterOptions.propertyTypes.isNotEmpty) {
      sections.addAll([
        _buildSectionHeader(
          context,
          icon: TablerIcons.building,
          title: context.localization.listings_filter_property_type,
        ),
        _buildPropertyTypeGrid(context, filterOptions.propertyTypes),
        const SizedBox(height: 16),
      ]);
    }

    if (filterOptions.tariffs.isNotEmpty) {
      sections.addAll([
        _buildChoiceGroup(
          context,
          icon: TablerIcons.sparkles,
          title: context.localization.listings_filter_tariff,
          choices: filterOptions.tariffs,
          selectedValue: _draft.tariff,
          getIcon: _getTariffIcon,
          onChanged: _onTariffChanged,
        ),
        const SizedBox(height: 16),
      ]);
    }

    sections.addAll([
      _buildPriceSection(context),
      const SizedBox(height: 16),
      _buildRoomsSection(context),
      const SizedBox(height: 16),
      _buildVerificationSection(context),
      const SizedBox(height: 16),
      _buildAvailabilitySection(context),
      const SizedBox(height: 16),
    ]);

    if (filterOptions.furnishings.isNotEmpty) {
      sections.addAll([
        _buildSectionHeader(
          context,
          icon: TablerIcons.armchair,
          title: context.localization.listings_filter_furnishing,
        ),
        _buildFurnishingSlider(context, filterOptions.furnishings),
        const SizedBox(height: 16),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sections,
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.currentTheme.iconNeutralDefault),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.p3Medium.copyWith(
                color: context.currentTheme.textNeutralPrimary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _buildDistrictSelector(
    BuildContext context,
    List<ListingDistrict> districts,
  ) {
    final selectedDistrict = districts
        .where((district) => district.id == _draft.districtId)
        .firstOrNull;

    final theme = context.currentTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDistrictPicker(context, districts),
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.bgSurfaceBase2,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(
              color: selectedDistrict != null
                  ? theme.strokeBrandHover
                  : theme.strokeNeutralLight100,
            ),
          ),
          child: Row(
            children: [
              Icon(
                TablerIcons.map_pin,
                size: 18,
                color: selectedDistrict != null
                    ? theme.iconBrandPrimary
                    : theme.iconNeutralDefault,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedDistrict?.name ??
                      context.localization.listings_select_district,
                  style: AppTextStyles.p3Regular.copyWith(
                    color: selectedDistrict != null
                        ? theme.textNeutralPrimary
                        : theme.textNeutralDisable,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selectedDistrict != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _draft = _draft.copyWith(clearDistrictId: true);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      TablerIcons.x,
                      size: 16,
                      color: theme.iconNeutralDefault,
                    ),
                  ),
                ),
              Icon(
                TablerIcons.chevron_right,
                size: 18,
                color: theme.iconNeutralDefault,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDistrictPicker(
    BuildContext context,
    List<ListingDistrict> districts,
  ) async {
    await HapticFeedbackUtil.light();
    if (!context.mounted) return;

    final result = await showDistrictPickerSheet(
      context,
      districts: districts,
      selectedDistrictId: _draft.districtId,
    );

    if (result != null && mounted) {
      setState(() {
        if (result.districtId == null) {
          _draft = _draft.copyWith(clearDistrictId: true);
        } else {
          _draft = _draft.copyWith(districtId: result.districtId);
        }
      });
    }
  }

  Widget _buildPropertyTypeGrid(
    BuildContext context,
    List<ListingChoice> choices,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.1,
      ),
      itemCount: choices.length,
      itemBuilder: (context, index) {
        final choice = choices[index];
        final isSelected = _draft.propertyType == choice.value;
        final theme = context.currentTheme;

        final foregroundColor = isSelected
            ? theme.textBrandPrimary
            : theme.textNeutralPrimary;
        final iconColor = isSelected
            ? theme.iconBrandPrimary
            : theme.iconNeutralDefault;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                _onPropertyTypeChanged(isSelected ? null : choice.value),
            borderRadius: BorderRadius.circular(AppRadius.input),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.bgBrandLight100
                    : theme.bgSurfaceBase2,
                border: Border.all(
                  color: isSelected
                      ? theme.strokeBrandHover
                      : theme.strokeNeutralLight100,
                  width: isSelected ? 1.5 : 1.0,
                ),
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getPropertyTypeIcon(choice.value),
                    size: 22,
                    color: iconColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    choice.label,
                    style: AppTextStyles.p4Medium.copyWith(
                      color: foregroundColor,
                      fontWeight: isSelected ? FontWeight.w600 : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    final maxBound = _maxPriceBound;
    final minBound = _minPriceBound;
    final step = _priceStep;

    final currentMin = (_draft.priceMin ?? minBound).clamp(minBound, maxBound);
    final currentMax = (_draft.priceMax ?? maxBound).clamp(
      currentMin,
      maxBound,
    );

    final divisions = ((maxBound - minBound) / step).round().clamp(1, 1000);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context,
          icon: _currency == 'USD'
              ? TablerIcons.currency_dollar
              : TablerIcons.cash,
          title: context.localization.listings_filter_price,
          trailing: _buildCurrencySelector(context),
        ),
        _buildPriceRangeInputs(context),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: context.currentTheme.bgBrandDefault,
            inactiveTrackColor: context.currentTheme.strokeNeutralLight200,
            thumbColor: context.currentTheme.bgBrandDefault,
            overlayColor: context.currentTheme.bgBrandLight100.withValues(
              alpha: 0.2,
            ),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 9,
            ),
          ),
          child: RangeSlider(
            values: RangeValues(currentMin, currentMax),
            min: minBound,
            max: maxBound,
            divisions: divisions,
            onChanged: (values) {
              final steppedStart = (values.start / step).round() * step;
              final steppedEnd = (values.end / step).round() * step;
              final newMin = steppedStart <= minBound ? null : steppedStart;
              final newMax = steppedEnd >= maxBound ? null : steppedEnd;

              setState(() {
                _draft = _draft.copyWith(
                  priceMin: newMin,
                  priceMax: newMax,
                  clearPriceMin: newMin == null,
                  clearPriceMax: newMax == null,
                );
                _priceMinController.text = _formatPriceValue(newMin, _currency);
                _priceMaxController.text = _formatPriceValue(newMax, _currency);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencySelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.currentTheme.bgSurfaceBase2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.currentTheme.strokeNeutralLight100),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['USD', 'UZS'].map((curr) {
          final isSelected = _currency == curr;
          return GestureDetector(
            onTap: () {
              if (_currency != curr) {
                setState(() {
                  _currency = curr;
                  _priceMinController.clear();
                  _priceMaxController.clear();
                  _draft = _draft.copyWith(
                    currency: curr,
                    clearPriceMin: true,
                    clearPriceMax: true,
                  );
                });
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.currentTheme.bgBrandDefault
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                curr,
                style: AppTextStyles.p4Medium.copyWith(
                  color: isSelected
                      ? context.currentTheme.textNeutralWhite
                      : context.currentTheme.textNeutralSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceRangeInputs(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _priceMinController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            style: AppTextStyles.p3Regular.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
            decoration: _fieldDecoration(
              context,
              context.localization.listings_price_from,
              prefixIcon: Icon(
                _currency == 'USD'
                    ? TablerIcons.currency_dollar
                    : TablerIcons.cash,
                size: 16,
                color: context.currentTheme.iconNeutralDefault,
              ),
              hintText: '0',
            ),
            onChanged: (val) {
              final cleanText = val.replaceAll('.', '').trim();
              final parsed = double.tryParse(cleanText);
              setState(() {
                _draft = parsed == null
                    ? _draft.copyWith(clearPriceMin: true)
                    : _draft.copyWith(priceMin: parsed);
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _priceMaxController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            style: AppTextStyles.p3Regular.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
            decoration: _fieldDecoration(
              context,
              context.localization.listings_price_to,
              prefixIcon: Icon(
                _currency == 'USD'
                    ? TablerIcons.currency_dollar
                    : TablerIcons.cash,
                size: 16,
                color: context.currentTheme.iconNeutralDefault,
              ),
              hintText: _formatPriceValue(_maxPriceBound, _currency),
            ),
            onChanged: (val) {
              final cleanText = val.replaceAll('.', '').trim();
              final parsed = double.tryParse(cleanText);
              setState(() {
                _draft = parsed == null
                    ? _draft.copyWith(clearPriceMax: true)
                    : _draft.copyWith(priceMax: parsed);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoomsSection(BuildContext context) {
    final theme = context.currentTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context,
          icon: TablerIcons.bed,
          title: context.localization.listings_filter_rooms,
        ),
        Row(
          children: _roomPresets.map((preset) {
            final isSelected = preset.isSelected(
              _draft.roomsMin,
              _draft.roomsMax,
            );

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onRoomPresetTapped(preset),
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.bgBrandLight100
                            : theme.bgSurfaceBase2,
                        borderRadius: BorderRadius.circular(AppRadius.input),
                        border: Border.all(
                          color: isSelected
                              ? theme.strokeBrandHover
                              : theme.strokeNeutralLight100,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Text(
                        preset.label,
                        style: AppTextStyles.p3Medium.copyWith(
                          color: isSelected
                              ? theme.textBrandPrimary
                              : theme.textNeutralPrimary,
                          fontWeight: isSelected ? FontWeight.w700 : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _onRoomPresetTapped(_RoomPreset preset) {
    final isCurrentlySelected = preset.isSelected(
      _draft.roomsMin,
      _draft.roomsMax,
    );
    setState(() {
      if (isCurrentlySelected) {
        _draft = _draft.copyWith(clearRoomsMin: true, clearRoomsMax: true);
      } else {
        _draft = _draft.copyWith(
          roomsMin: preset.min,
          roomsMax: preset.max,
          clearRoomsMin: preset.min == null,
          clearRoomsMax: preset.max == null,
        );
      }
    });
  }

  Widget _buildFurnishingSlider(
    BuildContext context,
    List<ListingChoice> furnishings,
  ) {
    final theme = context.currentTheme;

    // Fixed 3 positions with localized compact labels
    final options = <ListingChoice>[
      ListingChoice(
        value: 'unfurnished',
        label: context.localization.listings_furnishing_unfurnished,
      ),
      ListingChoice(
        value: 'semi_furnished',
        label: context.localization.listings_furnishing_semi_furnished,
      ),
      ListingChoice(
        value: 'furnished',
        label: context.localization.listings_furnishing_furnished,
      ),
    ];

    final activeIndex = options.indexWhere(
      (opt) => opt.value.toLowerCase() == _draft.furnishing?.toLowerCase(),
    );

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: theme.bgSurfaceBase2,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: theme.strokeNeutralLight100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(options.length, (index) {
          final opt = options[index];
          final isSelected = index == activeIndex;
          final foregroundColor = isSelected
              ? theme.textBrandPrimary
              : theme.textNeutralPrimary;
          final iconColor = isSelected
              ? theme.iconBrandPrimary
              : theme.iconNeutralDefault;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      _onFurnishingChanged(isSelected ? null : opt.value),
                  borderRadius: BorderRadius.circular(AppRadius.input - 2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.bgBrandLight100
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.input - 2),
                      border: Border.all(
                        color: isSelected
                            ? theme.strokeBrandHover
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getFurnishingIcon(opt.value),
                          size: 16,
                          color: iconColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            opt.label,
                            style: AppTextStyles.p4Medium.copyWith(
                              color: foregroundColor,
                              fontWeight: isSelected ? FontWeight.w600 : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVerificationSection(BuildContext context) {
    final isChecked = _draft.verified ?? false;
    return Container(
      decoration: BoxDecoration(
        color: context.currentTheme.bgSurfaceBase2,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(
          color: isChecked
              ? context.currentTheme.strokeBrandHover
              : context.currentTheme.strokeNeutralLight100,
        ),
      ),
      child: InkWell(
        onTap: () => _onVerifiedChanged(isChecked ? null : true),
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                TablerIcons.shield_check,
                size: 20,
                color: isChecked
                    ? context.currentTheme.iconBrandPrimary
                    : context.currentTheme.iconNeutralDefault,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.localization.listings_filter_verification,
                      style: AppTextStyles.p3Medium.copyWith(
                        color: context.currentTheme.textNeutralPrimary,
                      ),
                    ),
                    Text(
                      context.localization.listings_chip_verified,
                      style: AppTextStyles.p4Regular.copyWith(
                        color: context.currentTheme.textNeutralSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isChecked,
                  activeColor: context.currentTheme.bgBrandDefault,
                  checkColor: context.currentTheme.textNeutralWhite,
                  side: BorderSide(
                    color: context.currentTheme.strokeNeutralLight200,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (value) {
                    _onVerifiedChanged((value ?? false) ? true : null);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context,
    String? label, {
    Widget? prefixIcon,
    String? hintText,
  }) {
    final base = InputDecorations.denseDecoration(
      label ?? '',
      context: context,
    );
    return base.copyWith(
      labelText: label,
      hintText: hintText,
      prefixIcon: prefixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(left: 10, right: 6),
              child: prefixIcon,
            )
          : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      hintStyle: AppTextStyles.p3Regular.copyWith(
        color: context.currentTheme.textNeutralDisable,
      ),
      labelStyle: AppTextStyles.p3Medium.copyWith(
        color: context.currentTheme.textNeutralSecondary,
      ),
      floatingLabelStyle: AppTextStyles.p3Medium.copyWith(
        color: context.currentTheme.textBrandPrimary,
      ),
      isDense: true,
      filled: true,
      fillColor: context.currentTheme.bgSurfaceBase2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      border: _buildOutlineInputBorder(context),
      enabledBorder: _buildOutlineInputBorder(context),
      focusedBorder: _buildOutlineInputBorder(context, hasFocus: true),
    );
  }

  OutlineInputBorder _buildOutlineInputBorder(
    BuildContext context, {
    bool hasFocus = false,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide(
        color: hasFocus
            ? context.currentTheme.strokeBrandHover
            : context.currentTheme.strokeNeutralLight100,
      ),
    );
  }

  Widget _buildChoiceGroup(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<ListingChoice> choices,
    required String? selectedValue,
    required IconData Function(String value) getIcon,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(context, icon: icon, title: title),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...choices.map(
              (choice) => _buildChoice(
                context,
                label: choice.label,
                icon: getIcon(choice.value),
                selected: selectedValue == choice.value,
                onTap: () => onChanged(
                  selectedValue == choice.value ? null : choice.value,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChoice(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final foregroundColor = selected
        ? context.currentTheme.textBrandPrimary
        : context.currentTheme.textNeutralPrimary;
    final iconColor = selected
        ? context.currentTheme.iconBrandPrimary
        : context.currentTheme.iconNeutralDefault;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 38),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? context.currentTheme.bgBrandLight100
                : context.currentTheme.bgSurfaceBase2,
            border: Border.all(
              color: selected
                  ? context.currentTheme.strokeBrandHover
                  : context.currentTheme.strokeNeutralLight100,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.p3Medium.copyWith(color: foregroundColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: context.currentTheme.bgSurfaceSheet,
        border: Border(
          top: BorderSide(color: context.currentTheme.strokeNeutralLight200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              style: AppButtonStyle.outline,
              size: AppButtonSize.medium,
              label: context.localization.listings_clear_all,
              foregroundColor: context.currentTheme.textNeutralPrimary,
              backgroundColor: context.currentTheme.bgSurfaceBase2,
              borderColor: context.currentTheme.strokeNeutralLight200,
              shouldSetFullWidth: true,
              onPressed: _clearDraft,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppButton(
              size: AppButtonSize.medium,
              label: context.localization.listings_apply,
              foregroundColor: context.currentTheme.textNeutralWhite,
              backgroundColor: context.currentTheme.bgBrandDefault,
              shouldSetFullWidth: true,
              onPressed: _applyDraft,
            ),
          ),
        ],
      ),
    );
  }

  void _onFurnishingChanged(String? value) {
    setState(() {
      _draft = value == null
          ? _draft.copyWith(clearFurnishing: true)
          : _draft.copyWith(furnishing: value);
    });
  }

  Widget _buildAvailabilitySection(BuildContext context) {
    final initialFlexibility =
        _draft.flexibilityDays ?? kDefaultFlexibilityDays;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context,
          icon: TablerIcons.calendar,
          title: context.localization.listings_availability,
        ),
        ListingDateFilterField(
          key: ValueKey(_draft.hasDateRange),
          initialStartDate: _draft.startDate,
          initialEndDate: _draft.endDate,
          initialFlexibilityDays: initialFlexibility,
          onChanged: _onDatesChanged,
        ),
      ],
    );
  }

  void _onDatesChanged(DateTime? start, DateTime? end, int flexibility) {
    setState(() {
      _draft = _draft.copyWith(
        startDate: start,
        endDate: end,
        flexibilityDays: flexibility,
        clearDates: start == null && end == null,
        clearFlexibility: start == null && end == null,
      );
    });
  }

  void _onPropertyTypeChanged(String? value) {
    setState(() {
      _draft = value == null
          ? _draft.copyWith(clearPropertyType: true)
          : _draft.copyWith(propertyType: value);
    });
  }

  void _onVerifiedChanged(bool? value) {
    setState(() {
      _draft = value == null
          ? _draft.copyWith(clearVerified: true)
          : _draft.copyWith(verified: value);
    });
  }

  void _onTariffChanged(String? value) {
    setState(() {
      _draft = value == null
          ? _draft.copyWith(clearTariff: true)
          : _draft.copyWith(tariff: value);
    });
  }

  void _clearDraft() {
    setState(() {
      _draft = const ListingFilters.empty();
      _currency = 'USD';
      _priceMinController.clear();
      _priceMaxController.clear();
    });
  }

  void _applyDraft() {
    var finalDraft = _draft;
    if (finalDraft.priceMin != null &&
        finalDraft.priceMax != null &&
        finalDraft.priceMin! > finalDraft.priceMax!) {
      finalDraft = finalDraft.copyWith(
        priceMin: finalDraft.priceMax,
        priceMax: finalDraft.priceMin,
      );
    }
    if (finalDraft.roomsMin != null &&
        finalDraft.roomsMax != null &&
        finalDraft.roomsMin! > finalDraft.roomsMax!) {
      finalDraft = finalDraft.copyWith(
        roomsMin: finalDraft.roomsMax,
        roomsMax: finalDraft.roomsMin,
      );
    }
    Navigator.of(context).pop(finalDraft);
  }

  static String _formatPriceValue(num? value, String currency) {
    if (value == null) return '';
    final intVal = value.round();
    if (currency == 'UZS') {
      final raw = intVal.toString();
      return raw.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    }
    return intVal.toString();
  }

  static IconData _getPropertyTypeIcon(String value) {
    switch (value.toLowerCase()) {
      case 'apartment':
        return TablerIcons.building;
      case 'house':
        return TablerIcons.home;
      case 'studio':
        return TablerIcons.layout;
      case 'room':
        return TablerIcons.door;
      default:
        return TablerIcons.building;
    }
  }

  static IconData _getFurnishingIcon(String value) {
    switch (value.toLowerCase()) {
      case 'furnished':
        return TablerIcons.armchair;
      case 'semi_furnished':
        return TablerIcons.lamp;
      case 'unfurnished':
        return TablerIcons.box;
      default:
        return TablerIcons.sofa;
    }
  }

  static IconData _getTariffIcon(String value) {
    switch (value.toLowerCase()) {
      case 'standard':
        return TablerIcons.tag;
      case 'comfort':
        return TablerIcons.sparkles;
      case 'premium':
        return TablerIcons.crown;
      default:
        return TablerIcons.star;
    }
  }
}
