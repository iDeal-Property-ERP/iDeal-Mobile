import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/pending_chat_message.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_message_ticks.dart';
import 'package:ideal_mobile/utils/extensions/date_time_extensions.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    this.message,
    this.pending,
    this.status = ChatMessageStatus.sent,
    this.onRetry,
  });

  final ChatMessage? message;
  final PendingChatMessage? pending;
  final ChatMessageStatus status;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isMine = message?.isMine ?? true;
    final text = message?.text ?? pending?.text ?? '';
    final createdAt =
        message?.createdAt ?? pending?.createdAt ?? DateTime.now();
    final failed = status == ChatMessageStatus.failed;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: failed ? onRetry : null,
        child: Tooltip(
          message: failed ? context.localization.chat_retry : '',
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(maxWidth: 310),
            decoration: BoxDecoration(
              color: isMine
                  ? context.currentTheme.bgBrandDefault
                  : context.currentTheme.bgBrandLight50,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppRadius.card),
                topRight: Radius.circular(isMine ? 0 : AppRadius.card),
                bottomLeft: Radius.circular(isMine ? AppRadius.card : 0),
                bottomRight: const Radius.circular(AppRadius.card),
              ),
              border: failed
                  ? Border.all(color: context.currentTheme.strokeErrorDefault)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: AppTextStyles.p2Regular.copyWith(
                    color: isMine
                        ? context.currentTheme.textNeutralWhite
                        : context.currentTheme.textNeutralPrimary,
                  ),
                ),
                if (failed) ...[
                  const SizedBox(height: 3),
                  Text(
                    context.localization.chat_send_failed,
                    style: AppTextStyles.p4Regular.copyWith(
                      color: context.currentTheme.textErrorPrimary,
                    ),
                  ),
                ],
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      createdAt.to12HourFormat(),
                      style: AppTextStyles.c2Medium.copyWith(
                        color: isMine
                            ? context.currentTheme.textNeutralWhite
                            : context.currentTheme.textNeutralSecondary,
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 4),
                      ChatMessageTicks(status: status),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
