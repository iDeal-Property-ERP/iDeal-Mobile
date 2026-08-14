import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/presentation/settings/widgets/settings.dart';
import 'package:ideal_mobile/presentation/settings/widgets/settings_appbar.dart';
import 'package:ideal_mobile/utils/theme/bloc/theme_bloc.dart';
import 'package:ideal_mobile/utils/theme/bloc/theme_state.dart';

@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsScreenBody();
  }
}

class SettingsScreenBody extends StatelessWidget {
  const SettingsScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SettingsAppbar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return const Column(
              children: [
                SizedBox(height: 16.0),
                Expanded(child: Settings()),
                SizedBox(height: 48.0),
              ],
            );
          },
        ),
      ),
    );
  }
}
