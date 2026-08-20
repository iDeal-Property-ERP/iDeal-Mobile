import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/presentation/map/data/datasources/map_config_remote_data_source.dart';
import 'package:ideal_mobile/presentation/map/domain/entities/map_config.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
import 'package:ideal_mobile/presentation/map/domain/repositories/map_config_repository.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:ideal_mobile/utils/app_flavor_env.dart';
import 'package:ideal_mobile/utils/map_token_obfuscator.dart';

class MapConfigRepositoryImpl implements MapConfigRepository {
  MapConfigRepositoryImpl({
    required MapConfigRemoteDataSource remoteDataSource,
    SecureStorageService? storageService,
    this.cacheTtl = const Duration(hours: 24),
  }) : _remoteDataSource = remoteDataSource,
       _storageService = storageService ?? SecureStorageService();

  static const _providerStorageKey = 'map_cached_provider';
  static const _tokenStorageKey = 'map_cached_token';
  static const _fetchedAtStorageKey = 'map_cached_fetched_at';

  final MapConfigRemoteDataSource _remoteDataSource;
  final SecureStorageService _storageService;
  final Duration cacheTtl;

  PropertyMapConfig? _memoryCache;

  @visibleForTesting
  PropertyMapConfig? get memoryCache => _memoryCache;

  @visibleForTesting
  void setMemoryCache(PropertyMapConfig? config) => _memoryCache = config;

  @override
  Future<PropertyMapConfig> getMapConfig({bool forceRefresh = false}) async {
    final cached = _memoryCache;
    if (!forceRefresh && cached != null && !cached.isExpired(ttl: cacheTtl)) {
      return cached;
    }

    try {
      final remote = await _remoteDataSource.getMapConfig();
      final deobfuscatedToken = remote.token.isNotEmpty
          ? MapTokenObfuscator.deobfuscate(remote.token)
          : '';

      final now = DateTime.now();
      final config = PropertyMapConfig(
        provider: remote.provider,
        token: deobfuscatedToken,
        fetchedAt: now,
      );

      _memoryCache = config;
      await _persistToStorage(config);
      return config;
    } catch (error, stackTrace) {
      debugPrint('[MapConfig] Remote fetch failed: $error\n$stackTrace');

      final fromStorage = await _loadFromStorage();
      if (fromStorage != null) {
        _memoryCache = fromStorage;
        return fromStorage;
      }

      return _localEnvFallback();
    }
  }

  Future<void> _persistToStorage(PropertyMapConfig config) async {
    try {
      await _storageService.setString(
        _providerStorageKey,
        config.provider.name,
      );
      await _storageService.setString(_tokenStorageKey, config.token);
      await _storageService.setString(
        _fetchedAtStorageKey,
        config.fetchedAt.toIso8601String(),
      );
    } catch (error, stackTrace) {
      debugPrint('[MapConfig] Persist to storage failed: $error\n$stackTrace');
    }
  }

  Future<PropertyMapConfig?> _loadFromStorage() async {
    try {
      final providerName = await _storageService.getString(_providerStorageKey);
      final token = await _storageService.getString(_tokenStorageKey);
      final fetchedAtStr = await _storageService.getString(
        _fetchedAtStorageKey,
      );

      if (providerName == null || token == null) {
        return null;
      }

      final provider = providerName == PropertyMapProvider.google.name
          ? PropertyMapProvider.google
          : PropertyMapProvider.yandex;

      final fetchedAt = fetchedAtStr != null
          ? DateTime.tryParse(fetchedAtStr) ?? DateTime.now()
          : DateTime.now();

      return PropertyMapConfig(
        provider: provider,
        token: token,
        fetchedAt: fetchedAt,
      );
    } catch (error, stackTrace) {
      debugPrint('[MapConfig] Load from storage failed: $error\n$stackTrace');
      return null;
    }
  }

  PropertyMapConfig _localEnvFallback() {
    final yandexKey = AppConfig.yandexMapKitApiKey;
    final googleKey = AppConfig.googleMapsApiKey;

    final provider = yandexKey.isNotEmpty
        ? PropertyMapProvider.yandex
        : PropertyMapProvider.google;

    final token = provider == PropertyMapProvider.yandex
        ? yandexKey
        : googleKey;

    return PropertyMapConfig(
      provider: provider,
      token: token,
      fetchedAt: DateTime.now(),
    );
  }
}
