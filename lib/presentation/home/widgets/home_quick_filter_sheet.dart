import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';
import 'package:ideal_mobile/widgets/styling/input_decorations.dart';

enum HomeQuickFilterKind { district, rooms, price, tariff }

class _PresetRange {
  const _PresetRange({this.min, this.max, required this.label});

  final num? min;
  final num? max;
  final String label;

  bool matches(num? currentMin, num? currentMax) {
    if (min == 5 && max == null) {
      return currentMin == 5 && currentMax == null;
    }
    return currentMin == min && currentMax == max;
  }
}

const _roomPresets = <_PresetRange>[
  _PresetRange(min: 1, max: 1, label: '1'),
  _PresetRange(min: 2, max: 2, label: '2'),
  _PresetRange(min: 3, max: 3, label: '3'),
  _PresetRange(min: 4, max: 4, label: '4'),
  _PresetRange(min: 5, label: '5+'),
];

Future<ListingFilters?> showHomeQuickFilterSheet(
  BuildContext context, {
  required HomeQuickFilterKind kind,
  required ListingFilters filters,
  required ListingFilterOptions filterOptions,
}) {
  return showModalBottomSheet<ListingFilters?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.currentTheme.bgSurfaceSheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: HomeQuickFilterSheet(
        kind: kind,
        initialFilters: filters,
        filterOptions: filterOptions,
      ),
    ),
  );
}

class HomeQuickFilterSheet extends StatefulWidget {
  const HomeQuickFilterSheet({
    super.key,
    required this.kind,
    required this.initialFilters,
    required this.filterOptions,
  });

  final HomeQuickFilterKind kind;
  final ListingFilters initialFilters;
  final ListingFilterOptions filterOptions;

  @override
  State<HomeQuickFilterSheet> createState() => _HomeQuickFilterSheetState();
}

class _HomeQuickFilterSheetState extends State<HomeQuickFilterSheet> {
  late ListingFilters _draft;
  late String _currency;

  // Controllers for price
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  static const double _defaultUsdMax = 3000.0;
  static const double _defaultUzsMax = 40000000.0;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialFilters;
    _currency = _draft.currency ?? 'USD';

