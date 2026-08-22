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
    return currentMin == min && currentMax == max;
  }
}

const _roomPresets = <_PresetRange>[
  _PresetRange(min: 1, max: 1, label: '1'),
  _PresetRange(min: 2, max: 2, label: '2'),
  _PresetRange(min: 3, max: 3, label: '3'),
  _PresetRange(min: 4, label: '4+'),
];

const _pricePresets = <_PresetRange>[
  _PresetRange(max: 300, label: '≤\$300'),
  _PresetRange(min: 300, max: 600, label: '\$300–\$600'),
  _PresetRange(min: 600, max: 1000, label: '\$600–\$1000'),
  _PresetRange(min: 1000, label: '\$1000+'),
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

  // Controllers for rooms and price
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialFilters;

    switch (widget.kind) {
      case HomeQuickFilterKind.rooms:
        _minController = TextEditingController(
          text: _formatNumber(_draft.roomsMin),
        );
        _maxController = TextEditingController(
          text: _formatNumber(_draft.roomsMax),
        );
      case HomeQuickFilterKind.price:
        _minController = TextEditingController(
          text: _formatNumber(_draft.priceMin),
        );
        _maxController = TextEditingController(
          text: _formatNumber(_draft.priceMax),
        );
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
    final title = _sheetTitle(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.currentTheme.strokeNeutralLight200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.h2Bold.copyWith(
                  color: context.currentTheme.textNeutralPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(TablerIcons.x),
                color: context.currentTheme.iconNeutralDefault,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
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
    _PresetRange? activePreset;
    for (final preset in _roomPresets) {
      if (preset.matches(_draft.roomsMin, _draft.roomsMax)) {
        activePreset = preset;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in _roomPresets)
              _buildPresetChip(
                context,
                label: preset.label,
                isSelected: activePreset == preset,
                onTap: () =>
                    _onRoomPresetTapped(preset, activePreset == preset),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          context.localization.home_quick_filter_custom_range,
          style: AppTextStyles.p3Medium.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _buildRangeFields(
          context,
          minController: _minController,
          maxController: _maxController,
          minHint: widget.filterOptions.roomsMin,
          maxHint: widget.filterOptions.roomsMax,
          onMinChanged: (value) {
            final parsed = int.tryParse(value);
            setState(() {
              _draft = value.isEmpty
                  ? _draft.copyWith(clearRoomsMin: true)
                  : _draft.copyWith(roomsMin: parsed);
            });
          },
          onMaxChanged: (value) {
            final parsed = int.tryParse(value);
            setState(() {
              _draft = value.isEmpty
                  ? _draft.copyWith(clearRoomsMax: true)
                  : _draft.copyWith(roomsMax: parsed);
            });
          },
        ),
      ],
    );
  }

  Widget _buildPriceBody(BuildContext context) {
    _PresetRange? activePreset;
    for (final preset in _pricePresets) {
      if (preset.matches(_draft.priceMin, _draft.priceMax)) {
        activePreset = preset;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in _pricePresets)
              _buildPresetChip(
                context,
                label: preset.label,
                isSelected: activePreset == preset,
                onTap: () =>
                    _onPricePresetTapped(preset, activePreset == preset),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          context.localization.home_quick_filter_custom_range,
          style: AppTextStyles.p3Medium.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _buildRangeFields(
          context,
          minController: _minController,
          maxController: _maxController,
          minHint: widget.filterOptions.priceMin,
          maxHint: widget.filterOptions.priceMax,
          onMinChanged: (value) {
            final parsed = double.tryParse(value);
            setState(() {
              _draft = value.isEmpty
                  ? _draft.copyWith(clearPriceMin: true)
                  : _draft.copyWith(priceMin: parsed);
            });
          },
          onMaxChanged: (value) {
            final parsed = double.tryParse(value);
            setState(() {
              _draft = value.isEmpty
                  ? _draft.copyWith(clearPriceMax: true)
                  : _draft.copyWith(priceMax: parsed);
            });
          },
        ),
      ],
    );
  }

  void _onRoomPresetTapped(_PresetRange preset, bool isAlreadySelected) {
    if (isAlreadySelected) {
      setState(() {
        _draft = _draft.copyWith(clearRoomsMin: true, clearRoomsMax: true);
        _minController.clear();
        _maxController.clear();
      });
    } else {
      setState(() {
        _draft = _draft.copyWith(
          roomsMin: preset.min as int?,
          roomsMax: preset.max as int?,
          clearRoomsMin: preset.min == null,
          clearRoomsMax: preset.max == null,
        );
        _minController.text = _formatNumber(preset.min);
        _maxController.text = _formatNumber(preset.max);
      });
    }
  }

  void _onPricePresetTapped(_PresetRange preset, bool isAlreadySelected) {
    if (isAlreadySelected) {
      setState(() {
        _draft = _draft.copyWith(clearPriceMin: true, clearPriceMax: true);
        _minController.clear();
        _maxController.clear();
      });
    } else {
      setState(() {
        _draft = _draft.copyWith(
          priceMin: preset.min?.toDouble(),
          priceMax: preset.max?.toDouble(),
          clearPriceMin: preset.min == null,
          clearPriceMax: preset.max == null,
        );
        _minController.text = _formatNumber(preset.min);
        _maxController.text = _formatNumber(preset.max);
      });
    }
  }

  Widget _buildSelectableCard(
    BuildContext context, {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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

  Widget _buildPresetChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final foregroundColor = isSelected
        ? context.currentTheme.textBrandPrimary
        : context.currentTheme.textNeutralPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? context.currentTheme.bgBrandLight100
                : context.currentTheme.bgSurfaceBase2,
            border: Border.all(
              color: isSelected
                  ? context.currentTheme.iconBrandPrimary
                  : context.currentTheme.strokeNeutralLight100,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppTextStyles.p3Medium.copyWith(color: foregroundColor),
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
    required ValueChanged<String> onMinChanged,
    required ValueChanged<String> onMaxChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: minController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.p3Regular.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
            decoration: _fieldDecoration(
              context,
              context.localization.listings_range_min,
              hintText: _formatNumber(minHint),
            ),
            onChanged: onMinChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: maxController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppTextStyles.p3Regular.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
            decoration: _fieldDecoration(
              context,
              context.localization.listings_range_max,
              hintText: _formatNumber(maxHint),
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
    String? hintText,
  }) {
    final base = InputDecorations.denseDecoration(
      label ?? '',
      context: context,
    );
    return base.copyWith(
      labelText: label,
      hintText: hintText,
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
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
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
              onPressed: _clearKindDraft,
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

  void _clearKindDraft() {
    setState(() {
      switch (widget.kind) {
        case HomeQuickFilterKind.district:
          _draft = _draft.copyWith(clearDistrictId: true);
        case HomeQuickFilterKind.tariff:
          _draft = _draft.copyWith(clearTariff: true);
        case HomeQuickFilterKind.rooms:
          _draft = _draft.copyWith(clearRoomsMin: true, clearRoomsMax: true);
          _minController.clear();
          _maxController.clear();
        case HomeQuickFilterKind.price:
          _draft = _draft.copyWith(clearPriceMin: true, clearPriceMax: true);
          _minController.clear();
          _maxController.clear();
      }
    });
  }

  void _applyDraft() {
    var normalized = _draft;
    if (widget.kind == HomeQuickFilterKind.rooms) {
      if (normalized.roomsMin != null &&
          normalized.roomsMax != null &&
          normalized.roomsMin! > normalized.roomsMax!) {
        normalized = normalized.copyWith(
          roomsMin: normalized.roomsMax,
          roomsMax: normalized.roomsMin,
        );
      }
    } else if (widget.kind == HomeQuickFilterKind.price) {
      if (normalized.priceMin != null &&
          normalized.priceMax != null &&
          normalized.priceMin! > normalized.priceMax!) {
        normalized = normalized.copyWith(
          priceMin: normalized.priceMax,
          priceMax: normalized.priceMin,
        );
      }
    }

    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(normalized);
  }

  String _formatNumber(num? value) {
    if (value == null) return '';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }
}
