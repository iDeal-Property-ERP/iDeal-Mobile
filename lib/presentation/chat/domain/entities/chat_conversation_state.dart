import 'package:equatable/equatable.dart';

class ChatConversationState extends Equatable {
  const ChatConversationState({
    required this.id,
    required this.isReadOnly,
    required this.deletedByPeer,
    required this.isBlocked,
    required this.isArchived,
    required this.isMuted,
    required this.unreadCount,
    required this.lastMessageId,
    required this.peerLastReadMessageId,
    required this.listingIsAvailable,
  });

  final int id;
  final bool isReadOnly;
  final bool deletedByPeer;
  final bool isBlocked;
  final bool isArchived;
  final bool isMuted;
  final int unreadCount;
  final int? lastMessageId;
  final int? peerLastReadMessageId;
  final bool listingIsAvailable;

  @override
  List<Object?> get props => [
    id,
    isReadOnly,
    deletedByPeer,
    isBlocked,
    isArchived,
    isMuted,
    unreadCount,
    lastMessageId,
    peerLastReadMessageId,
    listingIsAvailable,
  ];
}
