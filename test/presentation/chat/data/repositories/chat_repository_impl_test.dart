import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/core/errors/exceptions.dart';
import 'package:ideal_mobile/core/errors/failure.dart';
import 'package:ideal_mobile/presentation/chat/data/datasources/chat_remote_data_source.dart';
import 'package:ideal_mobile/presentation/chat/data/models/chat_summary_model.dart';
import 'package:ideal_mobile/presentation/chat/data/repositories/listing_chat_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../chat_model_test_fixtures.dart';

class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

void main() {
  late MockChatRemoteDataSource remote;
  late ListingChatRepositoryImpl repository;

  setUp(() {
    remote = MockChatRemoteDataSource();
    repository = ListingChatRepositoryImpl(remote);
  });

  test('maps a successful datasource result to Right', () async {
    when(
      () => remote.getChatSummary(since: null),
    ).thenAnswer((_) async => ChatSummaryModel.fromJson(summaryJson()));

    final result = await repository.getChatSummary();

    expect(result, isA<Right>());
    expect(result.getOrElse(() => throw StateError('missing')).totalUnread, 2);
  });

  test('maps APIException to Left APIFailure', () async {
    when(
      () => remote.getChatSummary(since: null),
    ).thenThrow(const APIException(message: 'Unavailable', statusCode: 503));

    final result = await repository.getChatSummary();

    expect(result, isA<Left>());
    expect(result.fold((failure) => failure, (_) => null), isA<APIFailure>());
    expect(result.fold((failure) => failure.statusCode, (_) => 0), 503);
  });
}
