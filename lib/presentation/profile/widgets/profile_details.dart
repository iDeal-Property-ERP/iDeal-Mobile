import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/presentation/profile/widgets/user_avatar.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileState state = context.select<ProfileBloc, ProfileState>(
      (bloc) => bloc.state,
    );
    final String fullName = state.name.isNotEmpty
        ? state.name
        : state.profile?.phone ?? '';
    final String email = state.email;

    if (state.isProfileLoading && state.profile == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Row(
      children: [
        const UserAvatar(),
        const SizedBox(width: 24.0),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: .min,
            children: [
              Text(
                fullName,
                style: AppTextStyles.h6SemiBold.copyWith(
                  color: context.currentTheme.textNeutralPrimary,
                ),
                overflow: .ellipsis,
                maxLines: 1,
              ),
              Text(
                email,
                style: AppTextStyles.p3Medium.copyWith(
                  color: context.currentTheme.textNeutralSecondary,
                ),
                overflow: .ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
