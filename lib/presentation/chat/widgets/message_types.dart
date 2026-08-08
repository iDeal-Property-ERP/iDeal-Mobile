import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/presentation/chat/model/chat_message_model.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class MessageTypes extends StatelessWidget {
  const MessageTypes({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message.message,
      style: AppTextStyles.p2Regular.copyWith(
        color: message.isSentByMe
            ? context.currentTheme.strokeShadesWhite
            : context.currentTheme.textNeutralPrimary,
      ),
    );
  }
}
