import 'package:auto_route/annotations.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chat_conversation_bloc.dart';
import 'package:ideal_mobile/presentation/chat/bloc/chat_conversation_event.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/send_chat_message.dart';
import 'package:ideal_mobile/presentation/chat/domain/usecases/watch_chat_messages.dart';
import 'package:ideal_mobile/presentation/chat/model/chat_model.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_conversation_app_bar.dart';
import 'package:ideal_mobile/presentation/chat/widgets/chat_message_list.dart';
import 'package:ideal_mobile/presentation/chat/widgets/new_message_text_field.dart';
import 'package:ideal_mobile/services/firebase_auth_services.dart';

@RoutePage()
class ChatConversationScreen extends StatelessWidget {
  const ChatConversationScreen({super.key, required this.chatUser});

  final ChatModel chatUser;

  @override
  Widget build(BuildContext context) {
    final currentUserId = sl<FirebaseAuthService>().getCurrentUser()?.uid ?? '';
    return BlocProvider<ChatConversationBloc>(
      create: (_) => ChatConversationBloc(
        watchChatMessages: sl<WatchChatMessages>(),
        sendChatMessage: sl<SendChatMessage>(),
        currentUserId: currentUserId,
        recipientUserId: chatUser.userId,
      )..add(const ChatConversationSubscribedEvent()),
      child: ChatConversationWrapper(chatUser: chatUser),
    );
  }
}

class ChatConversationWrapper extends StatelessWidget {
  const ChatConversationWrapper({super.key, required this.chatUser});

  final ChatModel chatUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatConversationAppBar(chatUser: chatUser),
      body: SafeArea(
        child: ClarityMask(
          child: Column(
            children: [
              Expanded(child: ChatMessageList(chatUser: chatUser)),
              const NewMessageTextField(),
            ],
          ),
        ),
      ),
    );
  }
}
