import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/presentation/profile/widgets/account_section.dart';
import 'package:ideal_mobile/presentation/profile/widgets/activity_section.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_details.dart';
import 'package:ideal_mobile/presentation/profile/widgets/settings.dart';
import 'package:ideal_mobile/presentation/profile/widgets/sign_out.dart';
import 'package:ideal_mobile/presentation/profile/widgets/support_section.dart';
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
          await context.router.replaceAll([const HomeRoute()]);
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
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    ProfileDetails(),
                    SizedBox(height: 40.0),
                    AccountSection(),
                    SizedBox(height: 24.0),
                    ActivitySection(),
                    SizedBox(height: 32.0),
                    Settings(),
                    SizedBox(height: 24.0),
                    SupportSection(),
                    SizedBox(height: 24.0),
                    SignOut(),
                    SizedBox(height: 32.0),
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
