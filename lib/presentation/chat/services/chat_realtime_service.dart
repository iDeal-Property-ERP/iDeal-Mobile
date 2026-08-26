import 'dart:async';
import 'dart:convert';

import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:ideal_mobile/utils/app_flavor_env.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatRealtimeEvent {
  const ChatRealtimeEvent({
    required this.type,
    this.eventId,
    this.conversationId,
  });

  final String type;
  final int? eventId;
  final int? conversationId;

  factory ChatRealtimeEvent.fromJson(Map<String, dynamic> json) {
    final eventId = json['event_id'];
    final conversationId = json['conversation_id'];
    return ChatRealtimeEvent(
      type: json['type'] as String? ?? '',
      eventId: eventId is int ? eventId : null,
      conversationId: conversationId is int ? conversationId : null,
    );
  }
}

typedef WebSocketChannelFactory =
    WebSocketChannel Function(Uri uri, Map<String, dynamic>? headers);

/// Owns one authenticated, replayable chat socket for the active app process.
class ChatRealtimeService {
  ChatRealtimeService(this._storage, {WebSocketChannelFactory? channelFactory})
    : _channelFactory = channelFactory;

  final SecureStorageService _storage;
  final WebSocketChannelFactory? _channelFactory;
  final _events = StreamController<ChatRealtimeEvent>.broadcast();
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _heartbeat;
  Timer? _reconnect;
  int _cursor = 0;
  int _attempts = 0;
  bool _connecting = false;
  bool _foreground = true;
  bool _disposed = false;

  Stream<ChatRealtimeEvent> get events => _events.stream;

  static WebSocketChannel _defaultChannelFactory(
    Uri uri,
    Map<String, dynamic>? headers,
  ) {
    return IOWebSocketChannel.connect(uri, headers: headers);
  }

  Future<void> connect() async {
    if (_disposed || !_foreground || _channel != null || _connecting) return;
    _connecting = true;
    try {
      final accessToken = await _storage.getAccessToken();
      if (_disposed || !_foreground || _channel != null) return;
      if (accessToken == null || accessToken.trim().isEmpty) return;
      final baseUri = Uri.tryParse(AppConfig.baseUrl);
      if (baseUri == null || baseUri.host.isEmpty) return;
      final scheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
      final uri = baseUri.replace(scheme: scheme, path: '/ws/v1/chat/');

      final factory = _channelFactory ?? _defaultChannelFactory;
      final channel = factory(uri, {
        'Authorization': 'Bearer $accessToken',
        'Origin': baseUri.origin,
      });
      _channel = channel;
      _subscription = channel.stream.listen(
        _onMessage,
        onDone: _onDisconnected,
        onError: (_, _) => _onDisconnected(),
        cancelOnError: true,
      );
      await channel.ready;
    } catch (_) {
      _onDisconnected();
    } finally {
      _connecting = false;
    }
  }

  void setForeground({required bool value}) {
    _foreground = value;
    if (!value) {
      _closeSocket();
      return;
    }
    unawaited(connect());
  }

  void setTyping({required int conversationId, required bool isTyping}) {
    _send({
      'type': 'chat.typing.set',
      'conversation_id': conversationId,
      'is_typing': isTyping,
    });
  }

  void _onMessage(dynamic raw) {
    if (raw is! String) return;
    final decoded = _tryDecode(raw);
    if (decoded == null) return;
    final event = ChatRealtimeEvent.fromJson(decoded);
    if (event.type == 'chat.ready') {
      _attempts = 0;
      _send({'type': 'chat.sync', 'after_event_id': _cursor});
      _heartbeat ??= Timer.periodic(
        const Duration(seconds: 25),
        (_) => _send({'type': 'chat.ping', 'last_event_id': _cursor}),
      );
      return;
    }
    if (event.type == 'chat.resync_required') {
      _cursor = 0;
      _events.add(event);
      return;
    }
    final eventId = event.eventId;
    if (eventId != null) {
      if (eventId <= _cursor) return;
      _cursor = eventId;
    }
    if (event.type != 'chat.pong' && event.type != 'chat.error') {
      _events.add(event);
    }
  }

  Map<String, dynamic>? _tryDecode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } on FormatException {
      return null;
    }
  }

  void _onDisconnected() {
    _heartbeat?.cancel();
    _heartbeat = null;
    unawaited(_subscription?.cancel() ?? Future<void>.value());
    _subscription = null;
    unawaited(_channel?.sink.close() ?? Future<void>.value());
    _channel = null;
    if (_disposed || !_foreground || _reconnect != null) return;
    _attempts += 1;
    final exponent = _attempts.clamp(0, 5);
    final seconds = (1 << exponent).clamp(1, 30);
    _reconnect = Timer(Duration(seconds: seconds), () {
      _reconnect = null;
      unawaited(connect());
    });
  }

  void _send(Map<String, dynamic> value) {
    try {
      _channel?.sink.add(jsonEncode(value));
    } catch (_) {}
  }

  void _closeSocket() {
    _heartbeat?.cancel();
    _heartbeat = null;
    _reconnect?.cancel();
    _reconnect = null;
    unawaited(_subscription?.cancel() ?? Future<void>.value());
    _subscription = null;
    unawaited(_channel?.sink.close() ?? Future<void>.value());
    _channel = null;
  }

  Future<void> dispose() async {
    _disposed = true;
    _closeSocket();
    await _events.close();
  }
}
