import 'package:flutter/material.dart';

/// Local style used by the native Google map when the app is in dark mode.
/// A null light style restores Google's default map styling.
const String googleMapDarkStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1d1f22"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#aeb4be"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1d1f22"}]},
  {"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#555c66"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#24272c"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1f3429"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#343941"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#20242a"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#4a4f57"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2b2f35"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#142a3a"}]}
]
''';

String? googleMapStyleFor(Brightness brightness) =>
    brightness == Brightness.dark ? googleMapDarkStyle : null;
