import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/widgets/images/prioritized_image_scheduler.dart';

void main() {
  test('honours priority, FIFO, and three-download concurrency', () async {
    final started = <String>[];
    final completions = <String, Completer<String>>{};
    final scheduler = PrioritizedImageDownloadScheduler<String>(
      maxConcurrentDownloads: 3,
      downloader: (url) {
        started.add(url);
        return (completions[url] ??= Completer<String>()).future;
      },
    );

    final one = scheduler.schedule('normal-1');
    final two = scheduler.schedule('normal-2');
    final three = scheduler.schedule('normal-3');
    scheduler.schedule('low');
    scheduler.schedule('high', priority: ImageLoadPriority.high);
    await Future<void>.delayed(Duration.zero);

    expect(started, ['normal-1', 'normal-2', 'normal-3']);
    completions['normal-1']!.complete('one');
    await Future<void>.delayed(Duration.zero);
    expect(started.last, 'high');
    completions['normal-2']!.complete('two');
    completions['normal-3']!.complete('three');
    completions['high']!.complete('four');
    await Future<void>.delayed(Duration.zero);
    expect(started.last, 'low');
    completions['low']!.complete('five');
    await Future.wait([one.future, two.future, three.future]);
  });

  test(
    'deduplicates URLs, promotes pending priority, and cancels consumers',
    () async {
      final started = <String>[];
      final gate = Completer<String>();
      final scheduler = PrioritizedImageDownloadScheduler<String>(
        maxConcurrentDownloads: 1,
        downloader: (url) {
          started.add(url);
          return url == 'blocker' ? gate.future : Future.value(url);
        },
      );
      final blocker = scheduler.schedule('blocker');
      final low = scheduler.schedule('same', priority: ImageLoadPriority.low);
      final critical = scheduler.schedule(
        'same',
        priority: ImageLoadPriority.critical,
      );
      final normal = scheduler.schedule('normal');
      low.cancel();
      await expectLater(
        low.future,
        throwsA(isA<ImageDownloadCancelledException>()),
      );
      gate.complete('blocker');
      await blocker.future;
      await Future<void>.delayed(Duration.zero);

      expect(started.take(2), ['blocker', 'same']);
      expect(await critical.future, 'same');
      await Future<void>.delayed(Duration.zero);
      expect(started, ['blocker', 'same', 'normal']);
      await normal.future;
    },
  );

  test('drops a pending URL after its sole consumer cancels', () async {
    final started = <String>[];
    final gate = Completer<String>();
    final scheduler = PrioritizedImageDownloadScheduler<String>(
      maxConcurrentDownloads: 1,
      downloader: (url) {
        started.add(url);
        return url == 'blocker' ? gate.future : Future.value(url);
      },
    );
    final blocker = scheduler.schedule('blocker');
    final discarded = scheduler.schedule('discard');
    discarded.cancel();
    await expectLater(
      discarded.future,
      throwsA(isA<ImageDownloadCancelledException>()),
    );
    gate.complete('blocker');
    await blocker.future;
    await Future<void>.delayed(Duration.zero);
    expect(started, ['blocker']);
  });
}
