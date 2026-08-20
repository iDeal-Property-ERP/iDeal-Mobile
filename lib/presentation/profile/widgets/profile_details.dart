import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/presentation/profile/widgets/user_avatar.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/shimmer/shimmer_circular_image.dart';
import 'package:ideal_mobile/widgets/shimmer/shimmer_text.dart';
import 'package:shimmer/shimmer.dart';

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
    final String phone = state.profile?.phone ?? '';
    final bool showPhone = phone.isNotEmpty && phone != fullName;

    if (state.isProfileLoading && state.profile == null) {
      return const _ProfileDetailsSkeleton();
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
              if (showPhone)
                Text(
                  phone,
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

// Mirrors the loaded row's geometry (avatar 18.w, 30px name line, 21px phone
// line) so the sections below don't shift when profile data arrives.
class _ProfileDetailsSkeleton extends StatelessWidget {
  const _ProfileDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    final double textWidth = MediaQuery.of(context).size.width;

    return Shimmer.fromColors(
      baseColor: context.currentTheme.bgNeutralLight200,
      highlightColor: context.currentTheme.bgNeutralLight100,
      child: Row(
        children: [
          const ShimmerCircularImage(size: 18),
          const SizedBox(width: 24.0),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                SizedBox(
                  height: 30.0,
                  child: Center(child: ShimmerText(width: textWidth * 0.4)),
                ),
                SizedBox(
                  height: 21.0,
                  child: Center(child: ShimmerText(width: textWidth * 0.45)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
