import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/change_theme/widgets/theme_list_options.dart';
import 'package:ideal_mobile/utils/extensions/primitive_types_extensions.dart';
import 'package:ideal_mobile/utils/theme/bloc/theme_bloc.dart';
import 'package:ideal_mobile/utils/theme/bloc/theme_event.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';

@RoutePage()
class ChangeThemeScreen extends StatefulWidget {
  const ChangeThemeScreen({super.key});

  @override
  State<ChangeThemeScreen> createState() => _ChangeThemeScreenState();
}

class _ChangeThemeScreenState extends State<ChangeThemeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar.page(title: context.localization.choose_app_theme),
      body: const _ChangeThemeScreenBody(),
    );
  }
}

class _ChangeThemeScreenBody extends StatelessWidget {
  const _ChangeThemeScreenBody();

  @override
  Widget build(BuildContext context) {
    final selectedThemeMode = context.select<ThemeBloc, ThemeMode?>(
      (bloc) => bloc.state.themeMode,
    );

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: ThemeMode.values.map((themeMode) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ThemeListOptions(
                themeMode: themeMode.name.toLowerCase().capitalizeFirst,
                isSelected: selectedThemeMode == themeMode,
                onSelected: () => context.read<ThemeBloc>().add(
                  SetThemeModeEvent(mode: themeMode),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
