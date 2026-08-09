import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/presentation/listing_detail/domain/entities/listing_detail.dart';
import 'package:ideal_mobile/presentation/map/widgets/property_map_view.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ListingMapScreen extends StatelessWidget {
  const ListingMapScreen({super.key, required this.detail});

  final ListingDetail detail;

  @override
  Widget build(BuildContext context) {
    final latitude = detail.mapLat;
    final longitude = detail.mapLon;
    if (latitude == null || longitude == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: context.currentTheme.bgSurfaceBase,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            PropertyMapView(
              interactive: true,
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
            Positioned(
              top: 12,
              left: 16,
              child: Semantics(
                button: true,
                label: MaterialLocalizations.of(context).closeButtonLabel,
                child: Material(
                  color: context.currentTheme.bgSurfaceBase.withValues(
                    alpha: 0.9,
                  ),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(TablerIcons.x, size: 20),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              left: 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.currentTheme.bgSurfaceBase,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.p2SemiBold.copyWith(
                          color: context.currentTheme.textNeutralPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.p3Regular.copyWith(
                          color: context.currentTheme.textNeutralSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
