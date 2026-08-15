import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_bloc.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_event.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_state.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_conversation_list_tile.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_empty_view.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_list_shimmer.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_report_sheet.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';

const _kChatsLoadMoreThreshold = 400.0;

@RoutePage()
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key, this.bloc, this.startImmediately = false});

  final ChatsBloc? bloc;
  final bool startImmediately;

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> with WidgetsBindingObserver {
  ChatsBloc? _activeBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.startImmediately) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _activeBloc?.add(const ChatsStarted());
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) _activeBloc?.add(ChatsLifecycleChanged(state));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = widget.bloc;
    const body = _ChatsBody();
    if (bloc != null) {
      _activeBloc = bloc;
      return BlocProvider.value(value: bloc, child: body);
    }
    return BlocProvider(
      create: (_) {
        final created = ChatsBloc();
        _activeBloc = created;
        return created;
      },
      child: body,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _activeBloc?.add(const ChatsStopped());
    super.dispose();
  }
}

class _ChatsBody extends StatelessWidget {
  const _ChatsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.currentTheme.bgSurfaceBase,
      body: BlocListener<ChatsBloc, ChatsState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          final message = state.errorMessage;
          if (message != null) context.showSnackBar(message);
        },
        child: const _ChatsContent(),
      ),
    );
  }
}

class _ChatsContent extends StatefulWidget {
  const _ChatsContent();

  @override
  State<_ChatsContent> createState() => _ChatsContentState();
}

class _ChatsContentState extends State<_ChatsContent> {
  final ScrollController _activeController = ScrollController();
  final ScrollController _archivedController = ScrollController();

  @override
  void initState() {
    super.initState();
    _activeController.addListener(
      () => _onScroll(ChatsTab.active, _activeController),
    );
    _archivedController.addListener(
      () => _onScroll(ChatsTab.archived, _archivedController),
    );
  }

  @override
  void dispose() {
    _activeController.dispose();
    _archivedController.dispose();
    super.dispose();
  }

  void _onScroll(ChatsTab tab, ScrollController controller) {
    if (!controller.hasClients) return;
    final position = controller.position;
    if (position.pixels < position.maxScrollExtent - _kChatsLoadMoreThreshold) {
      return;
    }

    final feed = context.read<ChatsBloc>().state.feedFor(tab);
    if (!feed.hasLoaded ||
        feed.hasReachedMax ||
        feed.isLoading ||
        feed.isLoadingMore) {
      return;
    }
    context.read<ChatsBloc>().add(ChatsLoadMoreRequested(tab));
  }

  Future<void> _refresh(ChatsTab tab) async {
    final bloc = context.read<ChatsBloc>();
    bloc.add(ChatsRefreshRequested(tab: tab));
    await bloc.stream.firstWhere((state) => !state.feedFor(tab).isLoading);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsBloc, ChatsState>(
      builder: (context, state) {
        return IndexedStack(
          index: state.selectedTab.index,
          children: [
            _ChatsFeed(
              key: const PageStorageKey('active_chats_feed'),
              tab: ChatsTab.active,
              controller: _activeController,
              state: state,
              onRefresh: () => _refresh(ChatsTab.active),
            ),
            _ChatsFeed(
              key: const PageStorageKey('archived_chats_feed'),
              tab: ChatsTab.archived,
              controller: _archivedController,
              state: state,
              onRefresh: () => _refresh(ChatsTab.archived),
            ),
          ],
        );
      },
    );
  }
}

class _ChatsFeed extends StatelessWidget {
  const _ChatsFeed({
    super.key,
    required this.tab,
    required this.controller,
    required this.state,
    required this.onRefresh,
  });

