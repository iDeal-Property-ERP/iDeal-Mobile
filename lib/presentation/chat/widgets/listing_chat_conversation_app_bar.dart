import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_listing_ref.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_avatar.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';

class ListingChatConversationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ListingChatConversationAppBar({
    super.key,
    required this.listing,
    required this.listingIsAvailable,
    required this.isArchived,
    required this.isMuted,
    this.onArchive,
    this.onMute,
    this.onReport,
    this.onDelete,
  });

  final ChatListingRef listing;
  final bool listingIsAvailable;
  final bool isArchived;
  final bool isMuted;
  final VoidCallback? onArchive;
  final VoidCallback? onMute;
  final VoidCallback? onReport;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.currentTheme.bgSurfaceBase2,
      elevation: 0,
      titleSpacing: 0,
      leading: AppButton.icon(
        iconData: TablerIcons.arrow_left,
        iconOrTextColorOverride: context.currentTheme.iconNeutralDefault,
        size: AppButtonSize.extraLarge,
        onPressed: () => context.router.maybePop(),
      ),
      title: Row(
        children: [
          ChatAvatar(imageUrl: listing.coverImageUrl, size: 40),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              listing.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.p3SemiBold.copyWith(
                color: context.currentTheme.textNeutralPrimary,
              ),
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(
            TablerIcons.dots_vertical,
            color: context.currentTheme.iconNeutralDefault,
          ),
          onSelected: (value) {
            switch (value) {
              case 'archive':
                onArchive?.call();
              case 'mute':
                onMute?.call();
              case 'report':
                onReport?.call();
              case 'delete':
                onDelete?.call();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'archive',
              child: Text(
                isArchived
                    ? context.localization.chat_unarchive
                    : context.localization.chat_archive,
              ),
            ),
            PopupMenuItem(
              value: 'mute',
              child: Text(
                isMuted
                    ? context.localization.chat_unmute
                    : context.localization.chat_mute,
              ),
            ),
            PopupMenuItem(
              value: 'report',
              child: Text(context.localization.chat_report),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(context.localization.chat_delete),
            ),
          ],
        ),
      ],
      bottom: listingIsAvailable
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(34),
              child: Container(
                width: double.infinity,
                color: context.currentTheme.bgWarningLight50,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  context.localization.chat_listing_unavailable,
                  style: AppTextStyles.p4Regular.copyWith(
                    color: context.currentTheme.textWarningPrimary,
                  ),
                ),
              ),
            ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (listingIsAvailable ? 0 : 34));
}
