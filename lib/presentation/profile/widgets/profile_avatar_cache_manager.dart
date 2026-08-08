import 'package:file/file.dart' as file;
import 'package:file/local.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Dedicated disk cache for the authenticated user's avatar.
///
/// The URL is the cache key and every entry is refreshed after one day.
class ProfileAvatarCacheManager {
  ProfileAvatarCacheManager._();

  static final CacheManager instance = CacheManager(
    Config(
      'profile-avatar-cache',
      stalePeriod: const Duration(days: 1),
      maxNrOfCacheObjects: 10,
      fileService: _OneDayAvatarFileService(),
      fileSystem: _ProfileAvatarFileSystem('profile-avatar-cache'),
    ),
  );
}

class _ProfileAvatarFileSystem implements FileSystem {
  _ProfileAvatarFileSystem(this._cacheKey);

  final String _cacheKey;
  late final Future<file.Directory> _directory = _createDirectory();

  @override
  Future<file.File> createFile(String name) async {
    final directory = await _directory;
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.childFile(name);
  }

  Future<file.Directory> _createDirectory() async {
    final appSupportDirectory = await getApplicationSupportDirectory();
    final cacheDirectory = const LocalFileSystem().directory(
      path.join(appSupportDirectory.path, _cacheKey),
    );
    await cacheDirectory.create(recursive: true);
    return cacheDirectory;
  }
}

class _OneDayAvatarFileService extends HttpFileService {
  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await super.get(url, headers: headers);
    return _OneDayAvatarFileServiceResponse(response);
  }
}

class _OneDayAvatarFileServiceResponse implements FileServiceResponse {
  _OneDayAvatarFileServiceResponse(this._response);

  final FileServiceResponse _response;
  final DateTime _receivedAt = DateTime.now();

  @override
  Stream<List<int>> get content => _response.content;

  @override
  int? get contentLength => _response.contentLength;

  @override
  String? get eTag => _response.eTag;

  @override
  String get fileExtension => _response.fileExtension;

  @override
  int get statusCode => _response.statusCode;

  @override
  DateTime get validTill => _receivedAt.add(const Duration(days: 1));
}
