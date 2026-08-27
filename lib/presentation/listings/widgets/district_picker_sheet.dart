import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filter_options.dart';
import 'package:ideal_mobile/utils/haptic_feedback_util.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/utils/theme/theme_color_palette.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

class DistrictPickerResult {
  const DistrictPickerResult(this.districtId);

  final int? districtId;
}

Future<DistrictPickerResult?> showDistrictPickerSheet(
  BuildContext context, {
  required List<ListingDistrict> districts,
  int? selectedDistrictId,
}) {
  return showModalBottomSheet<DistrictPickerResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.currentTheme.bgSurfaceSheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (sheetContext) => DistrictPickerSheet(
      districts: districts,
      selectedDistrictId: selectedDistrictId,
    ),
  );
}

class DistrictPickerSheet extends StatefulWidget {
  const DistrictPickerSheet({
    super.key,
    required this.districts,
    this.selectedDistrictId,
  });

  final List<ListingDistrict> districts;
  final int? selectedDistrictId;

  @override
  State<DistrictPickerSheet> createState() => _DistrictPickerSheetState();
}

class _DistrictPickerSheetState extends State<DistrictPickerSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final filteredDistricts = widget.districts.where((district) {
      if (_query.isEmpty) return true;
      return district.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDragHandle(theme),
              _buildHeader(context, theme),
              _buildSearchBar(context, theme),
              const SizedBox(height: 8),
              Flexible(
                child: filteredDistricts.isEmpty
                    ? _buildEmptyState(context, theme)
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: filteredDistricts.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            final isAllSelected =
                                widget.selectedDistrictId == null;
                            return _buildDistrictItem(
                              context,
                              theme: theme,
                              title: context.localization.listings_rooms_any,
                              subtitle:
                                  context.localization.listings_all_filters,
                              isSelected: isAllSelected,
                              onTap: () async {
                                await HapticFeedbackUtil.light();
                                if (context.mounted) {
                                  Navigator.of(
                                    context,
                                  ).pop(const DistrictPickerResult(null));
                                }
                              },
                            );
                          }

                          final district = filteredDistricts[index - 1];
                          final isSelected =
                              district.id == widget.selectedDistrictId;

                          return _buildDistrictItem(
                            context,
                            theme: theme,
                            title: district.name,
                            isSelected: isSelected,
                            onTap: () async {
                              await HapticFeedbackUtil.light();
                              if (context.mounted) {
                                Navigator.of(
                                  context,
                                ).pop(DistrictPickerResult(district.id));
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle(ThemeColorPalette theme) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: theme.strokeNeutralLight200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeColorPalette theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Icon(TablerIcons.map_pin, size: 20, color: theme.iconNeutralDefault),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.localization.listings_filter_district,
              style: AppTextStyles.h6Bold.copyWith(
                color: theme.textNeutralPrimary,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              TablerIcons.x,
              size: 20,
              color: theme.iconNeutralDefault,
            ),
            onPressed: () => Navigator.of(context).pop(),
            visualDensity: VisualDensity.compact,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeColorPalette theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.p3Regular.copyWith(
          color: theme.textNeutralPrimary,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: context.localization.listings_search_district,
          hintStyle: AppTextStyles.p3Regular.copyWith(
            color: theme.textNeutralDisable,
          ),
          prefixIcon: Icon(
            TablerIcons.search,
            size: 18,
            color: theme.iconNeutralDefault,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          suffixIcon: _query.isNotEmpty
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _query = '';
                    });
                  },
                  child: Icon(
                    TablerIcons.x,
                    size: 16,
                    color: theme.iconNeutralDefault,
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 36,
          ),
          filled: true,
          fillColor: theme.bgSurfaceBase2,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: BorderSide(color: theme.strokeNeutralLight100),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: BorderSide(color: theme.strokeNeutralLight100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: BorderSide(color: theme.strokeBrandHover),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _query = value.trim();
          });
        },
      ),
    );
  }

  Widget _buildDistrictItem(
    BuildContext context, {
    required ThemeColorPalette theme,
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.bgBrandLight100 : theme.bgSurfaceBase2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? theme.strokeBrandHover
                  : theme.strokeNeutralLight100,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                TablerIcons.map_pin,
                size: 18,
                color: isSelected
                    ? theme.iconBrandPrimary
                    : theme.iconNeutralDefault,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.p3Medium.copyWith(
                        color: isSelected
                            ? theme.textBrandPrimary
                            : theme.textNeutralPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.p4Regular.copyWith(
                          color: theme.textNeutralSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  TablerIcons.check,
                  size: 18,
                  color: theme.iconBrandPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeColorPalette theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              TablerIcons.search_off,
              size: 36,
              color: theme.iconNeutralDisabled,
            ),
            const SizedBox(height: 8),
            Text(
              context.localization.listings_no_districts_found,
              style: AppTextStyles.p3Regular.copyWith(
                color: theme.textNeutralSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
