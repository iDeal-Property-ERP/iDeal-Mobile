import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/routes.dart';
import 'package:ideal_mobile/routes.gr.dart';

void main() {
  group('deep-linked detail routes', () {
    final matcher = AppRouter().matcher;

    test('match their required identifiers from the URL path', () {
      final cases =
          <({String path, String routeName, String parameter, String value})>[
            (
              path: '/listings/41',
              routeName: ListingDetailRoute.name,
              parameter: 'listingId',
              value: '41',
            ),
            (
              path: '/listings/41/booking',
              routeName: BookingRoute.name,
              parameter: 'listingId',
              value: '41',
            ),
            (
              path: '/bookings/82/status',
              routeName: BookingStatusRoute.name,
              parameter: 'bookingId',
              value: '82',
            ),
            (
              path: '/chats/19',
              routeName: ChatConversationRoute.name,
              parameter: 'conversationId',
              value: '19',
            ),
          ];

      for (final route in cases) {
        final match = matcher.match(route.path);
        expect(match, hasLength(1), reason: route.path);
        expect(match!.single.name, route.routeName);
        expect(match.single.pathParams.rawMap[route.parameter], route.value);
      }
    });

    test('static listing map wins before the dynamic listing detail route', () {
      final match = matcher.match('/listings/map');

      expect(match, hasLength(1));
      expect(match!.single.name, ListingDiscoveryMapRoute.name);
    });
  });
}
