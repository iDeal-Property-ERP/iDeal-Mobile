import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/presentation/home/widgets/home_banner_carousel.dart';
import 'package:ideal_mobile/utils/typedef.dart';

/// Data model for home promotional banners parsed from backend API.
class HomeBannerModel extends HomeBannerItem {
  const HomeBannerModel({
    required super.title,
    required super.description,
    required super.icon,
    super.id,
    super.tag,
    super.sortOrder,
  });

  factory HomeBannerModel.fromJson(DataMap json) {
    final id = json['id'] as int?;
    final title = (json['title'] ?? '') as String;
    final description = (json['description'] ?? '') as String;
    final tag = json['tag'] as String?;
    final sortOrder = json['sort_order'] as int?;
    final rawIcon = (json['icon'] ?? '') as String;

    return HomeBannerModel(
      id: id,
      title: title,
      description: description,
      icon: resolveIcon(rawIcon),
      tag: tag,
      sortOrder: sortOrder,
    );
  }

  static IconData resolveIcon(String iconName) {
    switch (iconName.toLowerCase().trim()) {
      case 'circle_check':
        return TablerIcons.circle_check;
      case 'shield_check':
        return TablerIcons.shield_check;
      case 'calendar_event':
        return TablerIcons.calendar_event;
      case 'file_certificate':
        return TablerIcons.file_certificate;
      case 'sparkles':
        return TablerIcons.sparkles;
      default:
        return TablerIcons.circle_check;
    }
  }
}
