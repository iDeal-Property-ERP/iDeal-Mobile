// ignore_for_file: one_member_abstracts

import 'package:dio/dio.dart';
import 'package:ideal_mobile/presentation/listing_map/domain/entities/listing_map_result.dart';
import 'package:ideal_mobile/presentation/listings/domain/entities/listing_filters.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
import 'package:ideal_mobile/utils/typedef.dart';

abstract class ListingMapRepository {
  ResultFuture<ListingMapResult> getListings({
    required PropertyMapBounds bounds,
    required ListingFilters filters,
    CancelToken? cancelToken,
  });
}
