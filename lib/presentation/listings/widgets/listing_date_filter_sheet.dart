import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_bloc.dart';
import 'package:ideal_mobile/presentation/listings/bloc/listings_event.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/listings/widgets/listing_date_filter_field.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

/// Opens the standalone availability date-filter sheet.
///
/// Returns the updated [ListingFilters] (or `null` when the user dismissed the
/// sheet without applying). When [applyToListingsBloc] is true the caller's
/// [ListingsBloc] is updated with the result, leaving active filters untouched
/// on cancel.
Future<ListingFilters?> showListingDateFilterSheet(
  BuildContext context, {
  ListingFilters? initialFilters,
  bool applyToListingsBloc = true,
}) async {
  final bloc = applyToListingsBloc ? context.read<ListingsBloc>() : null;
  final currentFilters = initialFilters ?? bloc?.state.filters;
  assert(currentFilters != null);

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
      initialChildSize: 0.7,
      minChildSize: 0.45,
      maxChildSize: 0.9,
      builder: (context, scrollController) => ListingDateFilterSheet(
        initialFilters: currentFilters!,
        scrollController: scrollController,
      ),
    ),
  );

  if (result != null && bloc != null && result != bloc.state.filters) {
    bloc.add(ApplyListingFiltersEvent(result));
  }
  return result;
}

class ListingDateFilterSheet extends StatefulWidget {
  const ListingDateFilterSheet({
    super.key,
    required this.initialFilters,
    this.scrollController,
  });

  final ListingFilters initialFilters;
  final ScrollController? scrollController;

  @override
  State<ListingDateFilterSheet> createState() => _ListingDateFilterSheetState();
}

class _ListingDateFilterSheetState extends State<ListingDateFilterSheet> {
  late ListingFilters _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialFilters;
  }

  int get _initialFlexibility => _draft.flexibilityDays ?? 3;

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

  void _clearDates() {
    setState(() {
      _draft = _draft.copyWith(clearDates: true);
    });
    Navigator.of(context).pop(_draft);
  }

  void _apply() => Navigator.of(context).pop(_draft);

  void _cancel() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    return SafeArea(
      top: false,
      child: Column(
        key: keys.dateFilter.sheet,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            decoration: BoxDecoration(
              color: theme.strokeNeutralLight200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        context.localization.listings_date_filter_title,
                        style: AppTextStyles.h3Medium.copyWith(
                          color: theme.textNeutralPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      key: keys.dateFilter.cancel,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(TablerIcons.x, size: 18),
                      color: theme.iconNeutralDefault,
                      onPressed: _cancel,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListingDateFilterField(
                  key: ValueKey(_draft.hasDateRange),
                  initialStartDate: _draft.startDate,
                  initialEndDate: _draft.endDate,
                  initialFlexibilityDays: _initialFlexibility,
                  onChanged: _onDatesChanged,
                ),
              ],
            ),
          ),
          Container(
            key: const Key('listingDateFilterSheetFooter'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: theme.bgSurfaceSheet,
              border: Border(
                top: BorderSide(color: theme.strokeNeutralLight200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    key: const Key('listingDateFilterSheetClear'),
                    style: AppButtonStyle.outline,
                    size: AppButtonSize.medium,
                    label: context.localization.listings_clear_dates,
                    foregroundColor: theme.textNeutralPrimary,
                    backgroundColor: theme.bgSurfaceBase2,
                    borderColor: theme.strokeNeutralLight200,
                    shouldSetFullWidth: true,
                    onPressed: _clearDates,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    key: const Key('listingDateFilterSheetApply'),
                    size: AppButtonSize.medium,
                    label: context.localization.listings_apply,
                    foregroundColor: theme.textNeutralWhite,
                    backgroundColor: theme.bgBrandDefault,
                    shouldSetFullWidth: true,
                    onPressed: _apply,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
