import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class PersonalDetails extends StatelessWidget {
  const PersonalDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          tileColor: context.currentTheme.bgSurfaceBase2,
          leading: Icon(
            TablerIcons.user_circle,
            color: context.currentTheme.iconNeutralDefault,
          ),
          title: Text(
            context.localization.personal_details,
            style: AppTextStyles.h6SemiBold.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
          ),
          trailing: Icon(
            TablerIcons.chevron_right,
            color: context.currentTheme.iconNeutralDefault,
          ),
          onTap: () {
            final profileBloc = context.read<ProfileBloc>();
            if (profileBloc.state.profile == null) {
              context.showSnackBar(
                context.localization.user_info_not_retrieved,
                isDisplayingError: true,
              );
              return;
            }
            context.router.push(PersonalDetailsRoute(profileBloc: profileBloc));
          },
        ),
      ],
    );
  }
}
