import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/common/theme/text_style/app_text_styles.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_bloc.dart';
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_event.dart';
import 'package:ideal_mobile/presentation/chat/bloc/listing_chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/pending_chat_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/delete_conversation.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_date_separator.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_image_bubble.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_input_bar.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_message_bubble.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_readonly_banner.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_report_sheet.dart';
import 'package:ideal_mobile/presentation/chat/widgets/listing_chat_conversation_app_bar.dart';
import 'package:ideal_mobile/utils/extensions/build_context_ext.dart';
import 'package:ideal_mobile/utils/extensions/date_time_extensions.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';
import 'package:ideal_mobile/widgets/app_button/app_button.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_size_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_state_enum.dart';
import 'package:ideal_mobile/widgets/app_button/enums/app_button_style_enum.dart';

@RoutePage()
class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({
    super.key,
    required this.conversationId,
    this.bloc,
  });

  final int conversationId;
  final ListingChatConversationBloc? bloc;

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen>
    with WidgetsBindingObserver {
  ListingChatConversationBloc? _activeBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) {
      _activeBloc?.add(ChatConversationLifecycleChanged(state));
    }
  }

  @override
  Widget build(BuildContext context) {
    final supplied = widget.bloc;
    if (supplied != null) {
      _activeBloc = supplied;
      return BlocProvider.value(
        value: supplied,
        child: const _ChatConversationScaffold(),
      );
    }
    return BlocProvider(
      create: (_) {
        final created = ListingChatConversationBloc(
          conversationId: widget.conversationId,
        );
        _activeBloc = created;
        created.add(const ChatConversationStarted());
        return created;
      },
      child: const _ChatConversationScaffold(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _activeBloc?.add(const ChatConversationStopped());
    super.dispose();
  }
}

class _ChatConversationScaffold extends StatelessWidget {
  const _ChatConversationScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      ListingChatConversationBloc,
      ListingChatConversationState
    >(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        final message = state.errorMessage;
        if (message == null) return;
        final visible = switch (message) {
          'chat_message_too_long' => context.localization.chat_message_too_long,
          'chat_image_too_large' => context.localization.chat_image_too_large,
          'chat_image_unsupported_format' =>
            context.localization.chat_image_unsupported_format,
          _ => message,
        };
        context.showSnackBar(visible);
      },
      child:
          BlocBuilder<
            ListingChatConversationBloc,
            ListingChatConversationState
          >(
            builder: (context, state) {
              return Scaffold(
                backgroundColor: context.currentTheme.bgSurfaceBase,
                appBar: ListingChatConversationAppBar(
                  listing: state.listing,
                  listingIsAvailable: state.listingIsAvailable,
                  isArchived: state.isArchived,
                  isMuted: state.isMuted,
                  onArchive: () =>
                      context.read<ListingChatConversationBloc>().add(
                        ChatConversationArchiveToggled(
                          archived: !state.isArchived,
                        ),
                      ),
                  onMute: () => context.read<ListingChatConversationBloc>().add(
                    ChatConversationMuteToggled(muted: !state.isMuted),
                  ),
                  onReport: () => _report(context),
                  onDelete: () => _delete(context, state.conversationId),
                ),
                // The bottom inset is deliberately left to ChatInputBar's own
                // SafeArea so the bar's background extends under the gesture
                // pill while its content stays clear of it.
                body: SafeArea(
                  top: false,
                  bottom: false,
                  child: Column(
                    children: [
                      if (state.isReadOnly) const ChatReadonlyBanner(),
                      Expanded(child: _MessagesList(state: state)),
                      const ChatInputBar(),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Future<void> _report(BuildContext context) async {
    final report = await ChatReportSheet.show(context);
    if (!context.mounted || report == null) return;
    context.read<ListingChatConversationBloc>().add(
      ChatConversationReportRequested(reason: report.reason, note: report.note),
    );
    context.showSnackBar(context.localization.chat_report_submitted);
  }

  Future<void> _delete(BuildContext context, int conversationId) async {
    final confirmed = await _confirmDelete(context);
    if (!context.mounted || !confirmed) return;
    final result = await sl<DeleteConversation>()(
      DeleteConversationParams(conversationId: conversationId),
    );
    if (!context.mounted) return;
    result.fold(
      (failure) => context.showSnackBar(failure.errorMessage),
      (_) => context.router.maybePop(),
    );
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
            size: AppButtonSize.small,
            state: AppButtonState.normal,
            label: context.localization.chat_cancel,
            onPressed: () => Navigator.pop(context, false),
          ),
          AppButton(
            style: AppButtonStyle.link,
            size: AppButtonSize.small,
            state: AppButtonState.normal,
            label: context.localization.chat_delete_confirm,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _MessagesList extends StatefulWidget {
  const _MessagesList({required this.state});

  final ListingChatConversationState state;

  @override
  State<_MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<_MessagesList> {
  late final ScrollController _controller;
  bool _initialScrollDone = false;
  bool _initialScrollScheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void didUpdateWidget(covariant _MessagesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.conversationId != widget.state.conversationId) {
      _initialScrollDone = false;
      _initialScrollScheduled = false;
    }
    if (!_initialScrollDone) return;

    final oldEntries = _entries(oldWidget.state);
    final newEntries = _entries(widget.state);
    if (oldEntries.isEmpty ||
        newEntries.length <= oldEntries.length ||
        !mounted ||
        !_controller.hasClients) {
      return;
    }

    final position = _controller.position;
    final oldMaxScrollExtent = position.maxScrollExtent;
    final wasNearBottom = oldMaxScrollExtent - position.pixels <= 64;
    final grewAtHead = oldEntries.first._identity != newEntries.first._identity;
    final grewAtTail = oldEntries.last._identity != newEntries.last._identity;

    if (grewAtHead) {
      _preservePosition(oldMaxScrollExtent);
    } else if (grewAtTail && wasNearBottom) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state.status == ListingChatConversationStatus.loading &&
        state.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final entries = _entries(state);
    if (entries.isEmpty) {
      return Center(
        child: Text(
          context.localization.no_messages_yet,
          style: AppTextStyles.p3Regular.copyWith(
            color: context.currentTheme.textNeutralSecondary,
          ),
        ),
      );
    }
    _scheduleInitialScroll();
    final children = <Widget>[];
    DateTime? previousDate;
    for (final entry in entries) {
      final date = entry.createdAt;
      if (previousDate == null || !previousDate.isSameDay(date)) {
        children.add(ChatDateSeparator(date: date));
        previousDate = date;
      }
      if (entry.message != null) {
        final message = entry.message!;
        if (message.isImage) {
          children.add(
            ChatImageBubble(message: message, status: state.statusFor(message)),
          );
        } else {
          children.add(
            ChatMessageBubble(
              message: message,
              status: state.statusFor(message),
              onRetry: () => _retry(context, message.clientId),
            ),
          );
        }
      } else {
        final pending = entry.pending!;
        if (pending.isImage) {
          children.add(
            ChatImageBubble(
              pending: pending,
              status: pending.status,
              onRetry: () => _retry(context, pending.clientId),
            ),
          );
        } else {
          children.add(
            ChatMessageBubble(
              pending: pending,
              status: pending.status,
              onRetry: () => _retry(context, pending.clientId),
            ),
          );
        }
      }
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_initialScrollDone && notification.metrics.extentBefore < 80) {
          context.read<ListingChatConversationBloc>().add(
            const ChatConversationLoadOlder(),
          );
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<ListingChatConversationBloc>().add(
            const ChatConversationRefreshRequested(),
          );
        },
        child: ListView.builder(
          controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        ),
      ),
    );
  }

  void _scheduleInitialScroll() {
    if (_initialScrollDone || _initialScrollScheduled) return;
    _initialScrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialScrollScheduled = false;
      if (!mounted || !_controller.hasClients) return;
      _controller.jumpTo(_controller.position.maxScrollExtent);
      _initialScrollDone = true;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _preservePosition(double oldMaxScrollExtent) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      final position = _controller.position;
      final offset =
          (position.pixels + (position.maxScrollExtent - oldMaxScrollExtent))
              .clamp(position.minScrollExtent, position.maxScrollExtent)
              .toDouble();
      _controller.jumpTo(offset);
    });
  }

  void _retry(BuildContext context, String? clientId) {
    if (clientId == null) return;
    context.read<ListingChatConversationBloc>().add(
      ChatConversationRetrySent(clientId),
    );
  }

  List<_MessageEntry> _entries(ListingChatConversationState state) {
    final entries = <_MessageEntry>[
      ...state.messages.map(_MessageEntry.message),
      ...state.pending.map(_MessageEntry.pending),
    ];
    entries.sort((left, right) => left.createdAt.compareTo(right.createdAt));
    return entries;
  }
}

class _MessageEntry {
  const _MessageEntry.message(ChatMessage value)
    : message = value,
      pending = null;

  const _MessageEntry.pending(PendingChatMessage value)
    : message = null,
      pending = value;

  final ChatMessage? message;
  final PendingChatMessage? pending;

  DateTime get createdAt => message?.createdAt ?? pending!.createdAt;

  String get _identity => message != null
      ? 'message:${message!.id}'
      : 'pending:${pending!.clientId}';
}
