import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_bloc.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/presentation/profile/widgets/app_version_text.dart';
import 'package:ideal_mobile/presentation/profile/widgets/appearance.dart';
import 'package:ideal_mobile/presentation/profile/widgets/divider.dart';
import 'package:ideal_mobile/presentation/profile/widgets/help_and_support.dart';
import 'package:ideal_mobile/presentation/profile/widgets/my_orders.dart';
import 'package:ideal_mobile/presentation/profile/widgets/personal_details.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_details.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_section.dart';
import 'package:ideal_mobile/presentation/profile/widgets/settings.dart';
import 'package:ideal_mobile/presentation/profile/widgets/sign_out.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/extensions/primitive_types_extensions.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (context) => ProfileBloc()..add(const LoadProfileEvent()),
      child: const ProfileScreenBody(),
    );
  }
}

class ProfileScreenBody extends StatefulWidget {
  const ProfileScreenBody({super.key});

  @override
  State<ProfileScreenBody> createState() => _ProfileScreenBodyState();
}

class _ProfileScreenBodyState extends State<ProfileScreenBody> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          current is SignOutState ||
          current is SignOutErrorState ||
          (previous.isProfileLoading &&
              !current.isProfileLoading &&
              current.profileError != null) ||
          (previous.isAvatarUpdating &&
              !current.isAvatarUpdating &&
              current.profileError != null),
      listener: (context, state) async {
        if (state is SignOutState) {
          try {
            context.read<HomeBloc>().add(
              const BottomNavBarIndexChangedEvent(index: 0),
            );
          } catch (_) {}
          if (context.mounted) {
            await context.router.replaceAll([const HomeRoute()]);
          }
        } else if (state is SignOutErrorState) {
          _showSignOutError(state, context);
        } else if (state.profileError != null) {
          context.showSnackBar(
            state.profileError!,
            isDisplayingError: true,
            action: state.profile == null
                ? SnackBarAction(
                    label: context.localization.retry,
                    onPressed: () => context.read<ProfileBloc>().add(
                      const LoadProfileEvent(),
                    ),
                  )
                : null,
          );
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            AppSliverTopBar.root(title: context.localization.profile),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    const ProfileDetails(),
                    const SizedBox(height: 32.0),
                    ProfileSection(
                      title: context.localization.activity,
                      child: const MyOrders(),
                    ),
                    const SizedBox(height: 24.0),
                    ProfileSection(
                      title: context.localization.account,
                      child: const PersonalDetails(),
                    ),
                    const SizedBox(height: 24.0),
                    ProfileSection(
                      title: context.localization.preferences,
                      child: const Column(
                        children: [
                          Appearance(),
                          ProfileItemsDivider(),
                          Settings(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    ProfileSection(
                      title: context.localization.support,
                      child: const HelpAndSupport(),
                    ),
                    const SizedBox(height: 24.0),
                    const SignOut(),
                    const SizedBox(height: 24.0),
                    const Center(child: AppVersionText()),
                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutError(SignOutErrorState state, BuildContext context) {
    final String error = state.errorMessage;
    context.showSnackBar(
      error.isNullOrEmpty()
          ? context.localization.opps_something_went_wrong
          : error,
    );
  }
}
