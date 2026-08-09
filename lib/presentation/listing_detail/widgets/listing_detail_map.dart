import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/presentation/map/widgets/property_map_view.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ListingDetailMap extends StatelessWidget {
  const ListingDetailMap({
    super.key,
    required this.detail,
    required this.onTap,
  });

  final ListingDetail detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final latitude = detail.mapLat;
    final longitude = detail.mapLon;
    if (latitude == null || longitude == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.localization.listing_detail_location,
          style: AppTextStyles.p2SemiBold.copyWith(
            color: context.currentTheme.textNeutralPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Semantics(
          button: true,
          label: context.localization.listing_detail_map_open,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PropertyMapView(
                    markers: [
                      PropertyMapMarker(
                        id: detail.propertyId,
                        latitude: latitude,
                        longitude: longitude,
                        label: detail.title,
                      ),
                    ],
                    initialCamera: CameraTarget(
                      latitude: latitude,
                      longitude: longitude,
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(onTap: onTap),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
