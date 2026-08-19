import 'package:flutter/material.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_avatar.dart';
import 'package:ideal_mobile/utils/extensions/date_time_extensions.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/images/tiered_network_image.dart';
import 'package:ideal_mobile/widgets/styling/app_radius.dart';

class ChatConversationListTile extends StatelessWidget {
  const ChatConversationListTile({
    super.key,
    required this.conversation,
    this.onTap,
    this.onLongPress,
  });

  final ChatConversation conversation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final listing = conversation.listing;
    final preview =
        conversation.lastMessagePreview ??
        (conversation.lastMessageKind == 'image'
            ? context.localization.chat_photo
            : '');
    final lastMessageAt = conversation.lastMessageAt;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _ListingImage(
              url: listing.coverImageUrl,
              previewUrl: listing.coverPreviewUrl,
              displayUrl: listing.coverDisplayUrl,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.p2SemiBold.copyWith(
                      color: context.currentTheme.textNeutralPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.p3Regular.copyWith(
                      color: context.currentTheme.textNeutralSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (lastMessageAt != null)
                  Text(
                    lastMessageAt.timeAgo(context.localization),
                    style: AppTextStyles.p4Regular.copyWith(
                      color: context.currentTheme.textNeutralSecondary,
                    ),
                  ),
                if (conversation.unreadCount > 0) ...[
                  const SizedBox(height: 6),
                  _UnreadPill(count: conversation.unreadCount),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingImage extends StatelessWidget {
  const _ListingImage({
    required this.url,
    required this.previewUrl,
    required this.displayUrl,
  });

  final String? url;
  final String? previewUrl;
  final String? displayUrl;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const ChatAvatar(size: 56);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.input),
      child: SizedBox(
        width: 56,
        height: 56,
        child: TieredNetworkImage(
          originalUrl: url,
          previewUrl: previewUrl,
          displayUrl: displayUrl,
          loadingBuilder: (_) => const ChatAvatar(size: 56),
          errorBuilder: (_) => const ChatAvatar(size: 56),
        ),
      ),
    );
  }
}

class _UnreadPill extends StatelessWidget {
  const _UnreadPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.currentTheme.bgBrandDefault,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: AppTextStyles.c1SemiBold.copyWith(
          color: context.currentTheme.textNeutralWhite,
        ),
      ),
    );
  }
}
