import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/profile/data/models/mobile_user_profile.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key, this.profile});

  final MobileUserProfile? profile;

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  var _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _submitting = true);
    final profile = widget.profile;
    try {
      await sl<Dio>().post(
        '/marketplace/inquiries/',
        data: {
          'full_name': profile?.displayName.isNotEmpty ?? false
              ? profile!.displayName
              : _nameController.text.trim(),
          'phone': profile?.phone ?? _phoneController.text.trim(),
          'message': _messageController.text.trim(),
        },
      );
      if (!mounted) return;
      context.showSnackBar(context.localization.response_received);
      Navigator.of(context).pop();
    } on DioException catch (error) {
      if (!mounted) return;
      final body = error.response?.data;
      final message = body is Map && body['message'] is String
          ? body['message'] as String
          : context.localization.opps_something_went_wrong;
      context.showSnackBar(message, isDisplayingError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = widget.profile?.phone?.isNotEmpty ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(context.localization.contact_us)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(context.localization.contact_us_message),
            const SizedBox(height: 24),
            if (!signedIn) ...[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.localization.name,
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.localization.name_cannot_be_empty
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: context.localization.enter_phone_number,
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.localization.invalid_mobile_number
                    : null,
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: context.localization.message,
              ),
              minLines: 5,
              maxLines: 8,
              validator: (value) => value == null || value.trim().isEmpty
                  ? context.localization.message_cannot_be_empty
                  : null,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: context.localization.submit,
              shouldSetFullWidth: true,
              size: AppButtonSize.extraLarge,
              isLoading: _submitting,
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
