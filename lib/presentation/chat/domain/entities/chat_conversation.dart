import 'package:ideal_mobile/presentation/chat/domain/entities/chat_conversation_state.dart';
import 'package:ideal_mobile/presentation/chat/domain/entities/chat_listing_ref.dart';

class ChatConversation extends ChatConversationState {
  const ChatConversation({
    required super.id,
    required super.isReadOnly,
    required super.deletedByPeer,
    required super.isBlocked,
    required super.isArchived,
    required super.isMuted,
    required super.unreadCount,
    required super.lastMessageId,
    required super.peerLastReadMessageId,
    required super.listingIsAvailable,
    required this.listing,
    required this.lastMessagePreview,
    required this.lastMessageKind,
    required this.lastMessageAt,
    required this.updatedAt,
  });

  final ChatListingRef listing;
  final String? lastMessagePreview;
  final String? lastMessageKind;
  final DateTime? lastMessageAt;
  final DateTime updatedAt;

  ChatConversation copyWith({
    ChatListingRef? listing,
    String? lastMessagePreview,
    String? lastMessageKind,
    DateTime? lastMessageAt,
    DateTime? updatedAt,
    bool? isReadOnly,
    bool? deletedByPeer,
    bool? isBlocked,
    bool? isArchived,
    bool? isMuted,
    int? unreadCount,
    int? lastMessageId,
    int? peerLastReadMessageId,
    bool? listingIsAvailable,
  }) {
    return ChatConversation(
      id: id,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      deletedByPeer: deletedByPeer ?? this.deletedByPeer,
      isBlocked: isBlocked ?? this.isBlocked,
      isArchived: isArchived ?? this.isArchived,
      isMuted: isMuted ?? this.isMuted,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      peerLastReadMessageId:
          peerLastReadMessageId ?? this.peerLastReadMessageId,
      listingIsAvailable: listingIsAvailable ?? this.listingIsAvailable,
      listing: listing ?? this.listing,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageKind: lastMessageKind ?? this.lastMessageKind,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    listing,
    lastMessagePreview,
    lastMessageKind,
    lastMessageAt,
    updatedAt,
  ];
}
