import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:ideal_mobile/presentation/map/data/datasources/map_config_remote_data_source.dart';
import 'package:ideal_mobile/presentation/map/domain/entities/map_config.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
import 'package:ideal_mobile/presentation/map/domain/repositories/map_config_repository.dart';
import 'package:ideal_mobile/services/secure_storage_service.dart';
import 'package:ideal_mobile/utils/app_environment.dart';
import 'package:ideal_mobile/utils/app_flavor_env.dart';
import 'package:ideal_mobile/utils/map_token_obfuscator.dart';

class MapConfigRepositoryImpl implements MapConfigRepository {
  MapConfigRepositoryImpl({
    required MapConfigRemoteDataSource remoteDataSource,
    SecureStorageService? storageService,
    this.cacheTtl = const Duration(hours: 24),
    this.secret,
  }) : _remoteDataSource = remoteDataSource,
       _storageService = storageService ?? SecureStorageService();

  static const _providerStorageKey = 'map_cached_provider';
  static const _tokenStorageKey = 'map_cached_token';
  static const _fetchedAtStorageKey = 'map_cached_fetched_at';

  final MapConfigRemoteDataSource _remoteDataSource;
  final SecureStorageService _storageService;
  final Duration cacheTtl;
  final String? secret;

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
      String deobfuscatedToken = '';
      if (remote.token.isNotEmpty) {
        try {
          final effectiveSecret = secret ?? AppConfig.mapObfuscationSecret;
          deobfuscatedToken = MapTokenObfuscator.deobfuscate(
            remote.token,
            secret: effectiveSecret,
          );
          if (deobfuscatedToken.isEmpty) {
            debugPrint(
              '[MapConfig] Deobfuscated token empty provider=${remote.provider.name} secretPresent=${effectiveSecret.isNotEmpty} flavor=${AppConfig.appFlavor.name}',
            );
            if (!AppEnvironment.isTestEnvironment && !kIsWeb) {
              try {
                FirebaseCrashlytics.instance.log(
                  '[MapConfig] empty after deobfuscate provider=${remote.provider.name} secretLen=${effectiveSecret.length} flavor=${AppConfig.appFlavor.name}',
                );
              } catch (_) {}
            }
          } else {
            debugPrint(
              '[MapConfig] Fetched provider=${remote.provider.name} tokenLen=${deobfuscatedToken.length} flavor=${AppConfig.appFlavor.name}',
            );
          }
        } on FormatException catch (error, stackTrace) {
          debugPrint(
            '[MapConfig] Token deobfuscation failed provider=${remote.provider.name} tokenLen=${remote.token.length} secretLen=${(secret ?? AppConfig.mapObfuscationSecret).length} flavor=${AppConfig.appFlavor.name}: $error\n$stackTrace',
          );
          if (!AppEnvironment.isTestEnvironment && !kIsWeb) {
            try {
              FirebaseCrashlytics.instance.recordError(
                error,
                stackTrace,
                reason:
                    'Map token deobfuscate FormatException provider=${remote.provider.name} flavor=${AppConfig.appFlavor.name}',
              );
            } catch (_) {}
          }
          // Keep token empty so selector will try fallback; still cache provider for diagnostics
          deobfuscatedToken = '';
        }
      } else {
        debugPrint(
          '[MapConfig] Remote token empty provider=${remote.provider.name} flavor=${AppConfig.appFlavor.name}',
        );
        if (!AppEnvironment.isTestEnvironment && !kIsWeb) {
          try {
            FirebaseCrashlytics.instance.log(
              '[MapConfig] remote token empty provider=${remote.provider.name} flavor=${AppConfig.appFlavor.name}',
            );
          } catch (_) {}
        }
      }

      final now = DateTime.now();
      final config = PropertyMapConfig(
        provider: remote.provider,
        token: deobfuscatedToken,
        fetchedAt: now,
      );

      _memoryCache = config;
      if (deobfuscatedToken.isNotEmpty) {
        await _persistToStorage(config);
      }
      return config;
    } catch (error, stackTrace) {
      debugPrint('[MapConfig] Remote fetch failed: $error\n$stackTrace');
      if (!AppEnvironment.isTestEnvironment && !kIsWeb) {
        try {
          FirebaseCrashlytics.instance.recordError(
            error,
            stackTrace,
            reason: 'MapConfig remote fetch failed flavor=${AppConfig.appFlavor.name}',
          );
        } catch (_) {}
      }

      final fromStorage = await _loadFromStorage();
      if (fromStorage != null && fromStorage.token.isNotEmpty) {
        _memoryCache = fromStorage;
        return fromStorage;
      }

      return PropertyMapConfig(
        provider: PropertyMapProvider.yandex,
        token: '',
        fetchedAt: DateTime.now(),
      );
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
}
