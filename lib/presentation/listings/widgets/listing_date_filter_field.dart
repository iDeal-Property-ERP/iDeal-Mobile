import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/constants/integration_test_keys.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/utils/date_time_picker_util.dart';
import 'package:ideal_mobile/utils/extensions/date_time_extensions.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

/// Reusable availability control used by both the standalone date-filter sheet
/// and the full listing filter sheet.
///
/// It owns a local draft of the selected date range and flexibility and reports
/// every change back through [onChanged] so any host (either sheet) can keep a
/// single source of truth in sync.
class ListingDateFilterField extends StatefulWidget {
  const ListingDateFilterField({
    required this.initialStartDate,
    required this.initialEndDate,
    required this.initialFlexibilityDays,
    required this.onChanged,
    super.key,
  });

  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final int initialFlexibilityDays;
  final void Function(
    DateTime? startDate,
    DateTime? endDate,
    int flexibilityDays,
  )
  onChanged;

  @override
  State<ListingDateFilterField> createState() => _ListingDateFilterFieldState();
}

class _ListingDateFilterFieldState extends State<ListingDateFilterField> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late int _flexibilityDays;

  bool get _hasRange => _startDate != null && _endDate != null;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _flexibilityDays = widget.initialFlexibilityDays;
  }

  void _emit() {
    widget.onChanged(_startDate, _endDate, _flexibilityDays);
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final initialRange = _hasRange
        ? DateTimeRange(start: _startDate!, end: _endDate!)
        : null;

    await DateTimePickerUtil.showRangeDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      initialRange: initialRange,
      helpText: context.localization.listings_date_filter_title,
      onRangeSelected: (range) {
        setState(() {
          _startDate = range.start;
          _endDate = range.end;
          if (_flexibilityDays < 0) _flexibilityDays = kDefaultFlexibilityDays;
        });
        _emit();
      },
    );
  }

  void _changeFlexibility(int delta) {
    final next = (_flexibilityDays + delta).clamp(0, kMaxFlexibilityDays);
    if (next == _flexibilityDays) return;
    setState(() => _flexibilityDays = next);
    _emit();
  }

  void _clearDates() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _flexibilityDays = kDefaultFlexibilityDays;
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    final rangeText = _hasRange
        ? context.localization.listings_date_range(
            _startDate!.format(pattern: 'd MMM'),
            _endDate!.format(pattern: 'd MMM'),
          )
        : context.localization.listings_select_dates;

    return Container(
      key: keys.dateFilter.field,
      decoration: BoxDecoration(
        color: theme.bgSurfaceBase2,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(
          color: _hasRange
              ? theme.strokeBrandHover
              : theme.strokeNeutralLight100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _pickRange(context),
              borderRadius: BorderRadius.circular(AppRadius.input),
              child: Container(
                key: keys.dateFilter.rangeSelector,
                constraints: const BoxConstraints(minHeight: 46),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(
                      TablerIcons.calendar,
                      size: 18,
                      color: _hasRange
                          ? theme.iconBrandPrimary
                          : theme.iconNeutralDefault,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rangeText,
                        style: AppTextStyles.p3Regular.copyWith(
                          color: _hasRange
                              ? theme.textNeutralPrimary
                              : theme.textNeutralDisable,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_hasRange)
                      GestureDetector(
                        key: keys.dateFilter.clearDates,
                        behavior: HitTestBehavior.opaque,
                        onTap: _clearDates,
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
          ),
          Divider(height: 1, thickness: 1, color: theme.strokeNeutralLight100),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.localization.listings_flexibility,
                    style: AppTextStyles.p3Medium.copyWith(
                      color: theme.textNeutralPrimary,
                    ),
                  ),
                ),
                IconButton(
                  key: keys.dateFilter.flexibilityDecrease,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: _flexibilityDays > 0
                      ? () => _changeFlexibility(-1)
                      : null,
                  icon: Icon(
                    TablerIcons.minus,
                    size: 16,
                    color: _flexibilityDays > 0
                        ? theme.iconBrandPrimary
                        : theme.iconNeutralDisabled,
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    key: keys.dateFilter.flexibilityValue,
                    context.localization.listings_flexibility_days(
                      _flexibilityDays,
                    ),
                    style: AppTextStyles.p3Medium.copyWith(
                      color: theme.textNeutralPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  key: keys.dateFilter.flexibilityIncrease,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: _flexibilityDays < kMaxFlexibilityDays
                      ? () => _changeFlexibility(1)
                      : null,
                  icon: Icon(
                    TablerIcons.plus,
                    size: 16,
                    color: _flexibilityDays < kMaxFlexibilityDays
                        ? theme.iconBrandPrimary
                        : theme.iconNeutralDisabled,
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
