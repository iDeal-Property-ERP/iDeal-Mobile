import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_parser/http_parser.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_conversation_model.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_conversation_state_model.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_conversations_page_model.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_message_model.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_messages_page_model.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_summary_model.dart';
import 'package:ideal_mobile/utils/cache_manager.dart';
import 'package:ideal_mobile/utils/typedef.dart';
import 'package:mime/mime.dart';

abstract class ChatRemoteDataSource {
  Future<ChatConversationModel> openConversation({required int listingId});

  Future<ChatConversationsPageModel> getConversations({
    required bool archived,
    required int page,
    required int perPage,
  });

  Future<ChatSummaryModel> getChatSummary({DateTime? since});

  Future<ChatConversationModel> getConversation({required int id});

  Future<ChatMessagesPageModel> getMessages({
    required int conversationId,
    int? afterId,
    int? beforeId,
    required int limit,
  });

  Future<ChatMessageModel> sendTextMessage({
    required int conversationId,
    required String text,
    required String clientId,
  });

  Future<ChatMessageModel> sendImageMessage({
    required int conversationId,
    required File image,
    required String clientId,
  });

  Future<ChatConversationStateModel> markConversationRead({
    required int conversationId,
    int? upToMessageId,
  });

  Future<ChatConversationStateModel> setConversationArchived({
    required int conversationId,
    required bool value,
  });

  Future<ChatConversationStateModel> setConversationMuted({
    required int conversationId,
    required bool value,
  });

  Future<void> reportConversation({
    required int conversationId,
    required String reason,
    String? note,
  });

  Future<void> deleteConversation({required int conversationId});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  const ChatRemoteDataSourceImpl(this._dio, this._cacheManager);

  static const _basePath = '/mobile/chat';

  final Dio _dio;
  final CacheManager _cacheManager;

  Options get _noCache => _cacheManager.noCacheOptions().toOptions();

  @override
  Future<ChatConversationModel> openConversation({
    required int listingId,
  }) async {
    final response = await _request(
      () => _dio.post(
        '$_basePath/conversations/',
        data: {'listing_id': listingId},
        options: _noCache,
      ),
    );
    final data = _dataFromResponse(response, accepted: {200, 201});
    return _parse(response, data, ChatConversationModel.fromJson);
  }

  @override
  Future<ChatConversationsPageModel> getConversations({
    required bool archived,
    required int page,
    required int perPage,
  }) async {
    final response = await _request(
      () => _dio.get(
        '$_basePath/conversations/',
        queryParameters: {
          'archived': archived,
          'page': page,
          'per_page': perPage,
        },
        options: _noCache,
      ),
    );
    final data = _dataFromResponse(response);
    return _parse(response, data, ChatConversationsPageModel.fromJson);
  }

  @override
  Future<ChatSummaryModel> getChatSummary({DateTime? since}) async {
    final query = <String, dynamic>{};
    if (since != null) query['since'] = since.toUtc().toIso8601String();
    final response = await _request(
      () => _dio.get(
        '$_basePath/summary/',
        queryParameters: query,
        options: _noCache,
      ),
    );
    final data = _dataFromResponse(response);
    return _parse(response, data, ChatSummaryModel.fromJson);
  }

  @override
  Future<ChatConversationModel> getConversation({required int id}) async {
    final response = await _request(
      () => _dio.get('$_basePath/conversations/$id/', options: _noCache),
    );
    final data = _dataFromResponse(response);
    return _parse(response, data, ChatConversationModel.fromJson);
  }

  @override
  Future<ChatMessagesPageModel> getMessages({
    required int conversationId,
    int? afterId,
    int? beforeId,
    required int limit,
  }) async {
    if (afterId != null && beforeId != null) {
      throw const APIException(
        message: 'Only one message cursor can be used.',
        statusCode: 400,
      );
    }
    final query = <String, dynamic>{'limit': limit};
    if (afterId != null) query['after_id'] = afterId;
    if (beforeId != null) query['before_id'] = beforeId;
    final response = await _request(
      () => _dio.get(
        '$_basePath/conversations/$conversationId/messages/',
        queryParameters: query,
        options: _noCache,
      ),
    );
    final data = _dataFromResponse(response);
    return _parse(response, data, ChatMessagesPageModel.fromJson);
  }