    switch (widget.kind) {
      case HomeQuickFilterKind.price:
        _minController = TextEditingController(
          text: _formatPriceValue(_draft.priceMin, _currency),
        );
        _maxController = TextEditingController(
          text: _formatPriceValue(_draft.priceMax, _currency),
        );
      case HomeQuickFilterKind.rooms:
      case HomeQuickFilterKind.district:
      case HomeQuickFilterKind.tariff:
        _minController = TextEditingController();
        _maxController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  String _sheetTitle(BuildContext context) {
    switch (widget.kind) {
      case HomeQuickFilterKind.district:
        return context.localization.home_quick_filter_district;
      case HomeQuickFilterKind.rooms:
        return context.localization.home_quick_filter_rooms;
      case HomeQuickFilterKind.price:
        return context.localization.home_quick_filter_price;
      case HomeQuickFilterKind.tariff:
        return context.localization.home_quick_filter_tariff;
    }
  }

  IconData _sheetIcon() {
    switch (widget.kind) {
      case HomeQuickFilterKind.district:
        return TablerIcons.map_pin;
      case HomeQuickFilterKind.rooms:
        return TablerIcons.bed;
      case HomeQuickFilterKind.price:
        return _currency == 'USD'
            ? TablerIcons.currency_dollar
            : TablerIcons.cash;
      case HomeQuickFilterKind.tariff:
        return TablerIcons.sparkles;
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
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _buildBody(context),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: context.currentTheme.strokeNeutralLight200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
          child: Row(
            children: [
              Icon(
                _sheetIcon(),
                size: 20,
                color: context.currentTheme.iconNeutralDefault,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _sheetTitle(context),
                  style: AppTextStyles.h6Bold.copyWith(
                    color: context.currentTheme.textNeutralPrimary,
                  ),
                ),
              ),
              if (widget.kind == HomeQuickFilterKind.price)
                _buildCurrencySelector(context),
              IconButton(
                icon: Icon(
                  TablerIcons.x,
                  size: 20,
                  color: context.currentTheme.iconNeutralDefault,
                ),
                onPressed: () => Navigator.of(context).pop(),
                visualDensity: VisualDensity.compact,
                splashRadius: 20,
              ),
            ],
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
                  _minController.clear();
                  _maxController.clear();
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  Widget _buildBody(BuildContext context) {
    switch (widget.kind) {
      case HomeQuickFilterKind.district:
        return _buildDistrictBody(context);
      case HomeQuickFilterKind.tariff:
        return _buildTariffBody(context);
      case HomeQuickFilterKind.rooms:
        return _buildRoomsBody(context);
      case HomeQuickFilterKind.price:
        return _buildPriceBody(context);
    }
  }

  Widget _buildDistrictBody(BuildContext context) {
    final districts = widget.filterOptions.districts;
    if (districts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            context.localization.home_quick_filter_no_districts,
            style: AppTextStyles.p2Regular.copyWith(
              color: context.currentTheme.textNeutralSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final district in districts)
          _buildSelectableCard(
            context,
            icon: TablerIcons.map_pin,
            label: district.name,
            isSelected: _draft.districtId == district.id,
            onTap: () {
              setState(() {
                _draft = _draft.districtId == district.id
                    ? _draft.copyWith(clearDistrictId: true)
                    : _draft.copyWith(districtId: district.id);
              });
            },
          ),
      ],
    );
  }

  Widget _buildTariffBody(BuildContext context) {
    final tariffs = widget.filterOptions.tariffs.isNotEmpty
        ? widget.filterOptions.tariffs
        : [
            ListingChoice(
              value: 'standard',
              label: context.localization.listings_tariff_standard,
            ),
            ListingChoice(
              value: 'comfort',
              label: context.localization.listings_tariff_comfort,
            ),
            ListingChoice(
              value: 'premium',
              label: context.localization.listings_tariff_premium,
            ),
          ];

    if (tariffs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            context.localization.home_quick_filter_no_tariffs,
            style: AppTextStyles.p2Regular.copyWith(
              color: context.currentTheme.textNeutralSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final choice in tariffs)
          _buildSelectableCard(
            context,
            icon: _getTariffIcon(choice.value),
            label: choice.label,
            isSelected:
                _draft.tariff?.toLowerCase() == choice.value.toLowerCase(),
            onTap: () {
              setState(() {
                final isSelected =
                    _draft.tariff?.toLowerCase() == choice.value.toLowerCase();
                _draft = isSelected
                    ? _draft.copyWith(clearTariff: true)
                    : _draft.copyWith(tariff: choice.value);
              });
            },
          ),
      ],
    );
  }

  Widget _buildRoomsBody(BuildContext context) {
    final minRooms = _draft.roomsMin;
    final maxRooms = _draft.roomsMax;
    final theme = context.currentTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: _roomPresets.map((preset) {
          final isSelected = preset.matches(minRooms, maxRooms);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onRoomPresetTapped(preset, isSelected),
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
    );
  }

  Widget _buildPriceBody(BuildContext context) {
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
        _buildRangeFields(
          context,
          minController: _minController,
          maxController: _maxController,
          minHint: minBound,
          maxHint: maxBound,
          prefixIcon: Icon(
            _currency == 'USD' ? TablerIcons.currency_dollar : TablerIcons.cash,
            size: 16,
            color: context.currentTheme.iconNeutralDefault,
          ),
          onMinChanged: (value) {
            final clean = value.replaceAll('.', '').trim();
            final parsed = double.tryParse(clean);
            setState(() {
              _draft = clean.isEmpty
                  ? _draft.copyWith(clearPriceMin: true)
                  : _draft.copyWith(priceMin: parsed);
            });
          },
          onMaxChanged: (value) {
            final clean = value.replaceAll('.', '').trim();
            final parsed = double.tryParse(clean);
            setState(() {
              _draft = clean.isEmpty
                  ? _draft.copyWith(clearPriceMax: true)
                  : _draft.copyWith(priceMax: parsed);
            });
          },
        ),
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
                _minController.text = _formatPriceValue(newMin, _currency);
                _maxController.text = _formatPriceValue(newMax, _currency);
              });
            },
          ),
        ),
      ],
    );
  }

  void _onRoomPresetTapped(_PresetRange preset, bool isAlreadySelected) {
    if (isAlreadySelected) {
      setState(() {
        _draft = _draft.copyWith(clearRoomsMin: true, clearRoomsMax: true);
      });
    } else {
      setState(() {
        _draft = _draft.copyWith(
          roomsMin: preset.min as int?,
          roomsMax: preset.max as int?,
          clearRoomsMin: preset.min == null,
          clearRoomsMax: preset.max == null,
        );
      });
    }
  }

  Widget _buildSelectableCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? context.currentTheme.bgBrandLight50
            : context.currentTheme.bgSurfaceBase2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(
            color: isSelected
                ? context.currentTheme.strokeBrandDefault
                : context.currentTheme.strokeNeutralLight100,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? context.currentTheme.iconBrandPrimary
                      : context.currentTheme.iconNeutralDefault,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.p1Medium.copyWith(
                      color: isSelected
                          ? context.currentTheme.textBrandPrimary
                          : context.currentTheme.textNeutralPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    TablerIcons.check,
                    color: context.currentTheme.iconBrandPrimary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRangeFields(
    BuildContext context, {
    required TextEditingController minController,
    required TextEditingController maxController,
    required num? minHint,
    required num? maxHint,
    Widget? prefixIcon,
    required ValueChanged<String> onMinChanged,
    required ValueChanged<String> onMaxChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: minController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            style: AppTextStyles.p3Regular.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
            decoration: _fieldDecoration(
              context,
              context.localization.listings_range_min,
              prefixIcon: prefixIcon,
              hintText: '0',
            ),
            onChanged: onMinChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: maxController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            style: AppTextStyles.p3Regular.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
            decoration: _fieldDecoration(
              context,
              context.localization.listings_range_max,
              prefixIcon: prefixIcon,
              hintText: _formatPriceValue(maxHint, _currency),
            ),
            onChanged: onMaxChanged,
          ),
        ),
      ],
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

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
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
          const SizedBox(width: 12),
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

  void _clearDraft() {
    setState(() {
      switch (widget.kind) {
        case HomeQuickFilterKind.district:
          _draft = _draft.copyWith(clearDistrictId: true);
        case HomeQuickFilterKind.tariff:
          _draft = _draft.copyWith(clearTariff: true);
        case HomeQuickFilterKind.rooms:
          _draft = _draft.copyWith(clearRoomsMin: true, clearRoomsMax: true);
        case HomeQuickFilterKind.price:
          _draft = _draft.copyWith(clearPriceMin: true, clearPriceMax: true);
          _minController.clear();
          _maxController.clear();
      }
    });
  }

  void _applyDraft() {
    var finalDraft = _draft;
    if (widget.kind == HomeQuickFilterKind.price) {
      if (finalDraft.priceMin != null &&
          finalDraft.priceMax != null &&
          finalDraft.priceMin! > finalDraft.priceMax!) {
        finalDraft = finalDraft.copyWith(
          priceMin: finalDraft.priceMax,
          priceMax: finalDraft.priceMin,
        );
      }
    } else if (widget.kind == HomeQuickFilterKind.rooms) {
      if (finalDraft.roomsMin != null &&
          finalDraft.roomsMax != null &&
          finalDraft.roomsMin! > finalDraft.roomsMax!) {
        finalDraft = finalDraft.copyWith(
          roomsMin: finalDraft.roomsMax,
          roomsMax: finalDraft.roomsMin,
        );
      }
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
