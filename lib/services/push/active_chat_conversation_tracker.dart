/// Stores the chat conversation currently visible in the app.
///
/// This intentionally has no Firebase dependency: router observers run while
/// the initial navigator is built, before asynchronous app startup completes.
class ActiveChatConversationTracker {
  ActiveChatConversationTracker._();

  static final ActiveChatConversationTracker instance =
      ActiveChatConversationTracker._();

  int? _conversationId;

  int? get conversationId => _conversationId;

  void setConversationId(int? conversationId) {
    _conversationId = conversationId;
  }
}