  @override
  Future<ChatMessageModel> sendTextMessage({
    required int conversationId,
    required String text,
    required String clientId,
  }) async {
    final response = await _request(
      () => _dio.post(
        '$_basePath/conversations/$conversationId/messages/',
        data: {'text': text, 'client_id': clientId},
        options: _noCache,
      ),
    );
    final data = _dataFromResponse(response, accepted: {200, 201});
    return _parse(response, data, ChatMessageModel.fromJson);
  }

  @override
  Future<ChatMessageModel> sendImageMessage({
    required int conversationId,
    required File image,
    required String clientId,
  }) async {
    final mime = lookupMimeType(image.path) ?? 'application/octet-stream';
    final multipart = await MultipartFile.fromFile(
      image.path,
      contentType: MediaType.parse(mime),
    );
    final response = await _request(
      () => _dio.post(
        '$_basePath/conversations/$conversationId/messages/image/',
        data: FormData.fromMap({'image': multipart, 'client_id': clientId}),
        options: _noCache,
      ),
    );
    final data = _dataFromResponse(response, accepted: {200, 201});
    return _parse(response, data, ChatMessageModel.fromJson);
  }

  @override
  Future<ChatConversationStateModel> markConversationRead({
    required int conversationId,
    int? upToMessageId,
  }) async {
    final response = await _request(
      () => _dio.post(
        '$_basePath/conversations/$conversationId/read/',
        data: {'up_to_message_id': upToMessageId},
        options: _noCache,
      ),
    );
    final data = _dataFromResponse(response);
    return _parse(response, data, ChatConversationStateModel.fromJson);
  }

  @override
  Future<ChatConversationStateModel> setConversationArchived({
    required int conversationId,
    required bool value,
  }) async {
    final suffix = value ? 'archive' : 'unarchive';
    return _setState(conversationId: conversationId, suffix: suffix);
  }

  @override
  Future<ChatConversationStateModel> setConversationMuted({
    required int conversationId,
    required bool value,
  }) async {
    final suffix = value ? 'mute' : 'unmute';
    return _setState(conversationId: conversationId, suffix: suffix);
  }

  Future<ChatConversationStateModel> _setState({
    required int conversationId,
    required String suffix,
  }) async {
    final response = await _request(
      () => _dio.post(
        '$_basePath/conversations/$conversationId/$suffix/',
        options: _noCache,
      ),
    );
    final data = _dataFromResponse(response);
    return _parse(response, data, ChatConversationStateModel.fromJson);
  }

  @override
  Future<void> reportConversation({
    required int conversationId,
    required String reason,
    String? note,
  }) async {
    final response = await _request(
      () => _dio.post(
        '$_basePath/conversations/$conversationId/report/',
        data: {'reason': reason, 'note': note},
        options: _noCache,
      ),
    );
    _dataFromResponse(response, accepted: {200, 201});
  }

  @override
  Future<void> deleteConversation({required int conversationId}) async {
    final response = await _request(
      () => _dio.delete(
        '$_basePath/conversations/$conversationId/',
        options: _noCache,
      ),
    );
    _dataFromResponse(response);
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw APIException(
        message:
            _messageFromData(error.response?.data) ??
            error.message ??
            'Request failed.',
        statusCode: error.response?.statusCode ?? 505,
      );
    } on APIException {
      rethrow;
    } catch (error) {
      throw APIException(message: error.toString(), statusCode: 505);
    }
  }

  DataMap _dataFromResponse(
    Response<dynamic> response, {
    Set<int> accepted = const {200},
  }) {
    final body = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
    if (!accepted.contains(response.statusCode) || body['success'] != true) {
      throw APIException(
        message: _messageFromData(response.data) ?? 'Request failed.',
        statusCode: response.statusCode ?? 500,
      );
    }
    final data = body['data'];
    if (data is! Map) {
      throw APIException(
        message: 'Chat response data was not returned.',
        statusCode: response.statusCode ?? 500,
      );
    }
    return Map<String, dynamic>.from(data);
  }

  T _parse<T>(
    Response<dynamic> response,
    DataMap data,
    T Function(DataMap) parser,
  ) {
    try {
      return parser(data);
    } on FormatException catch (error) {
      throw APIException(
        message: error.message,
        statusCode: response.statusCode ?? 500,
      );
    }
  }

  String? _messageFromData(dynamic data) {
    if (data is! Map) return data?.toString();
    final message = data['message'];
    return message is String && message.trim().isNotEmpty ? message : null;
  }
}
