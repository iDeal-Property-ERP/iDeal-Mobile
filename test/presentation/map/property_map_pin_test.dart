import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/map/widgets/property_map_pin.dart';

void main() {
  testWidgets('price and icon pins keep a 44 logical pixel tap target', (
    tester,
  ) async {
    for (final label in <String?>[r'$500', null]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: PropertyMapPin(
              backgroundColor: Colors.white,
              iconColor: Colors.black,
              label: label,
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(PropertyMapPin));
      expect(size.width, greaterThanOrEqualTo(44));
      expect(size.height, greaterThanOrEqualTo(44));
      expect(
        tester
            .getSize(find.byKey(const ValueKey('property-map-pin-visual')))
            .height,
        lessThan(44),
      );
    }
  });

  testWidgets('cluster keeps a compact visual inside a 44 pixel tap target', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: PropertyMapClusterPin(
            count: 12,
            backgroundColor: Colors.white,
            textColor: Colors.black,
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(PropertyMapClusterPin)),
      const Size(44, 44),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('property-map-cluster-visual'))),
      const Size(38, 38),
    );
  });
}
