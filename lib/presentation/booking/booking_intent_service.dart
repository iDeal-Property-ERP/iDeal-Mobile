import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';

class BookingIntentService {
  const BookingIntentService._();

  static const _listingIdKey = 'booking.pending_listing_id';

  static Future<void> save(int listingId) =>
      Prefs.setInt(_listingIdKey, listingId);

  static Future<int?> consume() async {
    final listingId = await Prefs.getInt(_listingIdKey);
    if (listingId != null) await Prefs.remove(_listingIdKey);
    return listingId;
  }

  static Future<bool> resumeAfterAuthentication(
    BuildContext context, {
    bool replaceAll = true,
  }) async {
    final listingId = await consume();
    if (listingId == null || !context.mounted) return false;
    final routes = <PageRouteInfo>[
      const HomeRoute(),
      BookingRoute(listingId: listingId),
    ];
    if (replaceAll) {
      await context.router.replaceAll(routes);
    } else {
      await context.router.push(BookingRoute(listingId: listingId));
    }
    return true;
  }
}
