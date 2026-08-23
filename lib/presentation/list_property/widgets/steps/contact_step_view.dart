import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_bloc.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_event.dart';
import 'package:ideal_mobile/presentation/list_property/bloc/list_property_wizard_state.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ContactStepView extends StatefulWidget {
  const ContactStepView({super.key});

  @override
  State<ContactStepView> createState() => _ContactStepViewState();
}

class _ContactStepViewState extends State<ContactStepView> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final state = context.read<ListPropertyWizardBloc>().state;
    _firstNameController = TextEditingController(text: state.firstName);
    _lastNameController = TextEditingController(text: state.lastName ?? '');
    _emailController = TextEditingController(text: state.email ?? '');
    _phoneController = TextEditingController(text: state.phone ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListPropertyWizardBloc, ListPropertyWizardState>(
      builder: (context, state) {
        final showError = state.showValidationErrors;
        final isFirstNameMissing = showError && state.firstName.trim().isEmpty;
        final isContactMissing =
            showError &&
            (state.phone == null || state.phone!.trim().isEmpty) &&
            (state.email == null || state.email!.trim().isEmpty);

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // First Name
            _FieldLabel(label: 'First Name *', hasError: isFirstNameMissing),
            _CustomTextField(
              controller: _firstNameController,
              hintText: 'John',
              hasError: isFirstNameMissing,
              textCapitalization: TextCapitalization.words,
              onChanged: (val) => context.read<ListPropertyWizardBloc>().add(
                ListPropertyContactUpdated(firstName: val),
              ),
            ),
            if (isFirstNameMissing)
              const _FieldErrorText(text: 'Please enter your first name'),
            const SizedBox(height: 16),

            // Last Name
            const _FieldLabel(label: 'Last Name'),
            _CustomTextField(
              controller: _lastNameController,
              hintText: 'Doe',
              textCapitalization: TextCapitalization.words,
              onChanged: (val) => context.read<ListPropertyWizardBloc>().add(
                ListPropertyContactUpdated(lastName: val),
              ),
            ),
            const SizedBox(height: 16),

            // Phone
            _FieldLabel(label: 'Phone Number *', hasError: isContactMissing),
            _CustomTextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              hintText: '+998 90 123 45 67',
              hasError: isContactMissing,
              onChanged: (val) => context.read<ListPropertyWizardBloc>().add(
                ListPropertyContactUpdated(phone: val),
              ),
            ),
            if (isContactMissing)
              const _FieldErrorText(text: 'Please enter your phone number'),
            const SizedBox(height: 16),

            // Email
            const _FieldLabel(label: 'Email Address'),
            _CustomTextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              hintText: 'john.doe@example.com',
              onChanged: (val) => context.read<ListPropertyWizardBloc>().add(
                ListPropertyContactUpdated(email: val),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.hasError = false});

  final String label;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: AppTextStyles.p3Medium.copyWith(
          color: hasError ? theme.textErrorPrimary : theme.textNeutralPrimary,
        ),
      ),
    );
  }
}

class _FieldErrorText extends StatelessWidget {
  const _FieldErrorText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: AppTextStyles.p4Medium.copyWith(
          color: context.currentTheme.textErrorPrimary,
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  const _CustomTextField({
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.hasError = false,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool hasError;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.currentTheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: hasError
            ? theme.strokeErrorDefault
            : theme.strokeNeutralLight200,
        width: hasError ? 1.5 : 1,
      ),
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      style: AppTextStyles.p3Medium.copyWith(color: theme.textNeutralPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.p3Regular.copyWith(
          color: theme.textNeutralSecondary,
        ),
        filled: true,
        fillColor: theme.bgSurfaceBase2,
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: hasError ? theme.strokeErrorDefault : theme.bgBrandDefault,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
