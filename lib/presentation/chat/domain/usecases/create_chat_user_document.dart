import 'package:equatable/equatable.dart';
import 'package:ideal_mobile/core/usecase/usecase.dart';
import 'package:ideal_mobile/presentation/chat/domain/repositories/chat_repository.dart';
import 'package:ideal_mobile/utils/typedef.dart';

class CreateChatUserDocument
    with UseCaseWithParams<void, CreateChatUserDocumentParams> {
  const CreateChatUserDocument(this._repository);

  final ChatRepository _repository;

  @override
  ResultVoid call(CreateChatUserDocumentParams params) =>
      _repository.createUserDocument(
        userId: params.userId,
        name: params.name,
        email: params.email,
        photoUrl: params.photoUrl,
      );
}

class CreateChatUserDocumentParams extends Equatable {
  const CreateChatUserDocumentParams({
    required this.userId,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  final String userId;
  final String name;
  final String email;
  final String? photoUrl;

  @override
  List<Object?> get props => [userId, name, email, photoUrl];
}
