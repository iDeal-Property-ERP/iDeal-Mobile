import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderSide,
    required this.isMine,
    required this.kind,
    required this.text,
    required this.imageUrl,
    this.imagePreviewUrl,
    this.imageDisplayUrl,
    required this.imageWidth,
    required this.imageHeight,
    required this.clientId,
    required this.isRead,
    required this.createdAt,
  });

  final int id;
  final int conversationId;
  final int senderId;
  final String senderSide;
  final bool isMine;
  final String kind;
  final String? text;
  final String? imageUrl;
  final String? imagePreviewUrl;
  final String? imageDisplayUrl;
  final int? imageWidth;
  final int? imageHeight;
  final String? clientId;
  final bool isRead;
  final DateTime createdAt;

  bool get isImage => kind == 'image';

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    senderSide,
    isMine,
    kind,
    text,
    imageUrl,
    imagePreviewUrl,
    imageDisplayUrl,
    imageWidth,
    imageHeight,
    clientId,
    isRead,
    createdAt,
  ];
}
