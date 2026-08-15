import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_bloc.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_event.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chats_state.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_conversation_list_tile.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_empty_view.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_list_shimmer.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_report_sheet.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chats_archived_group.dart';
import 'package:ideal_mobile/routes.gr.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';
import 'package:ideal_mobile/widgets/app_top_bar.dart';

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

class _ChatsContent extends StatelessWidget {
  const _ChatsContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsBloc, ChatsState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            context.read<ChatsBloc>().add(const ChatsRefreshRequested());
          },
          child: CustomScrollView(
            slivers: [
              AppSliverTopBar.root(
                title: context.localization.chats,
                actions: [
                  AppTopBarAction(
                    icon: TablerIcons.refresh,
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).refreshIndicatorSemanticLabel,
                    onPressed: () => context.read<ChatsBloc>().add(
                      const ChatsRefreshRequested(),
                    ),
                  ),
                ],
              ),
              if (state.isLoading && state.activeItems.isEmpty)
                const SliverFillRemaining(child: ChatListShimmer())
              else if (state.activeItems.isEmpty)
                const SliverToBoxAdapter(
                  child: SizedBox(height: 320, child: ChatEmptyView()),
                )
              else
                SliverList.builder(
                  itemCount: state.activeItems.length,
                  itemBuilder: (context, index) =>
                      _conversationTile(context, state.activeItems[index]),
                ),
              SliverToBoxAdapter(
                child: ChatsArchivedGroup(
                  expanded: state.archivedExpanded,
                  loading: state.isLoadingArchived,
                  conversations: state.archivedItems,
                  onToggle: () => context.read<ChatsBloc>().add(
                    const ChatsArchivedToggled(),
                  ),
                  onConversationTap: (conversation) =>
                      _openConversation(context, conversation),
                  onConversationLongPress: (conversation) =>
                      _showActions(context, conversation),
                ),
              ),
            ],
          ),
        );
      },
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
