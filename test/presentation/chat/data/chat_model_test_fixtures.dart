Map<String, dynamic> listingJson({bool includeOptional = true}) {
  final json = <String, dynamic>{
    'id': 42,
    'title': 'Sunny apartment',
    'is_available': true,
  };
  if (includeOptional) {
    json.addAll({
      'cover_image_url': 'https://example.com/listing.jpg',
      'price': 650.0,
      'currency': 'USD',
    });
  }
  return json;
}

Map<String, dynamic> conversationStateJson({
  bool isReadOnly = false,
  int? lastMessageId = 9,
  int? peerLastReadMessageId = 8,
}) => {
  'id': 42,
  'is_read_only': isReadOnly,
  'deleted_by_peer': false,
  'is_blocked': isReadOnly,
  'is_archived': false,
  'is_muted': false,
  'unread_count': 2,
  'last_message_id': lastMessageId,
  'peer_last_read_message_id': peerLastReadMessageId,
  'listing_is_available': true,
};

// ChatDateSeparator labels a message "Today"/"Yesterday" relative to
// DateTime.now() and falls back to an absolute 'MMM d' otherwise, so this date
// must stay far enough in the past for the golden label to be stable.
Map<String, dynamic> messageJson({
  int id = 9,
  String kind = 'text',
  String? imageUrl,
  String? clientId = 'client-9',
}) => {
  'id': id,
  'conversation_id': 42,
  'sender_id': 7,
  'sender_side': 'user',
  'is_mine': true,
  'kind': kind,
  'text': kind == 'text' ? 'Hello' : null,
  'image_url': imageUrl,
  'image_width': kind == 'image' ? 800 : null,
  'image_height': kind == 'image' ? 600 : null,
  'client_id': clientId,
  'is_read': false,
  'created_at': '2026-01-15T10:00:00.000Z',
};

Map<String, dynamic> conversationJson() => {
  ...conversationStateJson(),
  'listing': listingJson(),
  'last_message_preview': 'Hello',
  'last_message_kind': 'text',
  'last_message_at': '2026-08-09T10:00:00.000Z',
  'updated_at': '2026-08-09T10:00:00.000Z',
};

Map<String, dynamic> messagesPageJson() => {
  'messages': [messageJson()],
  'has_more': true,
  'conversation': conversationStateJson(),
};

Map<String, dynamic> conversationsPageJson() => {
  'count': 1,
  'num_pages': 1,
  'per_page': 20,
  'page': {
    'number': 1,
    'object_list': [conversationJson()],
  },
};

Map<String, dynamic> summaryJson() => {
  'total_unread': 2,
  'changed_conversation_ids': [42],
  'server_time': '2026-08-09T10:00:00.000Z',
};
