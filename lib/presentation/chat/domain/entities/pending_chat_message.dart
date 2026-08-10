import 'package:equatable/equatable.dart';

enum ChatMessageStatus { sending, sent, read, failed }

class PendingChatMessage extends Equatable {
  const PendingChatMessage({
    required this.clientId,
    required this.text,
    required this.localPath,
    required this.createdAt,
    required this.status,
  });

  final String clientId;
  final String? text;
  final String? localPath;
  final DateTime createdAt;
  final ChatMessageStatus status;

  bool get isImage => localPath != null;

  PendingChatMessage copyWith({ChatMessageStatus? status}) {
    return PendingChatMessage(
      clientId: clientId,
      text: text,
      localPath: localPath,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [clientId, text, localPath, createdAt, status];
}
