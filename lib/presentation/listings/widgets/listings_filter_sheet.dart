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

Future<void> showListingsFilterSheet(BuildContext context) {
  final bloc = context.read<ListingsBloc>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.currentTheme.bgSurfaceSheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (_) => BlocProvider<ListingsBloc>.value(
      value: bloc,
      child: const ListingsFilterSheet(),
    ),
  );
}

class ListingsFilterSheet extends StatefulWidget {
  const ListingsFilterSheet({super.key});

  @override
  State<ListingsFilterSheet> createState() => _ListingsFilterSheetState();
}

class _ListingsFilterSheetState extends State<ListingsFilterSheet> {
  static const _anyDistrictValue = '__any_district__';

  late ListingFilters _draft;
  late final TextEditingController _priceMinController;
  late final TextEditingController _priceMaxController;
  late final TextEditingController _roomsMinController;
  late final TextEditingController _roomsMaxController;

  @override
  void initState() {
    super.initState();
    _draft = context.read<ListingsBloc>().state.filters;
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
  }

  @override
  void dispose() {
    _priceMinController.dispose();
    _priceMaxController.dispose();
    _roomsMinController.dispose();
    _roomsMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterOptions = context.select<ListingsBloc, ListingFilterOptions>(
      (bloc) => bloc.state.filterOptions,
    );
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _buildForm(context, filterOptions),
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
        const SizedBox(height: 20),
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
      const SizedBox(height: 20),
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
      const SizedBox(height: 20),
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
        const SizedBox(height: 20),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.p3Medium.copyWith(
          color: context.currentTheme.textNeutralPrimary,
        ),
      ),
    );
  }

  Widget _buildDistrictDropdown(
    BuildContext context,
    List<ListingDistrict> districts,
  ) {
    final hasSelectedDistrict = districts.any(
      (district) => district.id == _draft.districtId,
    );
    final selectedValue = hasSelectedDistrict
        ? _draft.districtId!.toString()
        : _anyDistrictValue;

    return DropdownButtonFormField<String>(
      value: selectedValue,
      isExpanded: true,
      dropdownColor: context.currentTheme.bgNeutralLight200,
      icon: Icon(
        TablerIcons.chevron_down,
        color: context.currentTheme.iconNeutralDefault,
      ),
      decoration: _fieldDecoration(context, null),
      items: [
        DropdownMenuItem<String>(
          value: _anyDistrictValue,
          child: _dropdownText(context, context.localization.listings_anywhere),
        ),
        ...districts.map(
          (district) => DropdownMenuItem<String>(
            value: district.id.toString(),
            child: _dropdownText(context, district.name),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _draft = value == null || value == _anyDistrictValue
              ? _draft.copyWith(clearDistrictId: true)
              : _draft.copyWith(districtId: int.tryParse(value));
        });
      },
    );
  }

  Widget _dropdownText(BuildContext context, String text) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.p3Regular.copyWith(
        color: context.currentTheme.textNeutralPrimary,
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
      filled: true,
      fillColor: context.currentTheme.bgNeutralLight200,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
            : context.currentTheme.strokeNeutralLight200,
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
            _buildChoice(
              context,
              label: context.localization.listings_any,
              selected: selectedValue == null,
              onTap: () => onChanged(null),
            ),
            ...choices.map(
              (choice) => _buildChoice(
                context,
                label: choice.label,
                selected: selectedValue == choice.value,
                onTap: () => onChanged(choice.value),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? context.currentTheme.bgBrandLight100
                : context.currentTheme.bgNeutralLight200,
            border: Border.all(
              color: selected
                  ? context.currentTheme.iconBrandPrimary
                  : context.currentTheme.strokeNeutralLight200,
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
              style: AppButtonStyle.secondary,
              size: AppButtonSize.medium,
              label: context.localization.listings_clear_all,
              foregroundColor: context.currentTheme.textNeutralPrimary,
              backgroundColor: context.currentTheme.bgNeutralLight200,
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
    context.read<ListingsBloc>().add(ApplyListingFiltersEvent(normalized));
    Navigator.of(context).pop();
  }

  String _formatNumber(num? value) {
    if (value == null) return '';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }
}
