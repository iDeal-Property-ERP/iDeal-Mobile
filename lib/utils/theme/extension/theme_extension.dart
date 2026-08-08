import 'package:flutter/material.dart';
import 'package:ideal_mobile/utils/theme/dark_app_colors.dart';
import 'package:ideal_mobile/utils/theme/light_app_colors.dart';
import 'package:ideal_mobile/utils/theme/theme_color_palette.dart';

extension ThemeExtension on BuildContext {
  ThemeColorPalette get currentTheme =>
      Theme.of(this).brightness == .dark ? DarkAppColors() : LightAppColors();

  bool get isDark => Theme.of(this).brightness == .dark;

  T themeAsset<T>({required T light, required T dark}) => isDark ? dark : light;
}
