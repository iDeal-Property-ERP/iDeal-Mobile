import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:ideal_mobile/core/services/injection_container.dart';
import 'package:ideal_mobile/i18n/localization.dart';
import 'package:ideal_mobile/presentation/ai_chat/bloc/ai_chat_bloc.dart';
import 'package:ideal_mobile/presentation/ai_chat/widgets/ai_chat_bottom_sheet.dart';
import 'package:ideal_mobile/utils/theme/extension/theme_extension.dart';

class AiChatFab extends StatefulWidget {
  const AiChatFab({super.key});

  @override
  State<AiChatFab> createState() => _AiChatFabState();
}

class _AiChatFabState extends State<AiChatFab> {
  AiChatBloc? _aiChatBloc;

  void _openChat() {
    _aiChatBloc ??= AiChatBloc(
      geminiService: sl(),
      localizations: context.localization,
    );

    showAiChatBottomSheet(context, existingBloc: _aiChatBloc!);
  }

  @override
  void dispose() {
    _aiChatBloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _openChat,
      backgroundColor: context.currentTheme.bgBrandDefault,
      elevation: 4,
      child: Icon(
        TablerIcons.message_chatbot,
        color: context.currentTheme.textNeutralLight,
      ),
    );
  }
}
