import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/change_theme/widgets/theme_picker_sheet.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_bloc.dart';
import 'package:ideal_mobile/presentation/home/bloc/home_event.dart';
import 'package:ideal_mobile/presentation/my_listings/bloc/my_listings_bloc.dart';
import 'package:ideal_mobile/presentation/my_listings/bloc/my_listings_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/presentation/profile/widgets/app_version_text.dart';
import 'package:ideal_mobile/presentation/profile/widgets/help_and_support.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_contracts_sheet.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_group_card.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_header.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_language_sheet.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_my_listings_sheet.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_section_header.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_sign_out_button.dart';
import 'package:ideal_mobile/presentation/settings/privacy_policy_screen.dart';
import 'package:ideal_mobile/presentation/settings/terms_and_conditions_screen.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/extensions/primitive_types_extensions.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileBloc? parentBloc;
    try {
      parentBloc = context.read<ProfileBloc>();
    } catch (_) {}

    if (parentBloc != null) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<ProfileBloc>.value(value: parentBloc),
          BlocProvider<MyListingsBloc>(
            create: (_) =>
                sl<MyListingsBloc>()..add(const LoadMyListingsEvent()),
          ),
        ],
        child: const ProfileScreenBody(),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc()..add(const LoadProfileEvent()),
        ),
        BlocProvider<MyListingsBloc>(
          create: (_) => sl<MyListingsBloc>()..add(const LoadMyListingsEvent()),
        ),
      ],
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
    final headerColor = ProfileHeader.backgroundColorFor(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: headerColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: BlocListener<ProfileBloc, ProfileState>(
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
          backgroundColor: headerColor,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfileHeader(),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.currentTheme.bgSurfaceBase,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileSectionHeader(
                          title: context.localization.my_account,
                        ),
                        ProfileGroupCard(
                          items: [
                            ProfileGroupItem(
                              icon: TablerIcons.bell,
                              label: context.localization.notifications,
                              onTap: () =>
                                  context.router.push(NotificationsRoute()),
                            ),
                            ProfileGroupItem(
                              icon: TablerIcons.building,
                              label: context.localization.my_listings,
                              onTap: () => ProfileMyListingsSheet.show(context),
                            ),
                            ProfileGroupItem(
                              icon: TablerIcons.file_text,
                              label: context.localization.my_contracts,
                              onTap: () => ProfileContractsSheet.show(context),
                            ),
                            ProfileGroupItem(
                              icon: TablerIcons.calendar,
                              label: context.localization.booking_history,
                              onTap: () =>
                                  context.router.push(const BookingsRoute()),
                            ),
                          ],
                        ),
                        ProfileSectionHeader(
                          title: context.localization.app_section,
                        ),
                        ProfileGroupCard(
                          items: [
                            ProfileGroupItem(
                              icon: TablerIcons.palette,
                              label: context.localization.appearance,
                              onTap: () => ThemePickerSheet.show(context),
                            ),
                            ProfileGroupItem(
                              icon: TablerIcons.language,
                              label: context.localization.language_settings,
                              onTap: () => ProfileLanguageSheet.show(context),
                            ),
                            ProfileGroupItem(
                              icon: TablerIcons.headphones,
                              label: context.localization.help_and_support,
                              onTap: () =>
                                  HelpAndSupport.showContactOptions(context),
                            ),
                            ProfileGroupItem(
                              icon: TablerIcons.shield_check,
                              label: context.localization.privacy_policy,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PrivacyPolicyScreen(),
                                ),
                              ),
                            ),
                            ProfileGroupItem(
                              icon: TablerIcons.book,
                              label: context.localization.terms_and_conditions,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const TermsAndConditionsScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14.0),
                        const ProfileSignOutButton(),
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
