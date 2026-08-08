import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/chat/domain/repositories/chat_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class DeleteChatUserDocument
    with UseCaseWithParams<void, DeleteChatUserDocumentParams> {
  const DeleteChatUserDocument(this._repository);

  final ChatRepository _repository;

  @override
  ResultVoid call(DeleteChatUserDocumentParams params) =>
      _repository.deleteUserDocument(userId: params.userId);
}

class DeleteChatUserDocumentParams extends Equatable {
  const DeleteChatUserDocumentParams({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}
