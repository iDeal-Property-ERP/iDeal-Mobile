import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/delete_account/delete_account_screen.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/presentation/profile/widgets/profile_change_phone_sheet.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/validators/validators.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';
import 'package:ideal_mobile/widgets/styling/app_colors.dart';

@RoutePage()
class PersonalDetailsScreen extends StatelessWidget {
  const PersonalDetailsScreen({super.key, required this.profileBloc});

  final ProfileBloc profileBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: profileBloc,
      child: const _PersonalDetailsForm(),
    );
  }
}

class _PersonalDetailsForm extends StatefulWidget {
  const _PersonalDetailsForm();

  @override
  State<_PersonalDetailsForm> createState() => _PersonalDetailsFormState();
}

class _PersonalDetailsFormState extends State<_PersonalDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _patronymicController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _awaitingSave = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileBloc>().state.profile;
    _firstNameController = TextEditingController(
      text: profile?.firstName ?? '',
    );
    _lastNameController = TextEditingController(text: profile?.lastName ?? '');
    _patronymicController = TextEditingController(
      text: profile?.patronymic ?? '',
    );
    _emailController = TextEditingController(text: profile?.email ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _patronymicController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (!_awaitingSave || state.isProfileUpdating) return;

        _awaitingSave = false;
        if (state.profileError != null) {
          context.showSnackBar(state.profileError!, isDisplayingError: true);
          return;
        }
        context.router.maybePop();
      },
      child: Scaffold(
        appBar: AppTopBar.page(
          title: context.localization.personal_details,
          actions: [
            AppTopBarAction(
              icon: TablerIcons.trash,
              tooltip: context.localization.delete_account,
              style: AppTopBarActionStyle.danger,
              onPressed: _openDeleteAccount,
            ),
          ],
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: context.currentTheme.bgSurfaceBase,
            border: Border(
              top: BorderSide(
                color: context.currentTheme.strokeNeutralLight200,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 12.0, 18.0, 16.0),
              child: BlocBuilder<ProfileBloc, ProfileState>(
                buildWhen: (previous, current) =>
                    previous.isProfileUpdating != current.isProfileUpdating,
                builder: (context, state) => AppButton(
                  label: context.localization.save,
                  size: AppButtonSize.large,
                  shouldSetFullWidth: true,
                  isLoading: state.isProfileUpdating,
                  onPressed: state.isProfileUpdating ? null : _save,
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(18.0, 20.0, 18.0, 24.0),
              children: [
                _ProfileFormCard(
                  child: Column(
                    children: [
                      _ProfileTextField(
                        label: context.localization.first_name,
                        icon: TablerIcons.user,
                        controller: _firstNameController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 30,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? context.localization.name_cannot_be_empty
                            : null,
                      ),
                      _ProfileTextField(
                        label: context.localization.last_name,
                        icon: TablerIcons.user,
                        controller: _lastNameController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 30,
                      ),
                      _ProfileTextField(
                        label: context.localization.patronymic,
                        icon: TablerIcons.id,
                        controller: _patronymicController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 100,
                      ),
                      _ProfileTextField(
                        label: context.localization.email,
                        icon: TablerIcons.mail,
                        controller: _emailController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 254,
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) return null;
                          return isEmailValid(trimmed, context);
                        },
                      ),
                      _ProfileTextField(
                        label: context.localization.mobile_number,
                        icon: TablerIcons.phone,
                        controller: _phoneController,
                        textInputAction: TextInputAction.none,
                        keyboardType: TextInputType.phone,
                        readOnly: true,
                        bottomPadding: 0.0,
                        labelAction: TextButton.icon(
                          onPressed: () async {
                            final profile = await ProfileChangePhoneSheet.show(
                              context,
                            );
                            if (profile != null && mounted) {
                              _phoneController.text = profile.phone ?? '';
                            }
                          },
                          icon: const Icon(TablerIcons.pencil, size: 16.0),
                          label: Text(context.localization.edit),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                context.currentTheme.textBrandPrimary,
                            minimumSize: const Size(44.0, 40.0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final profile = context.read<ProfileBloc>().state.profile;
    if (profile == null) return;

    _awaitingSave = true;
    context.read<ProfileBloc>().add(
      UpdateProfileEvent(
        profile: profile.copyWith(
          firstName: _firstNameController.text.trim(),
          lastName: _optionalValue(_lastNameController),
          clearLastName: _optionalValue(_lastNameController) == null,
          patronymic: _optionalValue(_patronymicController),
          clearPatronymic: _optionalValue(_patronymicController) == null,
          email: _optionalValue(_emailController),
          clearEmail: _optionalValue(_emailController) == null,
        ),
      ),
    );
  }

  void _openDeleteAccount() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DeleteAccountScreen()));
  }

  String? _optionalValue(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.textInputAction,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.validator,
    this.readOnly = false,
    this.bottomPadding = 16.0,
    this.labelAction,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final String? Function(String?)? validator;
  final bool readOnly;
  final double bottomPadding;
  final Widget? labelAction;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: context.currentTheme.strokeNeutralLight200),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.p4SemiBold.copyWith(
                    color: context.currentTheme.textNeutralSecondary,
                  ),
                ),
              ),
              ..._labelActions,
            ],
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            maxLength: maxLength,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: AppTextStyles.p3Medium.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: context.currentTheme.bgSurfaceBase,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 15.0,
              ),
              prefixIcon: Icon(
                icon,
                size: 20.0,
                color: context.currentTheme.iconBrandPrimary,
              ),
              border: border,
              enabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: BorderSide(
                  color: context.currentTheme.strokeBrandHover,
                ),
              ),
              errorBorder: border.copyWith(
                borderSide: BorderSide(
                  color: context.currentTheme.strokeErrorDefault,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> get _labelActions {
    final action = labelAction;
    return action == null ? const <Widget>[] : <Widget>[action];
  }
}

class _ProfileFormCard extends StatelessWidget {
  const _ProfileFormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: context.isDark
          ? context.currentTheme.bgSurfaceBase2
          : AppColors.white,
      borderRadius: BorderRadius.circular(18.0),
      border: Border.all(color: context.currentTheme.strokeNeutralLight200),
      boxShadow: context.isDark
          ? null
          : const [
              BoxShadow(
                color: Color(0x120F2A5C),
                blurRadius: 16.0,
                offset: Offset(0.0, 6.0),
              ),
            ],
    ),
    child: child,
  );
}
