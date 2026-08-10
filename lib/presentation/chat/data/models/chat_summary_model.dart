import 'package:ideal_mobile/presentation/chat/data/models/chat_model_parsing.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_summary.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ChatSummaryModel extends ChatSummary {
  const ChatSummaryModel({
    required super.totalUnread,
    required super.changedConversationIds,
    required super.serverTime,
  });

  factory ChatSummaryModel.fromJson(DataMap json) {
    final ids = requiredList(json, 'changed_conversation_ids')
        .map((value) {
          final parsed = nullableInt(value);
          if (parsed == null) {
            throw const FormatException('Invalid changed conversation id.');
          }
          return parsed;
        })
        .toList(growable: false);
    return ChatSummaryModel(
      totalUnread: requiredInt(json, 'total_unread'),
      changedConversationIds: ids,
      serverTime: requiredDateTime(json, 'server_time'),
    );
  }

  DataMap toJson() => {
    'total_unread': totalUnread,
    'changed_conversation_ids': changedConversationIds,
    'server_time': serverTime.toIso8601String(),
  };
}
