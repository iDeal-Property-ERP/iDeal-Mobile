import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/map/widgets/providers/google_map_style.dart';

void main() {
  test('uses the native default style in light mode', () {
    expect(googleMapStyleFor(Brightness.light), isNull);
  });

  test('uses valid dark map style JSON in dark mode', () {
    final style = googleMapStyleFor(Brightness.dark);

    expect(style, isNotNull);
    final rules = jsonDecode(style!) as List<dynamic>;
    expect(rules, isNotEmpty);
    expect(
      rules.whereType<Map<String, dynamic>>(),
      contains(
        predicate<Map<String, dynamic>>(
          (rule) =>
              rule['featureType'] == 'water' &&
              rule['elementType'] == 'geometry',
        ),
      ),
    );
  });
}
