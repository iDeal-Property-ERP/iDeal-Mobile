import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_bloc.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_event.dart';
import 'package:ideal_mobile/presentation/profile/bloc/profile_state.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/validators/validators.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';

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
        appBar: AppTopBar.page(title: context.localization.personal_details),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
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
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ProfileTextField(
                  label: context.localization.first_name,
                  controller: _firstNameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 30,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? context.localization.name_cannot_be_empty
                      : null,
                ),
                _ProfileTextField(
                  label: context.localization.last_name,
                  controller: _lastNameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 30,
                ),
                _ProfileTextField(
                  label: context.localization.patronymic,
                  controller: _patronymicController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 100,
                ),
                _ProfileTextField(
                  label: context.localization.email,
                  controller: _emailController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
                  maxLength: 254,
                  validator: (value) =>
                      isEmailValid(value?.trim() ?? '', context),
                ),
                _ProfileTextField(
                  label: context.localization.mobile_number,
                  controller: _phoneController,
                  textInputAction: TextInputAction.none,
                  keyboardType: TextInputType.phone,
                  readOnly: true,
                  enabled: false,
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
          email: _emailController.text.trim(),
        ),
      ),
    );
  }

  String? _optionalValue(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.label,
    required this.controller,
    required this.textInputAction,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.validator,
    this.readOnly = false,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final String? Function(String?)? validator;
  final bool readOnly;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: context.currentTheme.strokeNeutralLight200),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.p3Medium.copyWith(
              color: context.currentTheme.textNeutralPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: enabled,
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
              fillColor: context.currentTheme.bgSurfaceBase2,
              counterText: '',
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
}
