import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

Future<String?> showTariffFilterSheet(
  BuildContext context, {
  String? selectedTariff,
}) {
  return showModalBottomSheet<String?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.currentTheme.bgSurfaceSheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (sheetContext) => TariffFilterSheet(
      initialTariff: selectedTariff,
      onTariffSelected: (tariff) => Navigator.of(sheetContext).pop(tariff),
    ),
  );
}

class TariffFilterSheet extends StatefulWidget {
  const TariffFilterSheet({
    super.key,
    this.initialTariff,
    required this.onTariffSelected,
  });

  final String? initialTariff;
  final ValueChanged<String?> onTariffSelected;

  @override
  State<TariffFilterSheet> createState() => _TariffFilterSheetState();
}

class _TariffFilterSheetState extends State<TariffFilterSheet> {
  late String? _selected;

  static const _tariffs = ['standard', 'comfort', 'premium'];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialTariff?.toLowerCase();
  }

  String _tariffLabel(BuildContext context, String tariff) {
    switch (tariff.toLowerCase()) {
      case 'comfort':
        return context.localization.listings_tariff_comfort;
      case 'premium':
        return context.localization.listings_tariff_premium;
      case 'standard':
      default:
        return context.localization.listings_tariff_standard;
    }
  }

  void _onOptionTap(String tariff) {
    final next = _selected == tariff ? null : tariff;
    setState(() {
      _selected = next;
    });
    widget.onTariffSelected(next);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.currentTheme.strokeNeutralLight200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.localization.listings_filter_tariff,
                  style: AppTextStyles.h2Bold.copyWith(
                    color: context.currentTheme.textNeutralPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(TablerIcons.x),
                  color: context.currentTheme.iconNeutralDefault,
                  onPressed: () => Navigator.of(context).pop(_selected),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              context.localization.home_tariff_sheet_subtitle,
              style: AppTextStyles.p2Regular.copyWith(
                color: context.currentTheme.textNeutralSecondary,
              ),
            ),
            const SizedBox(height: 18),
            ..._tariffs.map((tariff) {
              final isSelected = _selected == tariff;
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
                    onTap: () => _onOptionTap(tariff),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _tariffLabel(context, tariff),
                            style: AppTextStyles.p1Medium.copyWith(
                              color: isSelected
                                  ? context.currentTheme.textBrandPrimary
                                  : context.currentTheme.textNeutralPrimary,
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
            }),
            const SizedBox(height: 8),
            Text(
              context.localization.home_tariff_sheet_clear_hint,
              textAlign: TextAlign.center,
              style: AppTextStyles.p3Regular.copyWith(
                color: context.currentTheme.textNeutralSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
