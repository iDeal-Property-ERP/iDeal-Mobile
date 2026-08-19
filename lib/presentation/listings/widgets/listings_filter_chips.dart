import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_filter_dropdown_chip.dart';

class ListingsFilterChips extends StatelessWidget {
  const ListingsFilterChips({
    super.key,
    required this.filters,
    required this.filterOptions,
    required this.onFiltersChanged,
    required this.onOpenFilters,
  });

  final ListingFilters filters;
  final ListingFilterOptions filterOptions;
  final ValueChanged<ListingFilters> onFiltersChanged;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      ListingsFilterPillChip(
        label: context.localization.listings_all_filters,
        selected: filters.activeCount > 0,
        leadingIcon: TablerIcons.adjustments,
        badge: filters.activeCount > 0 ? filters.activeCount : null,
        onTap: onOpenFilters,
      ),
      ListingsFilterPillChip(
        label: context.localization.listings_chip_verified,
        selected: filters.verified ?? false,
        onTap: () => _toggleVerified(filters),
      ),
    ];

    if (filterOptions.districts.isNotEmpty) {
      chips.add(_buildDistrictChip(context));
    }
    if (filterOptions.propertyTypes.isNotEmpty) {
      chips.add(_buildPropertyTypeChip(context));
    }
    chips.add(_buildRoomsChip(context));
    chips.add(_buildPriceChip(context));
    if (filterOptions.tariffs.isNotEmpty) {
      chips.add(_buildTariffChip(context));
    }
    if (filterOptions.furnishings.isNotEmpty) {
      chips.add(_buildFurnishingChip(context));
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: _withGaps(chips)),
      ),
    );
  }

  List<Widget> _withGaps(List<Widget> children) {
    final widgets = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0) widgets.add(const SizedBox(width: 8));
      widgets.add(children[index]);
    }
    return widgets;
  }

  Widget _buildDistrictChip(BuildContext context) {
    final districts = filterOptions.districts;
    final selectedDistrict = _findDistrict(districts, filters.districtId);
    final options = <ListingsFilterDropdownOption<int>>[
      ListingsFilterDropdownOption<int>(
        value: null,
        label: context.localization.listings_anywhere,
      ),
      ...districts.map(
        (district) => ListingsFilterDropdownOption<int>(
          value: district.id,
          label: district.name,
        ),
      ),
    ];

    return ListingsFilterDropdownChip<int>(
      label: context.localization.listings_filter_district,
      options: options,
      selected: filters.districtId,
      selectedLabel: selectedDistrict == null && filters.districtId != null
          ? filters.districtId.toString()
          : null,
      onSelected: (value) {
        final updated = value == null
            ? filters.copyWith(clearDistrictId: true)
            : filters.copyWith(districtId: value);
        onFiltersChanged(updated);
      },
    );
  }

  Widget _buildRoomsChip(BuildContext context) {
    final selectedRange = _matchingRange(
      filters.roomsMin,
      filters.roomsMax,
      _roomPresets,
    );
    final hasSelectedRange =
        filters.roomsMin != null || filters.roomsMax != null;

    return ListingsFilterDropdownChip<_FilterRange>(
      label: context.localization.listings_filter_rooms,
      options: _roomOptions(context),
      selected: selectedRange,
      selectedLabel: hasSelectedRange
          ? _roomsRangeLabel(
              selectedRange ?? _FilterRange(filters.roomsMin, filters.roomsMax),
            )
          : null,
      onSelected: (value) {
        final updated = value == null
            ? filters.copyWith(clearRoomsMin: true, clearRoomsMax: true)
            : filters.copyWith(
                roomsMin: value.min?.toInt(),
                roomsMax: value.max?.toInt(),
                clearRoomsMin: value.min == null,
                clearRoomsMax: value.max == null,
              );
        onFiltersChanged(updated);
      },
    );
  }

  Widget _buildPropertyTypeChip(BuildContext context) {
    return ListingsFilterDropdownChip<String>(
      label: context.localization.listings_filter_property_type,
      options: [
        ListingsFilterDropdownOption<String>(
          value: null,
          label: context.localization.listings_any,
        ),
        ...filterOptions.propertyTypes.map(
          (choice) => ListingsFilterDropdownOption<String>(
            value: choice.value,
            label: choice.label,
          ),
        ),
      ],
      selected: filters.propertyType,
      onSelected: (value) {
        final updated = value == null
            ? filters.copyWith(clearPropertyType: true)
            : filters.copyWith(propertyType: value);
        onFiltersChanged(updated);
      },
    );
  }

  Widget _buildPriceChip(BuildContext context) {
    final selectedRange = _matchingRange(
      filters.priceMin,
      filters.priceMax,
      _pricePresets,
    );
    final hasSelectedRange =
        filters.priceMin != null || filters.priceMax != null;

    return ListingsFilterDropdownChip<_FilterRange>(
      label: context.localization.listings_filter_price,
      options: _priceOptions(context),
      selected: selectedRange,
      selectedLabel: hasSelectedRange
          ? _priceRangeLabel(
              selectedRange ?? _FilterRange(filters.priceMin, filters.priceMax),
            )
          : null,
      onSelected: (value) {
        final updated = value == null
            ? filters.copyWith(clearPriceMin: true, clearPriceMax: true)
            : filters.copyWith(
                priceMin: value.min?.toDouble(),
                priceMax: value.max?.toDouble(),
                clearPriceMin: value.min == null,
                clearPriceMax: value.max == null,
              );
        onFiltersChanged(updated);
      },
    );
  }

  Widget _buildTariffChip(BuildContext context) {
    return ListingsFilterDropdownChip<String>(
      label: context.localization.listings_filter_tariff,
      options: [
        ListingsFilterDropdownOption<String>(
          value: null,
          label: context.localization.listings_any,
        ),
        ...filterOptions.tariffs.map(
          (choice) => ListingsFilterDropdownOption<String>(
            value: choice.value,
            label: choice.label,
          ),
        ),
      ],
      selected: filters.tariff,
      onSelected: (value) {
        final updated = value == null
            ? filters.copyWith(clearTariff: true)
            : filters.copyWith(tariff: value);
        onFiltersChanged(updated);
      },
    );
  }

  Widget _buildFurnishingChip(BuildContext context) {
    return ListingsFilterDropdownChip<String>(
      label: context.localization.listings_filter_furnishing,
      options: [
        ListingsFilterDropdownOption<String>(
          value: null,
          label: context.localization.listings_any,
        ),
        ...filterOptions.furnishings.map(
          (choice) => ListingsFilterDropdownOption<String>(
            value: choice.value,
            label: choice.label,
          ),
        ),
      ],
      selected: filters.furnishing,
      onSelected: (value) {
        final updated = value == null
            ? filters.copyWith(clearFurnishing: true)
            : filters.copyWith(furnishing: value);
        onFiltersChanged(updated);
      },
    );
  }

  List<ListingsFilterDropdownOption<_FilterRange>> _roomOptions(
    BuildContext context,
  ) {
    return [
      ListingsFilterDropdownOption<_FilterRange>(
        value: null,
        label: context.localization.listings_any,
      ),
      for (final preset in _roomPresets)
        if (_isRoomPresetInBounds(preset))
          ListingsFilterDropdownOption<_FilterRange>(
            value: preset,
            label: _roomsRangeLabel(preset),
          ),
    ];
  }

  List<ListingsFilterDropdownOption<_FilterRange>> _priceOptions(
    BuildContext context,
  ) {
    return [
      ListingsFilterDropdownOption<_FilterRange>(
        value: null,
        label: context.localization.listings_any,
      ),
      for (final preset in _pricePresets)
        ListingsFilterDropdownOption<_FilterRange>(
          value: preset,
          label: _priceRangeLabel(preset),
        ),
    ];
  }

  ListingDistrict? _findDistrict(
    List<ListingDistrict> districts,
    int? districtId,
  ) {
    for (final district in districts) {
      if (district.id == districtId) return district;
    }
    return null;
  }

  _FilterRange? _matchingRange(
    num? minimum,
    num? maximum,
    List<_FilterRange> presets,
  ) {
    for (final preset in presets) {
      if (preset.min == minimum && preset.max == maximum) return preset;
    }
    return null;
  }

  bool _isRoomPresetInBounds(_FilterRange preset) {
    if (preset.max != null &&
        filterOptions.roomsMin != null &&
        preset.max! < filterOptions.roomsMin!) {
      return false;
    }
    if (preset.min != null &&
        filterOptions.roomsMax != null &&
        preset.min! > filterOptions.roomsMax!) {
      return false;
    }
    return true;
  }

  String _roomsRangeLabel(_FilterRange range) {
    if (range.min != null && range.min == range.max) {
      return _formatNumber(range.min!);
    }
    return _openRange(range.min, range.max);
  }

  String _priceRangeLabel(_FilterRange range) {
    return _openRange(range.min, range.max, prefix: '\$');
  }

  String _openRange(num? minimum, num? maximum, {String prefix = ''}) {
    final min = minimum == null ? null : '$prefix${_formatNumber(minimum)}';
    final max = maximum == null ? null : '$prefix${_formatNumber(maximum)}';

    if (min != null && max != null) return '$min–$max';
    if (min != null) return '$min+';
    if (max != null) return '≤$max';
    return '';
  }

  String _formatNumber(num value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  void _toggleVerified(ListingFilters currentFilters) {
    final updated = currentFilters.verified ?? false
        ? currentFilters.copyWith(clearVerified: true)
        : currentFilters.copyWith(verified: true);
    onFiltersChanged(updated);
  }
}

class _FilterRange {
  const _FilterRange(this.min, this.max);

  final num? min;
  final num? max;

  @override
  bool operator ==(Object other) {
    return other is _FilterRange && other.min == min && other.max == max;
  }

  @override
  int get hashCode => Object.hash(min, max);
}

const _roomPresets = <_FilterRange>[
  _FilterRange(1, 1),
  _FilterRange(2, 2),
  _FilterRange(3, 3),
  _FilterRange(4, null),
];

const _pricePresets = <_FilterRange>[
  _FilterRange(null, 300),
  _FilterRange(300, 600),
  _FilterRange(600, 1000),
  _FilterRange(1000, null),
];
