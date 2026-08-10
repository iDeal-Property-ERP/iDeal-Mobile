import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_state_enum.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

class ChatReportDraft {
  const ChatReportDraft({required this.reason, required this.note});

  final String reason;
  final String? note;
}

class ChatReportSheet {
  const ChatReportSheet._();

  static Future<ChatReportDraft?> show(BuildContext context) {
    return showModalBottomSheet<ChatReportDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.currentTheme.bgSurfaceSheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (context) => const _ChatReportContent(),
    );
  }
}

class _ChatReportContent extends StatefulWidget {
  const _ChatReportContent();

  @override
  State<_ChatReportContent> createState() => _ChatReportContentState();
}

class _ChatReportContentState extends State<_ChatReportContent> {
  String? _reason;
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final localizations = context.localization;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                localizations.chat_report_title,
                style: AppTextStyles.h6SemiBold.copyWith(
                  color: context.currentTheme.textNeutralPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _reasonTile(
                title: localizations.chat_report_reason_spam,
                value: 'spam',
              ),
              _reasonTile(
                title: localizations.chat_report_reason_abuse,
                value: 'abuse',
              ),
              _reasonTile(
                title: localizations.chat_report_reason_scam,
                value: 'scam',
              ),
              _reasonTile(
                title: localizations.chat_report_reason_other,
                value: 'other',
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLength: 500,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: localizations.chat_report_note_hint,
                  filled: true,
                  fillColor: context.currentTheme.bgSurfaceBase,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AppButton.primary(
                label: localizations.chat_report_submit,
                size: AppButtonSize.medium,
                state: _reason == null
                    ? AppButtonState.disabled
                    : AppButtonState.normal,
                showLoader: false,
                onPressed: _reason == null
                    ? () {}
                    : () => Navigator.of(context).pop(
                        ChatReportDraft(
                          reason: _reason!,
                          note: _noteController.text.trim().isEmpty
                              ? null
                              : _noteController.text.trim(),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reasonTile({required String title, required String value}) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: AppTextStyles.p3Regular.copyWith(
          color: context.currentTheme.textNeutralPrimary,
        ),
      ),
      value: value,
      groupValue: _reason,
      onChanged: (value) => setState(() => _reason = value),
      activeColor: context.currentTheme.iconBrandHover,
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
