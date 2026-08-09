import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

const Map<String, IconData> _amenityIcons = {
  'wifi': TablerIcons.wifi,
  'furnished': TablerIcons.sofa,
  'furniture': TablerIcons.sofa,
  'sofa': TablerIcons.sofa,
  'parking': TablerIcons.parking,
  'car': TablerIcons.car,
  'elevator': TablerIcons.elevator,
  'security': TablerIcons.shield,
  'shield': TablerIcons.shield,
  'air-conditioning': TablerIcons.air_conditioning,
  'air-conditioning-disabled': TablerIcons.air_conditioning_disabled,
  'ac': TablerIcons.air_conditioning,
  'balcony': TablerIcons.home,
  'heating': TablerIcons.flame,
  'heat': TablerIcons.flame,
};

class ListingDetailAmenities extends StatelessWidget {
  const ListingDetailAmenities({super.key, required this.amenities});

  final List<ListingAmenity> amenities;

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.localization.listing_detail_amenities,
          style: AppTextStyles.p2SemiBold.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        const SizedBox(height: 13),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: amenities.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 13,
            mainAxisExtent: 24,
          ),
          itemBuilder: (context, index) => _AmenityRow(
            amenity: amenities[index],
            icon: _iconFor(amenities[index]),
          ),
        ),
      ],
    );
  }

  IconData _iconFor(ListingAmenity amenity) {
    final icon = _amenityIcons[_normalise(amenity.icon)];
    final slug = _amenityIcons[_normalise(amenity.slug)];
    return icon ?? slug ?? TablerIcons.circle_check;
  }

  String _normalise(String? value) {
    return (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('_', '-')
        .replaceAll(' ', '-');
  }
}

class _AmenityRow extends StatelessWidget {
  const _AmenityRow({required this.amenity, required this.icon});

  final ListingAmenity amenity;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.currentTheme.iconBrandPrimary),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            amenity.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.p3Regular.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
