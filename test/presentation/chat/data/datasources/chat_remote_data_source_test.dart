import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/chat/data/datasources/chat_remote_data_source.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:mocktail/mocktail.dart';

import '../chat_model_test_fixtures.dart';

class MockDio extends Mock implements Dio {}

class MockCacheManager extends Mock implements CacheManager {}

Response<dynamic> _response(String path, int statusCode, dynamic data) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: path),
    statusCode: statusCode,
    data: data,
  );
}

Map<String, dynamic> _envelope(dynamic data, {bool success = true}) => {
  'success': success,
  'message': success ? 'OK' : 'No chat',
  'data': data,
};

void main() {
  late MockDio dio;
  late MockCacheManager cacheManager;
  late ChatRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = MockDio();
    cacheManager = MockCacheManager();
    when(
      () => cacheManager.noCacheOptions(),
    ).thenReturn(CacheOptions(store: MemCacheStore()));
    dataSource = ChatRemoteDataSourceImpl(dio, cacheManager);
  });

  test('opens a conversation and accepts HTTP 201', () async {
    const path = '/mobile/chat/conversations/';
    when(
      () => dio.post(
        path,
        data: {'listing_id': 42},
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _response(path, 201, _envelope(conversationJson())),
    );

    final result = await dataSource.openConversation(listingId: 42);

    expect(result.id, 42);
    verify(() => cacheManager.noCacheOptions()).called(1);
  });

  test('uses exact after cursor and limit query parameters', () async {
    const path = '/mobile/chat/conversations/42/messages/';
    when(
      () => dio.get(
        path,
        queryParameters: {'after_id': 9, 'limit': 50},
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _response(path, 200, _envelope(messagesPageJson())),
    );

    final result = await dataSource.getMessages(
      conversationId: 42,
      afterId: 9,
      limit: 50,
    );

    expect(result.messages.single.id, 9);
    verify(
      () => dio.get(
        path,
        queryParameters: {'after_id': 9, 'limit': 50},
        options: any(named: 'options'),
      ),
    ).called(1);
  });

  test('uses exact before cursor query parameters', () async {
    const path = '/mobile/chat/conversations/42/messages/';
    when(
      () => dio.get(
        path,
        queryParameters: {'before_id': 9, 'limit': 30},
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _response(path, 200, _envelope(messagesPageJson())),
    );

    await dataSource.getMessages(conversationId: 42, beforeId: 9, limit: 30);

    verify(
      () => dio.get(
        path,
        queryParameters: {'before_id': 9, 'limit': 30},
        options: any(named: 'options'),
      ),
    ).called(1);
  });

  test('unwraps an unsuccessful envelope as APIException', () async {
    const path = '/mobile/chat/summary/';
    when(
      () => dio.get(
        path,
        queryParameters: <String, dynamic>{},
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _response(path, 200, _envelope(null, success: false)),
    );

    await expectLater(
      dataSource.getChatSummary(),
      throwsA(
        isA<APIException>().having(
          (error) => error.message,
          'message',
          'No chat',
        ),
      ),
    );
  });

  test('sends a multipart field named image', () async {
    const path = '/mobile/chat/conversations/42/messages/image/';
    final image = File('assets/test/images/test_image.jpeg');
    when(
      () => dio.post(
        path,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _response(
        path,
        201,
        _envelope(
          messageJson(kind: 'image', imageUrl: 'https://example.com/photo.jpg'),
        ),
      ),
    );

    await dataSource.sendImageMessage(
      conversationId: 42,
      image: image,
      clientId: 'client-image',
    );

    final captured =
        verify(
              () => dio.post(
                path,
                data: captureAny(named: 'data'),
                options: any(named: 'options'),
              ),
            ).captured.single
            as FormData;
    expect(captured.files.any((entry) => entry.key == 'image'), isTrue);
    expect(
      captured.fields.any(
        (entry) => entry.key == 'client_id' && entry.value == 'client-image',
      ),
      isTrue,
    );
    verify(() => cacheManager.noCacheOptions()).called(1);
  });

  test('sends a read receipt with the cursor message id', () async {
    const path = '/mobile/chat/conversations/42/read/';
    when(
      () => dio.post(
        path,
        data: {'up_to_message_id': 9},
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _response(path, 200, _envelope(conversationStateJson())),
    );

    final result = await dataSource.markConversationRead(
      conversationId: 42,
      upToMessageId: 9,
    );

    expect(result.id, 42);
  });
}
