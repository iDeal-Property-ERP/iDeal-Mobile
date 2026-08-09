import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ListingDetailSpecChips extends StatelessWidget {
  const ListingDetailSpecChips({super.key, required this.detail});

  final ListingDetail detail;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (detail.rooms != null) {
      chips.add(
        _SpecChip(
          icon: TablerIcons.bed,
          label: context.localization.listings_rooms_count(detail.rooms!),
        ),
      );
    }

    if (detail.areaSqm != null) {
      chips.add(
        _SpecChip(
          icon: TablerIcons.ruler,
          label: context.localization.listings_area_sqm(detail.areaSqm!),
        ),
      );
    }

    if (detail.floor != null) {
      chips.add(
        _SpecChip(
          icon: TablerIcons.stairs,
          label: _floorLabel(context, detail.floor!, detail.totalFloors),
        ),
      );
    }

    if (detail.tariff.trim().isNotEmpty) {
      chips.add(
        _SpecChip(
          icon: TablerIcons.tag,
          label: _tariffLabel(context, detail.tariff),
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  String _floorLabel(BuildContext context, int floor, int? totalFloors) {
    if (totalFloors == null) {
      return context.localization.listings_floor_only(floor);
    }
    return context.localization.listings_floor_of(floor, totalFloors);
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
}

class _SpecChip extends StatelessWidget {
  const _SpecChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.currentTheme.bgNeutralLight100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: context.currentTheme.iconBrandPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.p3SemiBold.copyWith(
                color: context.currentTheme.textNeutralPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
