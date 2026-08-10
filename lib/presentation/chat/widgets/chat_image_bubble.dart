import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/pending_chat_message.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_image_full_screen_view.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_message_ticks.dart';
import 'package:ideal_mobile/utils/extensions/date_time_extensions.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

class ChatImageBubble extends StatelessWidget {
  const ChatImageBubble({
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
    final path = pending?.localPath;
    final url = message?.imageUrl;
    final createdAt =
        message?.createdAt ?? pending?.createdAt ?? DateTime.now();
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: status == ChatMessageStatus.failed
            ? onRetry
            : () => _openImage(context, path ?? url),
        child: Tooltip(
          message: status == ChatMessageStatus.failed
              ? context.localization.chat_retry
              : '',
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isMine
                  ? context.currentTheme.bgBrandDefault
                  : context.currentTheme.bgBrandLight50,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: status == ChatMessageStatus.failed
                  ? Border.all(color: context.currentTheme.strokeErrorDefault)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  child: SizedBox(
                    width: 220,
                    height: 180,
                    child: path != null
                        ? Image.file(File(path), fit: BoxFit.cover)
                        : url == null || url.isEmpty
                        ? Icon(
                            TablerIcons.photo_off,
                            color: context.currentTheme.iconNeutralDisabled,
                          )
                        : CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              TablerIcons.photo_off,
                              color: context.currentTheme.iconNeutralDisabled,
                            ),
                          ),
                  ),
                ),
                if (status == ChatMessageStatus.failed)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      context.localization.chat_send_failed,
                      style: AppTextStyles.p4Regular.copyWith(
                        color: context.currentTheme.textErrorPrimary,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 3, 4, 1),
                  child: Row(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openImage(BuildContext context, String? path) {
    if (path == null || path.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatImageFullScreenView(path: path),
      ),
    );
  }
}