  final ChatsTab tab;
  final ScrollController controller;
  final ChatsState state;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final feed = state.feedFor(tab);
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          AppSliverTopBar.root(
            title: context.localization.chats,
            bottomHeight: 48,
            bottom: _ChatsTabs(selectedTab: state.selectedTab),
            actions: [
              AppTopBarAction(
                icon: TablerIcons.refresh,
                tooltip: MaterialLocalizations.of(
                  context,
                ).refreshIndicatorSemanticLabel,
                onPressed: () => context.read<ChatsBloc>().add(
                  ChatsRefreshRequested(tab: tab),
                ),
              ),
            ],
          ),
          if (feed.isLoading && feed.items.isEmpty)
            const SliverFillRemaining(child: ChatListShimmer())
          else if (feed.errorMessage != null && feed.items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _ChatsErrorView(
                onRetry: () => context.read<ChatsBloc>().add(
                  ChatsRefreshRequested(tab: tab),
                ),
              ),
            )
          else if (feed.items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: ChatEmptyView(
                title: tab == ChatsTab.archived
                    ? context.localization.chats_archived_empty_title
                    : null,
                subtitle: tab == ChatsTab.archived
                    ? context.localization.chats_archived_empty_subtitle
                    : null,
              ),
            )
          else
            SliverList.builder(
              itemCount: feed.items.length,
              itemBuilder: (context, index) =>
                  _conversationTile(context, feed.items[index]),
            ),
          if (feed.isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const CircularProgressIndicator.adaptive(),
                    const SizedBox(height: 12),
                    Text(
                      context.localization.chats_loading_more,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.currentTheme.textNeutralSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (feed.errorMessage != null && feed.items.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: MaterialBanner(
                  content: Text(context.localization.chats_load_error),
                  actions: [
                    TextButton(
                      onPressed: () => context.read<ChatsBloc>().add(
                        feed.failedPage == 1
                            ? ChatsRefreshRequested(tab: tab)
                            : ChatsLoadMoreRequested(tab),
                      ),
                      child: Text(context.localization.chats_retry),
                    ),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _conversationTile(
    BuildContext context,
    ChatConversation conversation,
  ) {
    return ChatConversationListTile(
      conversation: conversation,
      onTap: () => _openConversation(context, conversation),
      onLongPress: () => _showActions(context, conversation),
    );
  }

  void _openConversation(BuildContext context, ChatConversation conversation) {
    context.router.push(
      ChatConversationRoute(
        conversationId: conversation.id,
        initialConversation: conversation,
      ),
    );
  }

  Future<void> _showActions(
    BuildContext context,
    ChatConversation conversation,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.currentTheme.bgSurfaceSheet,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                conversation.isArchived
                    ? context.localization.chat_unarchive
                    : context.localization.chat_archive,
              ),
              onTap: () => Navigator.pop(context, 'archive'),
            ),
            ListTile(
              title: Text(
                conversation.isMuted
                    ? context.localization.chat_unmute
                    : context.localization.chat_mute,
              ),
              onTap: () => Navigator.pop(context, 'mute'),
            ),
            ListTile(
              title: Text(context.localization.chat_report),
              onTap: () => Navigator.pop(context, 'report'),
            ),
            ListTile(
              title: Text(context.localization.chat_delete),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    final bloc = context.read<ChatsBloc>();
    switch (action) {
      case 'archive':
        bloc.add(
          ChatsArchiveToggled(
            conversationId: conversation.id,
            archived: !conversation.isArchived,
          ),
        );
      case 'mute':
        bloc.add(
          ChatsMuteToggled(
            conversationId: conversation.id,
            muted: !conversation.isMuted,
          ),
        );
      case 'report':
        final report = await ChatReportSheet.show(context);
        if (!context.mounted || report == null) return;
        bloc.add(
          ChatsConversationReported(
            conversationId: conversation.id,
            reason: report.reason,
            note: report.note,
          ),
        );
        context.showSnackBar(context.localization.chat_report_submitted);
      case 'delete':
        final confirmed = await _confirmDelete(context);
        if (confirmed && context.mounted) {
          bloc.add(ChatsConversationDeleted(conversation.id));
        }
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.currentTheme.bgSurfaceBase2,
        title: Text(context.localization.chat_delete_title),
        content: Text(context.localization.chat_delete_message),
        actions: [
          AppButton(
            style: AppButtonStyle.link,
            label: context.localization.chat_cancel,
            onPressed: () => Navigator.pop(context, false),
          ),
          AppButton(
            style: AppButtonStyle.link,
            label: context.localization.chat_delete_confirm,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _ChatsTabs extends StatelessWidget {
  const _ChatsTabs({required this.selectedTab});

  final ChatsTab selectedTab;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.currentTheme.bgSurfaceBase,
      child: Row(
        children: [
          _ChatsTabButton(
            label: context.localization.chats_active,
            selected: selectedTab == ChatsTab.active,
            onTap: () => context.read<ChatsBloc>().add(
              const ChatsTabSelected(ChatsTab.active),
            ),
          ),
          _ChatsTabButton(
            label: context.localization.chats_archived,
            selected: selectedTab == ChatsTab.archived,
            onTap: () => context.read<ChatsBloc>().add(
              const ChatsTabSelected(ChatsTab.archived),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatsTabButton extends StatelessWidget {
  const _ChatsTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? context.currentTheme.textBrandPrimary
        : context.currentTheme.textNeutralSecondary;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: AppTextStyles.p3SemiBold.copyWith(color: color),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 2,
                color: selected
                    ? context.currentTheme.strokeBrandDefault
                    : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatsErrorView extends StatelessWidget {
  const _ChatsErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              TablerIcons.alert_circle,
              size: 64,
              color: context.currentTheme.iconErrorDefault,
            ),
            const SizedBox(height: 16),
            Text(
              context.localization.chats_load_error,
              textAlign: TextAlign.center,
              style: AppTextStyles.p2SemiBold.copyWith(
                color: context.currentTheme.textNeutralPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(context.localization.chats_retry),
            ),
          ],
        ),
      ),
    );
  }
}
