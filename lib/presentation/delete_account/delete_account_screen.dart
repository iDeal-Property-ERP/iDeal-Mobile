import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:ideal_mobile/shared_pref/prefs.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  var _loading = false;

  Future<void> _startDeletion() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.localization.delete_account),
        content: Text(context.localization.delete_account_confirmation_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.localization.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.localization.delete_account),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      await _requestCode();
      if (!mounted) return;
      await _confirmCode();
    } on DioException catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestCode() => sl<Dio>().post(
    '/mobile/account/deletion/otp/request/',
    data: {'channel': 'telegram'},
  );

  Future<void> _resendCode() async {
    try {
      await _requestCode();
      if (mounted) context.showSnackBar(context.localization.response_received);
    } on DioException catch (error) {
      if (mounted) _showError(error);
    }
  }

  Future<void> _confirmCode() async {
    final codeController = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.localization.enter_otp),
        content: TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.localization.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, codeController.text),
            child: Text(context.localization.delete_account),
          ),
          TextButton(
            onPressed: _resendCode,
            child: Text(context.localization.resend),
          ),
        ],
      ),
    );
    codeController.dispose();
    if (code == null || code.length != 6) return;

    try {
      await sl<Dio>().post(
        '/mobile/account/deletion/confirm/',
        data: {'code': code},
      );
      await Prefs.clear();
      await sl<SecureStorageService>().clearAuthTokens();
      await sl<CacheManager>().clearCachedApiResponse();
      if (!mounted) return;
      await context.router.replaceAll([const LoginWithPhoneNumberRoute()]);
    } on DioException catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showError(DioException error) {
    final body = error.response?.data;
    final message = body is Map && body['message'] is String
        ? body['message'] as String
        : context.localization.opps_something_went_wrong;
    context.showSnackBar(message, isDisplayingError: true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.localization.delete_account)),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.localization.delete_account_confirmation_message),
          const Spacer(),
          AppButton(
            label: context.localization.delete_account,
            shouldSetFullWidth: true,
            size: AppButtonSize.extraLarge,
            isLoading: _loading,
            onPressed: _loading ? null : _startDeletion,
          ),
        ],
      ),
    ),
  );
}
