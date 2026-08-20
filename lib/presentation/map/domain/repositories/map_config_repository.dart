// ignore_for_file: one_member_abstracts

import 'package:ideal_mobile/presentation/map/domain/entities/map_config.dart';

abstract interface class MapConfigRepository {
  Future<PropertyMapConfig> getMapConfig({bool forceRefresh = false});
}
