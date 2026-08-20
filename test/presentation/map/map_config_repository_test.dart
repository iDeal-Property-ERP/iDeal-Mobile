import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/map/data/datasources/map_config_remote_data_source.dart';
import 'package:ideal_mobile/presentation/map/data/models/map_config_response_model.dart';
import 'package:ideal_mobile/presentation/map/data/repositories/map_config_repository_impl.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:ideal_mobile/utils/map_token_obfuscator.dart';
import 'package:mocktail/mocktail.dart';

class _MockMapConfigRemoteDataSource extends Mock
    implements MapConfigRemoteDataSource {}

class _MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late _MockMapConfigRemoteDataSource mockRemoteDataSource;
  late _MockSecureStorageService mockStorageService;
  late MapConfigRepositoryImpl repository;

  final inMemoryStorage = <String, String>{};

  setUp(() {
    mockRemoteDataSource = _MockMapConfigRemoteDataSource();
    mockStorageService = _MockSecureStorageService();

    inMemoryStorage.clear();

    when(() => mockStorageService.setString(any(), any())).thenAnswer((
      invocation,
    ) async {
      final key = invocation.positionalArguments[0] as String;
      final val = invocation.positionalArguments[1] as String;
      inMemoryStorage[key] = val;
    });

    when(() => mockStorageService.getString(any())).thenAnswer((
      invocation,
    ) async {
      final key = invocation.positionalArguments[0] as String;
      return inMemoryStorage[key];
    });

    repository = MapConfigRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      storageService: mockStorageService,
      cacheTtl: const Duration(hours: 1),
    );
  });

  group('MapConfigRepositoryImpl', () {
    test('fetches from remote, deobfuscates, and caches in storage', () async {
      const rawToken = 'test-yandex-token-12345';
      final obfuscated = MapTokenObfuscator.obfuscate(rawToken);

      when(() => mockRemoteDataSource.getMapConfig()).thenAnswer(
        (_) async => MapConfigResponseModel(
          provider: PropertyMapProvider.yandex,
          token: obfuscated,
        ),
      );

      final config = await repository.getMapConfig();

      expect(config.provider, PropertyMapProvider.yandex);
      expect(config.token, rawToken);
      expect(inMemoryStorage['map_cached_provider'], 'yandex');
      expect(inMemoryStorage['map_cached_token'], rawToken);
      expect(repository.memoryCache?.token, rawToken);

      verify(() => mockRemoteDataSource.getMapConfig()).called(1);
    });

    test('returns in-memory cache without hitting remote when valid', () async {
      const rawToken = 'test-token';
      final obfuscated = MapTokenObfuscator.obfuscate(rawToken);

      when(() => mockRemoteDataSource.getMapConfig()).thenAnswer(
        (_) async => MapConfigResponseModel(
          provider: PropertyMapProvider.yandex,
          token: obfuscated,
        ),
      );

      final first = await repository.getMapConfig();
      final second = await repository.getMapConfig();

      expect(first, second);
      verify(() => mockRemoteDataSource.getMapConfig()).called(1);
    });

    test('forceRefresh bypasses in-memory cache', () async {
      const rawToken = 'test-token';
      final obfuscated = MapTokenObfuscator.obfuscate(rawToken);

      when(() => mockRemoteDataSource.getMapConfig()).thenAnswer(
        (_) async => MapConfigResponseModel(
          provider: PropertyMapProvider.yandex,
          token: obfuscated,
        ),
      );

      await repository.getMapConfig();
      await repository.getMapConfig(forceRefresh: true);

      verify(() => mockRemoteDataSource.getMapConfig()).called(2);
    });

    test('falls back to storage when remote call fails', () async {
      inMemoryStorage['map_cached_provider'] = 'google';
      inMemoryStorage['map_cached_token'] = 'persisted-google-token';
      inMemoryStorage['map_cached_fetched_at'] = DateTime.now()
          .toIso8601String();

      when(
        () => mockRemoteDataSource.getMapConfig(),
      ).thenThrow(Exception('Network error'));

      final config = await repository.getMapConfig();

      expect(config.provider, PropertyMapProvider.google);
      expect(config.token, 'persisted-google-token');
    });
  });
}
