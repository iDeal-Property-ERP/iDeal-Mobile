import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class PropertyMapPin extends StatelessWidget {
  const PropertyMapPin({
    super.key,
    required this.backgroundColor,
    required this.iconColor,
  });

  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(TablerIcons.home, size: 18, color: iconColor),
      ),
    );
  }
}
