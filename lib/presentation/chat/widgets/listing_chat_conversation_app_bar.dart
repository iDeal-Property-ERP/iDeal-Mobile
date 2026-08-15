import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_listing_ref.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_avatar.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_top_bar/app_top_bar.dart';

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
    final bar = AppTopBar.page(
      title: '',
      actions: [
        AppTopBarAction(
          icon: TablerIcons.dots_vertical,
          tooltip: MaterialLocalizations.of(context).showMenuTooltip,
          onPressed: () => _showMenu(context),
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

    return PreferredSize(
      preferredSize: bar.preferredSize,
      child: Stack(
        fit: StackFit.expand,
        children: [
          bar,
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ChatAvatar(imageUrl: listing.coverImageUrl, size: 40),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Semantics(
                        header: true,
                        child: Text(
                          listing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.p3SemiBold.copyWith(
                            color: context.currentTheme.textNeutralPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMenu(BuildContext context) async {
    final size = MediaQuery.sizeOf(context);
    final value = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        size.width - 224,
        MediaQueryData.fromView(View.of(context)).padding.top +
            AppTopBar.height -
            4,
        8,
        0,
      ),
      items: [
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
    );

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
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(AppTopBar.height + (listingIsAvailable ? 0 : 34));
}
