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
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';
import 'package:ideal_mobile/widgets/styling/input_decorations.dart';

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
      expand: false,
      initialChildSize: 0.48,
      minChildSize: 0.28,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.48, 0.9],
      builder: (context, scrollController) => ListingsFilterSheet(
        initialFilters: currentFilters!,
        filterOptions: currentOptions!,
        scrollController: scrollController,
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
  });

  final ListingFilters initialFilters;
  final ListingFilterOptions filterOptions;
  final ScrollController? scrollController;

  @override
  State<ListingsFilterSheet> createState() => _ListingsFilterSheetState();
}

class _ListingsFilterSheetState extends State<ListingsFilterSheet> {
  late ListingFilters _draft;
  late final TextEditingController _priceMinController;
  late final TextEditingController _priceMaxController;
  late final TextEditingController _roomsMinController;
  late final TextEditingController _roomsMaxController;
  late final TextEditingController _districtSearchController;
  late final FocusNode _districtSearchFocusNode;
  bool _isDistrictDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialFilters;
    _priceMinController = TextEditingController(
      text: _formatNumber(_draft.priceMin),
    );
    _priceMaxController = TextEditingController(
      text: _formatNumber(_draft.priceMax),
    );
    _roomsMinController = TextEditingController(
      text: _formatNumber(_draft.roomsMin),
    );
    _roomsMaxController = TextEditingController(
      text: _formatNumber(_draft.roomsMax),
    );
    _districtSearchController = TextEditingController();
    _districtSearchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _priceMinController.dispose();
    _priceMaxController.dispose();
    _roomsMinController.dispose();
    _roomsMaxController.dispose();
    _districtSearchController.dispose();
    _districtSearchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

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
        _buildSectionTitle(
          context,
          context.localization.listings_filter_district,
        ),
        _buildDistrictDropdown(context, filterOptions.districts),
        const SizedBox(height: 12),
      ]);
    }

    if (filterOptions.propertyTypes.isNotEmpty) {
      sections.addAll([
        _buildChoiceGroup(
          context,
          title: context.localization.listings_filter_property_type,
          choices: filterOptions.propertyTypes,
          selectedValue: _draft.propertyType,
          onChanged: _onPropertyTypeChanged,
        ),
        const SizedBox(height: 12),
      ]);
    }

    sections.addAll([
      _buildSectionTitle(context, context.localization.listings_filter_price),
      _buildRangeFields(
        context,
        minController: _priceMinController,
        maxController: _priceMaxController,
        minHint: filterOptions.priceMin,
        maxHint: filterOptions.priceMax,
        onMinChanged: _onPriceMinChanged,
        onMaxChanged: _onPriceMaxChanged,
      ),
      const SizedBox(height: 12),
      _buildSectionTitle(context, context.localization.listings_filter_rooms),
      _buildRangeFields(
        context,
        minController: _roomsMinController,
        maxController: _roomsMaxController,
        minHint: filterOptions.roomsMin,
        maxHint: filterOptions.roomsMax,
        onMinChanged: _onRoomsMinChanged,
        onMaxChanged: _onRoomsMaxChanged,
      ),
      const SizedBox(height: 12),
      _buildVerificationSection(context),
      const SizedBox(height: 12),
    ]);

    if (filterOptions.furnishings.isNotEmpty) {
      sections.addAll([
        _buildChoiceGroup(
          context,
          title: context.localization.listings_filter_furnishing,
          choices: filterOptions.furnishings,
          selectedValue: _draft.furnishing,
          onChanged: _onFurnishingChanged,
        ),
        const SizedBox(height: 12),
      ]);
    }

    if (filterOptions.tariffs.isNotEmpty) {
      sections.add(
        _buildChoiceGroup(
          context,
          title: context.localization.listings_filter_tariff,
          choices: filterOptions.tariffs,
          selectedValue: _draft.tariff,
          onChanged: _onTariffChanged,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sections,
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: AppTextStyles.p3Medium.copyWith(
          color: context.currentTheme.textNeutralPrimary,
        ),
      ),
    );
  }

  Widget _buildVerificationSection(BuildContext context) {
    final isChecked = _draft.verified ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(
          context,
          context.localization.listings_filter_verification,
        ),
        InkWell(
          onTap: () => _onVerifiedChanged(isChecked ? null : true),
          borderRadius: BorderRadius.circular(AppRadius.input),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
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
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.localization.listings_chip_verified,
                    style: AppTextStyles.p3Medium.copyWith(
                      color: context.currentTheme.textNeutralPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistrictDropdown(
    BuildContext context,
    List<ListingDistrict> districts,
  ) {
    final selectedDistrict = districts
        .where((district) => district.id == _draft.districtId)
        .firstOrNull;

    final query = _districtSearchController.text.trim().toLowerCase();
    final filteredDistricts =
        (query.isEmpty
                ? districts
                : districts.where((d) => d.name.toLowerCase().contains(query)))
            .take(3)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isDistrictDropdownOpen = !_isDistrictDropdownOpen;
              if (_isDistrictDropdownOpen) {
                Future.microtask(() {
                  if (mounted) {
                    _districtSearchFocusNode.requestFocus();
                  }
                });
              }
            });
          },
          borderRadius: BorderRadius.circular(AppRadius.input),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: context.currentTheme.bgSurfaceBase2,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(
                color: _isDistrictDropdownOpen
                    ? context.currentTheme.strokeBrandHover
                    : context.currentTheme.strokeNeutralLight100,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDistrict?.name ??
                        context.localization.listings_select_district,
                    style: AppTextStyles.p3Regular.copyWith(
                      color: selectedDistrict != null
                          ? context.currentTheme.textNeutralPrimary
                          : context.currentTheme.textNeutralDisable,
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
                        color: context.currentTheme.iconNeutralDefault,
                      ),
                    ),
                  ),
                Icon(
                  _isDistrictDropdownOpen
                      ? TablerIcons.chevron_up
                      : TablerIcons.chevron_down,
                  size: 18,
                  color: context.currentTheme.iconNeutralDefault,
                ),
              ],
            ),
          ),
        ),
        if (_isDistrictDropdownOpen) ...[
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: context.currentTheme.bgSurfaceBase2,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(
                color: context.currentTheme.strokeNeutralLight200,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _districtSearchController,
                  focusNode: _districtSearchFocusNode,
                  style: AppTextStyles.p3Regular.copyWith(
                    color: context.currentTheme.textNeutralPrimary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: context.localization.listings_search_district,
                    hintStyle: AppTextStyles.p3Regular.copyWith(
                      color: context.currentTheme.textNeutralDisable,
                    ),
                    prefixIcon: Icon(
                      TablerIcons.search,
                      size: 18,
                      color: context.currentTheme.iconNeutralDefault,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    suffixIcon: _districtSearchController.text.isNotEmpty
                        ? GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                _districtSearchController.clear();
                              });
                            },
                            child: Icon(
                              TablerIcons.x,
                              size: 16,
                              color: context.currentTheme.iconNeutralDefault,
                            ),
                          )
                        : null,
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    filled: true,
                    fillColor: context.currentTheme.bgSurfaceSheet,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppRadius.input / 1.5,
                      ),
                      borderSide: BorderSide(
                        color: context.currentTheme.strokeNeutralLight100,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppRadius.input / 1.5,
                      ),
                      borderSide: BorderSide(
                        color: context.currentTheme.strokeNeutralLight100,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppRadius.input / 1.5,
                      ),
                      borderSide: BorderSide(
                        color: context.currentTheme.strokeBrandHover,
                      ),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 6),
                if (filteredDistricts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        context.localization.listings_no_districts_found,
                        style: AppTextStyles.p3Regular.copyWith(
                          color: context.currentTheme.textNeutralSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  ...filteredDistricts.map((district) {
                    final isSelected = _draft.districtId == district.id;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _draft = isSelected
                                ? _draft.copyWith(clearDistrictId: true)
                                : _draft.copyWith(districtId: district.id);
                            _isDistrictDropdownOpen = false;
                            _districtSearchController.clear();
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.currentTheme.bgBrandLight100
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  district.name,
                                  style: AppTextStyles.p3Medium.copyWith(
                                    color: isSelected
                                        ? context.currentTheme.textBrandPrimary
                                        : context
                                              .currentTheme
                                              .textNeutralPrimary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  TablerIcons.check,
                                  size: 16,
                                  color: context.currentTheme.iconBrandPrimary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ],
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

  Widget _buildChoiceGroup(
    BuildContext context, {
    required String title,
    required List<ListingChoice> choices,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(context, title),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...choices.map(
              (choice) => _buildChoice(
                context,
                label: choice.label,
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
    required bool selected,
    required VoidCallback onTap,
  }) {
    final foregroundColor = selected
        ? context.currentTheme.textBrandPrimary
        : context.currentTheme.textNeutralPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? context.currentTheme.bgBrandLight100
                : context.currentTheme.bgSurfaceBase2,
            border: Border.all(
              color: selected
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

  void _onPriceMinChanged(String value) {
    _updateDraft(
      value.isEmpty
          ? _draft.copyWith(clearPriceMin: true)
          : _draft.copyWith(priceMin: double.tryParse(value)),
    );
  }

  void _onPriceMaxChanged(String value) {
    _updateDraft(
      value.isEmpty
          ? _draft.copyWith(clearPriceMax: true)
          : _draft.copyWith(priceMax: double.tryParse(value)),
    );
  }

  void _onRoomsMinChanged(String value) {
    _updateDraft(
      value.isEmpty
          ? _draft.copyWith(clearRoomsMin: true)
          : _draft.copyWith(roomsMin: int.tryParse(value)),
    );
  }

  void _onRoomsMaxChanged(String value) {
    _updateDraft(
      value.isEmpty
          ? _draft.copyWith(clearRoomsMax: true)
          : _draft.copyWith(roomsMax: int.tryParse(value)),
    );
  }

  void _onFurnishingChanged(String? value) {
    setState(() {
      _draft = value == null
          ? _draft.copyWith(clearFurnishing: true)
          : _draft.copyWith(furnishing: value);
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

  void _updateDraft(ListingFilters updated) {
    setState(() {
      _draft = updated;
    });
  }

  void _clearDraft() {
    setState(() {
      _draft = const ListingFilters.empty();
      _priceMinController.clear();
      _priceMaxController.clear();
      _roomsMinController.clear();
      _roomsMaxController.clear();
      _districtSearchController.clear();
      _isDistrictDropdownOpen = false;
    });
  }

  void _applyDraft() {
    var normalized = _draft;
    if (normalized.priceMin != null &&
        normalized.priceMax != null &&
        normalized.priceMin! > normalized.priceMax!) {
      normalized = normalized.copyWith(
        priceMin: normalized.priceMax,
        priceMax: normalized.priceMin,
      );
    }
    if (normalized.roomsMin != null &&
        normalized.roomsMax != null &&
        normalized.roomsMin! > normalized.roomsMax!) {
      normalized = normalized.copyWith(
        roomsMin: normalized.roomsMax,
        roomsMax: normalized.roomsMin,
      );
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
