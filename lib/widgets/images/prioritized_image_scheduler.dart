import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart'
    as flutter_cache;

/// A stable order, from interaction-critical work down to prefetch work.
enum ImageLoadPriority { critical, high, normal, low }

class ImageDownloadCancelledException implements Exception {
  const ImageDownloadCancelledException();
}

/// A consumer-specific view of a scheduled URL. Cancelling one handle never
/// cancels another consumer of the same URL.
class ImageDownloadHandle<T> {
  ImageDownloadHandle._(this.future, this._onCancel);

  final Future<T> future;
  final void Function() _onCancel;
  bool _isCancelled = false;

  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    _onCancel();
  }
}

/// A small, deterministic URL scheduler. It is intentionally independent of
/// Flutter's image codec so it can be unit-tested and used by all image views.
class PrioritizedImageDownloadScheduler<T> {
  PrioritizedImageDownloadScheduler({
    required Future<T> Function(String url) downloader,
    this.maxConcurrentDownloads = 3,
  }) : assert(maxConcurrentDownloads > 0),
       _downloader = downloader;

  final Future<T> Function(String url) _downloader;
  final int maxConcurrentDownloads;
  final Map<String, _DownloadJob<T>> _jobs = {};
  final Map<ImageLoadPriority, ListQueue<_DownloadJob<T>>> _queues = {
    for (final priority in ImageLoadPriority.values)
      priority: ListQueue<_DownloadJob<T>>(),
  };
  int _activeDownloads = 0;

  ImageDownloadHandle<T> schedule(
    String url, {
    ImageLoadPriority priority = ImageLoadPriority.normal,
  }) {
    final consumer = _DownloadConsumer<T>();
    final existing = _jobs[url];
    if (existing != null) {
      existing.consumers.add(consumer);
      _promote(existing, priority);
    } else {
      final job = _DownloadJob<T>(url: url, priority: priority)
        ..consumers.add(consumer);
      _jobs[url] = job;
      _queues[priority]!.addLast(job);
      _drain();
    }

    return ImageDownloadHandle<T>._(
      consumer.completer.future,
      () => _cancel(url, consumer),
    );
  }

  void _promote(_DownloadJob<T> job, ImageLoadPriority priority) {
    if (job.started || priority.index >= job.priority.index) return;
    _queues[job.priority]!.remove(job);
    job.priority = priority;
    _queues[priority]!.addLast(job);
  }

  void _cancel(String url, _DownloadConsumer<T> consumer) {
    if (consumer.cancelled) return;
    consumer.cancelled = true;
    if (!consumer.completer.isCompleted) {
      consumer.completer.completeError(const ImageDownloadCancelledException());
    }

    final job = _jobs[url];
    if (job == null || job.started || job.hasActiveConsumers) return;

    _queues[job.priority]!.remove(job);
    _jobs.remove(url);
  }

  void _drain() {
    while (_activeDownloads < maxConcurrentDownloads) {
      final job = _nextJob();
      if (job == null) return;
      if (!job.hasActiveConsumers) {
        _jobs.remove(job.url);
        continue;
      }
      job.started = true;
      _activeDownloads++;
      unawaited(_run(job));
    }
  }

  _DownloadJob<T>? _nextJob() {
    for (final priority in ImageLoadPriority.values) {
      final queue = _queues[priority]!;
      if (queue.isNotEmpty) return queue.removeFirst();
    }
    return null;
  }

  Future<void> _run(_DownloadJob<T> job) async {
    try {
      final value = await _downloader(job.url);
      for (final consumer in job.consumers) {
        if (!consumer.cancelled && !consumer.completer.isCompleted) {
          consumer.completer.complete(value);
        }
      }
    } catch (error, stackTrace) {
      for (final consumer in job.consumers) {
        if (!consumer.cancelled && !consumer.completer.isCompleted) {
          consumer.completer.completeError(error, stackTrace);
        }
      }
    } finally {
      _activeDownloads--;
      _jobs.remove(job.url);
      _drain();
    }
  }
}

class _DownloadJob<T> {
  _DownloadJob({required this.url, required this.priority});

  final String url;
  ImageLoadPriority priority;
  final List<_DownloadConsumer<T>> consumers = [];
  bool started = false;

  bool get hasActiveConsumers =>
      consumers.any((consumer) => !consumer.cancelled);
}

class _DownloadConsumer<T> {
  final Completer<T> completer = Completer<T>();
  bool cancelled = false;
}

/// A dedicated public-image namespace prevents image eviction policy from
/// being coupled to API responses or profile/private data.
class PublicImageCacheManager {
  PublicImageCacheManager._();

  static final flutter_cache.BaseCacheManager instance =
      flutter_cache.CacheManager(
        flutter_cache.Config(
          'ideal_public_images_v1',
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 300,
        ),
      );
}

class AppImageLoader {
  AppImageLoader({
    flutter_cache.BaseCacheManager? cacheManager,
    int maxConcurrentDownloads = 3,
  }) : _scheduler = PrioritizedImageDownloadScheduler<File>(
         downloader: (url) => (cacheManager ?? PublicImageCacheManager.instance)
             .getSingleFile(url),
         maxConcurrentDownloads: maxConcurrentDownloads,
       );

  static final AppImageLoader instance = AppImageLoader();

  final PrioritizedImageDownloadScheduler<File> _scheduler;

  ImageDownloadHandle<File> load(
    String url, {
    ImageLoadPriority priority = ImageLoadPriority.normal,
  }) => _scheduler.schedule(url, priority: priority);
}
