import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listings_filter_dropdown_chip.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_top_bar/app_top_bar.dart';

class ListingMapToolbar extends StatefulWidget {
  const ListingMapToolbar({
    super.key,
    required this.filters,
    required this.filterOptions,
    required this.onBack,
    required this.onSearchChanged,
    required this.onFiltersChanged,
    required this.onOpenFullFilters,
  });

  final ListingFilters filters;
  final ListingFilterOptions filterOptions;
  final VoidCallback onBack;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ListingFilters> onFiltersChanged;
  final VoidCallback onOpenFullFilters;

  @override
  State<ListingMapToolbar> createState() => _ListingMapToolbarState();
}

class _ListingMapToolbarState extends State<ListingMapToolbar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.filters.query);
  }

  @override
  void didUpdateWidget(ListingMapToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final query = widget.filters.query ?? '';
    if (_searchController.text != query) {
      _searchController.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AppTopBarAction(
                  icon: TablerIcons.arrow_left,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: widget.onBack,
                  style: AppTopBarActionStyle.overlay,
                ),
                const SizedBox(width: 6),
                Expanded(child: _buildSearch(context)),
                const SizedBox(width: 6),
                AppTopBarAction(
                  icon: TablerIcons.adjustments,
                  tooltip: context.localization.listing_map_full_filters,
                  badge: widget.filters.activeCount > 0
                      ? '${widget.filters.activeCount}'
                      : null,
                  onPressed: widget.onOpenFullFilters,
                  style: AppTopBarActionStyle.overlay,
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: _withGaps([
                    if (widget.filterOptions.districts.isNotEmpty)
                      _districtChip(context),
                    if (widget.filterOptions.propertyTypes.isNotEmpty)
                      _propertyTypeChip(context),
                    _priceChip(context),
                    _roomsChip(context),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          widget.onSearchChanged(value);
          setState(() {});
        },
        textInputAction: TextInputAction.search,
        style: AppTextStyles.p3Medium.copyWith(
          color: context.currentTheme.textNeutralPrimary,
        ),
        decoration: InputDecoration(
          hintText: context.localization.listing_map_search_hint,
          prefixIcon: const Icon(TablerIcons.search, size: 19),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: MaterialLocalizations.of(
                    context,
                  ).deleteButtonTooltip,
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                    setState(() {});
                  },
                  icon: const Icon(TablerIcons.x, size: 18),
                ),
          filled: true,
          fillColor: context.currentTheme.bgSurfaceBase2.withValues(
            alpha: 0.92,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(22),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(22),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
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

  Widget _districtChip(BuildContext context) {
    final filters = widget.filters;
    return ListingsFilterDropdownChip<int>(
      label: context.localization.listings_filter_district,
      selected: filters.districtId,
      options: [
        ListingsFilterDropdownOption<int>(
          value: null,
          label: context.localization.listings_anywhere,
        ),
        ...widget.filterOptions.districts.map(
          (district) => ListingsFilterDropdownOption<int>(
            value: district.id,
            label: district.name,
          ),
        ),
      ],
      onSelected: (value) => widget.onFiltersChanged(
        value == null
            ? filters.copyWith(clearDistrictId: true)
            : filters.copyWith(districtId: value),
      ),
      compact: true,
    );
  }

  Widget _propertyTypeChip(BuildContext context) {
    final filters = widget.filters;
    return ListingsFilterDropdownChip<String>(
      label: context.localization.listings_filter_property_type,
      selected: filters.propertyType,
      options: [
        ListingsFilterDropdownOption<String>(
          value: null,
          label: context.localization.listings_any,
        ),
        ...widget.filterOptions.propertyTypes.map(
          (choice) => ListingsFilterDropdownOption<String>(
            value: choice.value,
            label: choice.label,
          ),
        ),
      ],
      onSelected: (value) => widget.onFiltersChanged(
        value == null
            ? filters.copyWith(clearPropertyType: true)
            : filters.copyWith(propertyType: value),
      ),
      compact: true,
    );
  }

  Widget _priceChip(BuildContext context) {
    final filters = widget.filters;
    final selected = _findRange(filters.priceMin, filters.priceMax, _prices);
    return ListingsFilterDropdownChip<_Range>(
      label: context.localization.listings_filter_price,
      selected: selected,
      selectedLabel:
          selected == null &&
              (filters.priceMin != null || filters.priceMax != null)
          ? _rangeLabel(filters.priceMin, filters.priceMax, prefix: r'$')
          : null,
      options: [
        ListingsFilterDropdownOption<_Range>(
          value: null,
          label: context.localization.listings_any,
        ),
        for (final range in _prices)
          ListingsFilterDropdownOption<_Range>(
            value: range,
            label: _rangeLabel(range.min, range.max, prefix: r'$'),
          ),
      ],
      onSelected: (value) => widget.onFiltersChanged(
        value == null
            ? filters.copyWith(clearPriceMin: true, clearPriceMax: true)
            : filters.copyWith(
                priceMin: value.min?.toDouble(),
                priceMax: value.max?.toDouble(),
                clearPriceMin: value.min == null,
                clearPriceMax: value.max == null,
              ),
      ),
      compact: true,
    );
  }

  Widget _roomsChip(BuildContext context) {
    final filters = widget.filters;
    final selected = _findRange(filters.roomsMin, filters.roomsMax, _rooms);
    return ListingsFilterDropdownChip<_Range>(
      label: context.localization.listings_filter_rooms,
      selected: selected,
      selectedLabel:
          selected == null &&
              (filters.roomsMin != null || filters.roomsMax != null)
          ? _rangeLabel(filters.roomsMin, filters.roomsMax)
          : null,
      options: [
        ListingsFilterDropdownOption<_Range>(
          value: null,
          label: context.localization.listings_any,
        ),
        for (final range in _rooms)
          ListingsFilterDropdownOption<_Range>(
            value: range,
            label: _rangeLabel(range.min, range.max),
          ),
      ],
      onSelected: (value) => widget.onFiltersChanged(
        value == null
            ? filters.copyWith(clearRoomsMin: true, clearRoomsMax: true)
            : filters.copyWith(
                roomsMin: value.min?.toInt(),
                roomsMax: value.max?.toInt(),
                clearRoomsMin: value.min == null,
                clearRoomsMax: value.max == null,
              ),
      ),
      compact: true,
    );
  }
}

class _Range {
  const _Range(this.min, this.max);

  final num? min;
  final num? max;
}

_Range? _findRange(num? min, num? max, List<_Range> ranges) {
  for (final range in ranges) {
    if (range.min == min && range.max == max) return range;
  }
  return null;
}

String _rangeLabel(num? min, num? max, {String prefix = ''}) {
  String formatted(num value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';
  if (min != null && max != null) {
    return '$prefix${formatted(min)}–$prefix${formatted(max)}';
  }
  if (min != null) return '$prefix${formatted(min)}+';
  if (max != null) return '≤$prefix${formatted(max)}';
  return '';
}

const _prices = <_Range>[
  _Range(null, 300),
  _Range(300, 600),
  _Range(600, 1000),
  _Range(1000, null),
];

const _rooms = <_Range>[
  _Range(1, 1),
  _Range(2, 2),
  _Range(3, 3),
  _Range(4, null),
];
