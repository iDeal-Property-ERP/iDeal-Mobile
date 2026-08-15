import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class PropertyMapPin extends StatelessWidget {
  const PropertyMapPin({
    super.key,
    required this.backgroundColor,
    required this.iconColor,
    this.label,
    this.isSelected = false,
  });

  final Color backgroundColor;
  final Color iconColor;
  final String? label;
  final bool isSelected;

  /// Keeps the Yandex view-provider tap target large enough without making
  /// the visible price pill or home glyph unnecessarily large.
  static const double minimumInteractiveDimension = 44;

  @override
  Widget build(BuildContext context) {
    final cleanLabel = label?.trim();
    final hasLabel = cleanLabel != null && cleanLabel.isNotEmpty;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: minimumInteractiveDimension,
        minHeight: minimumInteractiveDimension,
      ),
      child: Center(
        child: DecoratedBox(
          key: const ValueKey('property-map-pin-visual'),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(hasLabel ? 18 : 24),
            border: isSelected ? Border.all(color: iconColor, width: 2) : null,
            boxShadow: const [
              BoxShadow(
                color: Color(0x29000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: hasLabel
                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 7)
                : const EdgeInsets.all(8),
            child: hasLabel
                ? Text(
                    cleanLabel,
                    maxLines: 1,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Icon(TablerIcons.home, size: 18, color: iconColor),
          ),
        ),
      ),
    );
  }
}

class PropertyMapClusterPin extends StatelessWidget {
  const PropertyMapClusterPin({
    super.key,
    required this.count,
    required this.backgroundColor,
    required this.textColor,
  });

  final int count;
  final Color backgroundColor;
  final Color textColor;

  static const double minimumInteractiveDimension = 44;
  static const double visualDimension = 38;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: minimumInteractiveDimension,
      child: Center(
        child: DecoratedBox(
          key: const ValueKey('property-map-cluster-visual'),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: textColor, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x29000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox.square(
            dimension: visualDimension,
            child: Center(
              child: Text(
                '$count',
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
