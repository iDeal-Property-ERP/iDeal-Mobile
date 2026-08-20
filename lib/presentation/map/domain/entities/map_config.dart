import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';

class PropertyMapConfig extends Equatable {
  const PropertyMapConfig({
    required this.provider,
    required this.token,
    required this.fetchedAt,
  });

  final PropertyMapProvider provider;
  final String token;
  final DateTime fetchedAt;

  bool isExpired({Duration ttl = const Duration(hours: 24)}) {
    return DateTime.now().difference(fetchedAt) > ttl;
  }

  @override
  List<Object?> get props => [provider, token, fetchedAt];
}
