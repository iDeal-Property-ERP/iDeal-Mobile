import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_bloc.dart';
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_event.dart';
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_attach_sheet.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_state_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      ListingChatConversationBloc,
      ListingChatConversationState
    >(
      buildWhen: (previous, current) =>
          previous.canSend != current.canSend ||
          previous.isReadOnly != current.isReadOnly ||
          previous.metadataConfirmed != current.metadataConfirmed,
      builder: (context, state) {
        final enabled = state.metadataConfirmed && !state.isReadOnly;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: context.currentTheme.bgSurfaceBase2,
            border: Border(
              top: BorderSide(
                color: context.currentTheme.strokeNeutralLight100,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppButton(
                    style: AppButtonStyle.textOrIcon,
                    size: AppButtonSize.medium,
                    state: enabled
                        ? AppButtonState.normal
                        : AppButtonState.disabled,
                    isIconButton: true,
                    iconData: TablerIcons.paperclip,
                    foregroundColor: context.currentTheme.iconNeutralDefault,
                    onPressed: enabled ? () => _pickImage(context) : null,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: enabled,
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 1024,
                      textInputAction: TextInputAction.newline,
                      onChanged: (value) => context
                          .read<ListingChatConversationBloc>()
                          .add(ChatConversationDraftChanged(value)),
                      onSubmitted: (_) => _send(context),
                      style: AppTextStyles.p3Medium.copyWith(
                        color: context.currentTheme.textNeutralPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: context.localization.chat_message_hint,
                        counterText: '',
                        filled: true,
                        fillColor: context.currentTheme.bgSurfaceBase,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          borderSide: BorderSide(
                            color: context.currentTheme.strokeNeutralLight100,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.input),
                          borderSide: BorderSide(
                            color: context.currentTheme.strokeNeutralLight100,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AppButton(
                    style: AppButtonStyle.textOrIcon,
                    size: AppButtonSize.medium,
                    state: state.canSend
                        ? AppButtonState.normal
                        : AppButtonState.disabled,
                    isIconButton: true,
                    iconData: TablerIcons.send,
                    foregroundColor: state.canSend
                        ? context.currentTheme.iconBrandHover
                        : context.currentTheme.iconNeutralDisabled,
                    onPressed: state.canSend ? () => _send(context) : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _send(BuildContext context) {
    context.read<ListingChatConversationBloc>().add(
      ChatConversationTextSent(_controller.text),
    );
    _controller.clear();
  }

  Future<void> _pickImage(BuildContext context) async {
    final path = await ChatAttachSheet.show(context);
    if (!context.mounted || path == null) return;
    context.read<ListingChatConversationBloc>().add(
      ChatConversationImageSent(path),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
