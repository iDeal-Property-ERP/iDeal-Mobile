import 'package:geolocator/geolocator.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';

// This one-method interface keeps device location injectable in widget tests.
// ignore: one_member_abstracts
abstract interface class PropertyMapLocationService {
  Future<PropertyMapCoordinate?> getCurrentLocation();
}

class GeolocatorPropertyMapLocationService
    implements PropertyMapLocationService {
  const GeolocatorPropertyMapLocationService();

  @override
  Future<PropertyMapCoordinate?> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return PropertyMapCoordinate(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
