import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class MapConfigResponseModel {
  const MapConfigResponseModel({required this.provider, required this.token});

  factory MapConfigResponseModel.fromJson(DataMap json) {
    final data = _mapValue(json['data']) ?? json;
    final providerStr =
        (data['provider'] as String?)?.toLowerCase().trim() ?? '';
    final provider = providerStr == 'google'
        ? PropertyMapProvider.google
        : PropertyMapProvider.yandex;

    final token = (data['token'] as String?)?.trim() ?? '';

    return MapConfigResponseModel(provider: provider, token: token);
  }

  final PropertyMapProvider provider;
  final String token;
}

DataMap? _mapValue(dynamic value) {
  if (value is! Map) return null;
  return Map<String, dynamic>.from(value);
}
