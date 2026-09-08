import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/map/services/property_map_location_service.dart';
import 'package:ideal_mobile/presentation/map/widgets/property_map_view.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_top_bar/app_top_bar.dart';

@RoutePage()
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    super.key,
    this.initialCoordinate,
    this.locationService,
    this.providerSelector,
    this.providerViewBuilder,
  });

  final PropertyMapCoordinate? initialCoordinate;

  @visibleForTesting
  final PropertyMapLocationService? locationService;

  @visibleForTesting
  final PropertyMapProviderSelector? providerSelector;

  @visibleForTesting
  final PropertyMapProviderViewBuilder? providerViewBuilder;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const _tashkentDefault = PropertyMapCoordinate(
    latitude: 41.311081,
    longitude: 69.240562,
  );

  late PropertyMapCoordinate _currentCoordinate;
  late final PropertyMapController _mapController;
  late final PropertyMapLocationService _locationService;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _currentCoordinate = widget.initialCoordinate ?? _tashkentDefault;
    _mapController = PropertyMapController();
    _locationService =
        widget.locationService ?? const GeolocatorPropertyMapLocationService();
  }

  Future<void> _handleMyLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

    try {
      final loc = await _locationService.getCurrentLocation();
      if (!mounted) return;
      if (loc != null) {
        setState(() => _currentCoordinate = loc);
        await _mapController.moveCamera(
          CameraTarget(
            latitude: loc.latitude,
            longitude: loc.longitude,
            zoom: 16,
          ),
        );
      } else {
        context.showSnackBar(
          context.localization.listing_map_location_unavailable,
          isDisplayingError: true,
        );
      }
    } catch (_) {
      if (mounted) {
        context.showSnackBar(
          context.localization.listing_map_location_unavailable,
          isDisplayingError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;

    return Scaffold(
      backgroundColor: theme.bgSurfaceBase,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Interactive Map
            PropertyMapView(
              key: const ValueKey('location-picker-map'),
              interactive: true,
              markers: const [],
              controller: _mapController,
              providerSelector: widget.providerSelector,
              providerViewBuilder: widget.providerViewBuilder,
              initialCamera: CameraTarget(
                latitude: _currentCoordinate.latitude,
                longitude: _currentCoordinate.longitude,
              ),
              onCameraMove: (cameraState) {
                setState(() {
                  _currentCoordinate = cameraState.target;
                });
              },
              onCameraSettled: (idleState) {
                setState(() {
                  _currentCoordinate = idleState.bounds.center;
                });
              },
              onMapTap: (coord) {
                setState(() {
                  _currentCoordinate = coord;
                });
                _mapController.moveCamera(
                  CameraTarget(
                    latitude: coord.latitude,
                    longitude: coord.longitude,
                  ),
                );
              },
            ),

            // Fixed Center Crosshair / Pin Marker
            Center(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.bgBrandDefault,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            TablerIcons.map_pin_filled,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Top Header Overlay
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  AppTopBarAction(
                    icon: TablerIcons.chevron_left,
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                    style: AppTopBarActionStyle.overlay,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.bgSurfaceBase,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        context.localization.list_property_pick_location_title,
                        style: AppTextStyles.p2SemiBold.copyWith(
                          color: theme.textNeutralPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating My Location Button
            Positioned(
              right: 16,
              bottom: 180,
              child: Material(
                color: theme.bgSurfaceBase,
                shape: const CircleBorder(),
                elevation: 4,
                shadowColor: const Color(0x33000000),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _isLocating ? null : _handleMyLocation,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _isLocating
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.bgBrandDefault,
                            ),
                          )
                        : Icon(
                            TablerIcons.current_location,
                            size: 22,
                            color: theme.textNeutralPrimary,
                          ),
                  ),
                ),
              ),
            ),

            // Bottom Confirmation Panel
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.bgSurfaceBase,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x29000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          TablerIcons.map_pin,
                          size: 18,
                          color: theme.textBrandPrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.localization.list_property_drag_map_hint,
                            style: AppTextStyles.p3Regular.copyWith(
                              color: theme.textNeutralSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.bgSurfaceBase2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_currentCoordinate.latitude.toStringAsFixed(6)}, '
                        '${_currentCoordinate.longitude.toStringAsFixed(6)}',
                        style: AppTextStyles.p3Medium.copyWith(
                          color: theme.textNeutralPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppButton(
                      label:
                          context.localization.list_property_confirm_location,
                      size: AppButtonSize.large,
                      shouldSetFullWidth: true,
                      onPressed: () {
                        Navigator.of(context).pop(_currentCoordinate);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
