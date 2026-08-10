import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/chat/domain/repositories/listing_chat_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class ReportConversation
    with UseCaseWithParams<void, ReportConversationParams> {
  const ReportConversation(this._repository);

  final ListingChatRepository _repository;

  @override
  ResultVoid call(ReportConversationParams params) {
    return _repository.reportConversation(
      conversationId: params.conversationId,
      reason: params.reason,
      note: params.note,
    );
  }
}

class ReportConversationParams extends Equatable {
  const ReportConversationParams({
    required this.conversationId,
    required this.reason,
    this.note,
  });

  final int conversationId;
  final String reason;
  final String? note;

  @override
  List<Object?> get props => [conversationId, reason, note];
}
