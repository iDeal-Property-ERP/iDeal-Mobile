import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_conversation_list_tile.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class ChatsArchivedGroup extends StatelessWidget {
  const ChatsArchivedGroup({
    super.key,
    required this.expanded,
    required this.loading,
    required this.conversations,
    required this.onToggle,
    this.onConversationTap,
    this.onConversationLongPress,
  });

  final bool expanded;
  final bool loading;
  final List<ChatConversation> conversations;
  final VoidCallback onToggle;
  final ValueChanged<ChatConversation>? onConversationTap;
  final ValueChanged<ChatConversation>? onConversationLongPress;

  @override
  Widget build(BuildContext context) {
    final content = loading
        ? const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        : Column(
            children: conversations
                .map(
                  (conversation) => ChatConversationListTile(
                    conversation: conversation,
                    onTap: onConversationTap == null
                        ? null
                        : () => onConversationTap!(conversation),
                    onLongPress: onConversationLongPress == null
                        ? null
                        : () => onConversationLongPress!(conversation),
                  ),
                )
                .toList(growable: false),
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.localization.chats_archived,
                    style: AppTextStyles.p3SemiBold.copyWith(
                      color: context.currentTheme.textNeutralPrimary,
                    ),
                  ),
                ),
                Icon(
                  expanded ? TablerIcons.chevron_up : TablerIcons.chevron_down,
                  color: context.currentTheme.iconNeutralDefault,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          firstChild: const SizedBox.shrink(),
          secondChild: content,
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
        ),
      ],
    );
  }
}
