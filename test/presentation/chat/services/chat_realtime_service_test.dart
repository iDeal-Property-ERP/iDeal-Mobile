import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/chat/services/chat_realtime_service.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockWebSocketChannel extends Mock implements WebSocketChannel {}

class MockWebSocketSink extends Mock implements WebSocketSink {}

void main() {
  late MockSecureStorageService mockStorage;

  setUpAll(() {
    dotenv.loadFromString(
      envString: '''
LOCAL_API_BASE_URL=https://test.i-deal.uz/api/v1
DEV_API_BASE_URL=https://test.i-deal.uz/api/v1
PROD_API_BASE_URL=https://test.i-deal.uz/api/v1
''',
    );
  });

  setUp(() {
    mockStorage = MockSecureStorageService();
  });

  test('does not connect when access token is empty', () async {
    when(() => mockStorage.getAccessToken()).thenAnswer((_) async => null);

    var factoryCalled = false;
    final service = ChatRealtimeService(
      mockStorage,
      channelFactory: (uri, headers) {
        factoryCalled = true;
        final channel = MockWebSocketChannel();
        when(() => channel.ready).thenAnswer((_) async {});
        when(() => channel.stream).thenAnswer((_) => const Stream.empty());
        return channel;
      },
    );

    await service.connect();
    expect(factoryCalled, isFalse);
    await service.dispose();
  });

  test('coalesces concurrent connection attempts', () async {
    final token = Completer<String?>();
    when(() => mockStorage.getAccessToken()).thenAnswer((_) => token.future);

    final incomingStream = StreamController<String>();
    final mockChannel = MockWebSocketChannel();
    final mockSink = MockWebSocketSink();
    when(() => mockSink.close(any(), any())).thenAnswer((_) async {});
    when(() => mockChannel.ready).thenAnswer((_) async {});
    when(() => mockChannel.stream).thenAnswer((_) => incomingStream.stream);
    when(() => mockChannel.sink).thenReturn(mockSink);

    var factoryCalls = 0;
    final service = ChatRealtimeService(
      mockStorage,
      channelFactory: (uri, headers) {
        factoryCalls += 1;
        return mockChannel;
      },
    );

    final first = service.connect();
    final second = service.connect();
    token.complete('valid-token');
    await Future.wait([first, second]);

    expect(factoryCalls, 1);
    verify(() => mockStorage.getAccessToken()).called(1);

    await service.dispose();
    await incomingStream.close();
  });

  test('does not open a socket after moving to background', () async {
    final token = Completer<String?>();
    when(() => mockStorage.getAccessToken()).thenAnswer((_) => token.future);

    var factoryCalled = false;
    final service = ChatRealtimeService(
      mockStorage,
      channelFactory: (uri, headers) {
        factoryCalled = true;
        return MockWebSocketChannel();
      },
    );

    final connection = service.connect();
    service.setForeground(value: false);
    token.complete('valid-token');
    await connection;

    expect(factoryCalled, isFalse);
    await service.dispose();
  });

  test('connects and handles chat.ready event by syncing cursor', () async {
    when(
      () => mockStorage.getAccessToken(),
    ).thenAnswer((_) async => 'valid-token');

    final incomingStream = StreamController<String>();
    final mockSink = MockWebSocketSink();
    final mockChannel = MockWebSocketChannel();
    final sentMessages = <dynamic>[];

    when(() => mockSink.add(any())).thenAnswer((invocation) {
      sentMessages.add(invocation.positionalArguments.first);
    });
    when(() => mockSink.close(any(), any())).thenAnswer((_) async {});
    when(() => mockChannel.ready).thenAnswer((_) async {});
    when(() => mockChannel.stream).thenAnswer((_) => incomingStream.stream);
    when(() => mockChannel.sink).thenReturn(mockSink);

    Uri? connectedUri;
    Map<String, dynamic>? connectedHeaders;

    final service = ChatRealtimeService(
      mockStorage,
      channelFactory: (uri, headers) {
        connectedUri = uri;
        connectedHeaders = headers;
        return mockChannel;
      },
    );

    await service.connect();

    expect(connectedUri?.scheme, 'wss');
    expect(connectedUri?.path, '/ws/v1/chat/');
    expect(connectedHeaders?['Authorization'], 'Bearer valid-token');
    expect(connectedHeaders?['Origin'], 'https://test.i-deal.uz');

    incomingStream.add(jsonEncode({'type': 'chat.ready'}));
    await Future<void>.delayed(Duration.zero);

    expect(sentMessages, isNotEmpty);
    final syncPayload = jsonDecode(sentMessages.first as String);
    expect(syncPayload['type'], 'chat.sync');
    expect(syncPayload['after_event_id'], 0);

    await service.dispose();
    await incomingStream.close();
  });

  test('gracefully handles connection failure '
      'without throwing unhandled exception', () async {
    when(
      () => mockStorage.getAccessToken(),
    ).thenAnswer((_) async => 'valid-token');

    final mockChannel = MockWebSocketChannel();
    final mockSink = MockWebSocketSink();
    when(() => mockSink.close(any(), any())).thenAnswer((_) async {});
    when(() => mockChannel.sink).thenReturn(mockSink);
    when(() => mockChannel.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockChannel.ready).thenAnswer(
      (_) => Future.error(WebSocketChannelException('Handshake 404 error')),
    );

    final service = ChatRealtimeService(
      mockStorage,
      channelFactory: (uri, headers) => mockChannel,
    );

    // Must not throw or bubble unhandled exception
    await service.connect();
    await service.dispose();
  });

  test('dispatches typing indicator event', () async {
    when(
      () => mockStorage.getAccessToken(),
    ).thenAnswer((_) async => 'valid-token');

    final streamController = StreamController<String>();
    final mockChannel = MockWebSocketChannel();
    final mockSink = MockWebSocketSink();
    final sentMessages = <dynamic>[];

    when(() => mockSink.add(any())).thenAnswer((invocation) {
      sentMessages.add(invocation.positionalArguments.first);
    });
    when(() => mockSink.close(any(), any())).thenAnswer((_) async {});
    when(() => mockChannel.ready).thenAnswer((_) async {});
    when(() => mockChannel.stream).thenAnswer((_) => streamController.stream);
    when(() => mockChannel.sink).thenReturn(mockSink);

    final service = ChatRealtimeService(
      mockStorage,
      channelFactory: (uri, headers) => mockChannel,
    );

    await service.connect();
    service.setTyping(conversationId: 42, isTyping: true);

    expect(sentMessages, isNotEmpty);
    final payload = jsonDecode(sentMessages.first as String);
    expect(payload['type'], 'chat.typing.set');
    expect(payload['conversation_id'], 42);
    expect(payload['is_typing'], true);

    await service.dispose();
    await streamController.close();
  });

  test('forwards broadcast events from stream', () async {
    when(
      () => mockStorage.getAccessToken(),
    ).thenAnswer((_) async => 'valid-token');

    final incomingStream = StreamController<String>();
    final receivedEvents = <ChatRealtimeEvent>[];
    final mockChannel = MockWebSocketChannel();
    final mockSink = MockWebSocketSink();

    when(() => mockSink.close(any(), any())).thenAnswer((_) async {});
    when(() => mockChannel.ready).thenAnswer((_) async {});
    when(() => mockChannel.stream).thenAnswer((_) => incomingStream.stream);
    when(() => mockChannel.sink).thenReturn(mockSink);

    final service = ChatRealtimeService(
      mockStorage,
      channelFactory: (uri, headers) => mockChannel,
    );

    final sub = service.events.listen(receivedEvents.add);
    await service.connect();

    incomingStream.add(
      jsonEncode({
        'type': 'chat.message.created',
        'event_id': 101,
        'conversation_id': 5,
      }),
    );
    await Future<void>.delayed(Duration.zero);

    expect(receivedEvents, hasLength(1));
    expect(receivedEvents.first.type, 'chat.message.created');
    expect(receivedEvents.first.eventId, 101);
    expect(receivedEvents.first.conversationId, 5);

    await sub.cancel();
    await service.dispose();
    await incomingStream.close();
  });
}
