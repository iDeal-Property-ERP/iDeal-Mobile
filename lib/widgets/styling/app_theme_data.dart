import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

enum AppThemeEnum { DarkTheme, LightTheme }

class AppThemesData {
  static final Map<AppThemeEnum, ThemeData> themeData =
      <AppThemeEnum, ThemeData>{
        AppThemeEnum.LightTheme: ThemeData(
          splashFactory: NoSplash.splashFactory,
          useMaterial3: false,
          brightness: .light,
          primaryColor: AppColors.brand600,
          primarySwatch: AppColors.primarySwatches,
          colorScheme: const ColorScheme.light(
            primary: AppColors.brand600,
            secondary: AppColors.brand500,
            error: AppColors.redError600,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppColors.bgSurfaceBase,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          scaffoldBackgroundColor: AppColors.bgSurfaceBase,
          canvasColor: AppColors.bgSurfaceBase,
          cardColor: AppColors.bgSurfaceBase2,
          dialogBackgroundColor: AppColors.bgSurfaceBase2,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
          ),
          cardTheme: CardThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.dialog),
            ),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.sheet),
              ),
            ),
          ),
          bottomAppBarTheme: const BottomAppBarThemeData(
            color: AppColors.bottomAppBarColorLight,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppColors.bottomAppBarColorLight,
            selectedItemColor: AppColors.brand600,
          ),
        ),
        AppThemeEnum.DarkTheme: ThemeData(
          splashFactory: NoSplash.splashFactory,
          brightness: .dark,
          useMaterial3: false,
          primaryColor: AppColors.brand600,
          primarySwatch: AppColors.primarySwatches,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.brand600,
            secondary: AppColors.brand500,
            surface: AppColors.black,
            error: AppColors.redError500,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppColors.black,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          scaffoldBackgroundColor: AppColors.black,
          canvasColor: AppColors.black,
          cardColor: AppColors.bgSurfaceBase2dark,
          dialogBackgroundColor: AppColors.bgSurfaceBase2dark,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
          ),
          cardTheme: CardThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.dialog),
            ),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.sheet),
              ),
            ),
          ),
          bottomAppBarTheme: const BottomAppBarThemeData(
            color: AppColors.bottomAppBarColorDark,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppColors.bottomAppBarColorDark,
            selectedItemColor: AppColors.brand600,
          ),
        ),
      };
}
