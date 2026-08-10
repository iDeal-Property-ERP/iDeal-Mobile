import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_summary.dart';
import 'package:ideal_mobile/presentation/chat/domain/repositories/listing_chat_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class GetChatSummary with UseCaseWithParams<ChatSummary, GetChatSummaryParams> {
  const GetChatSummary(this._repository);

  final ListingChatRepository _repository;

  @override
  ResultFuture<ChatSummary> call(GetChatSummaryParams params) {
    return _repository.getChatSummary(since: params.since);
  }
}

class GetChatSummaryParams extends Equatable {
  const GetChatSummaryParams({this.since});

  final DateTime? since;

  @override
  List<Object?> get props => [since];
}
