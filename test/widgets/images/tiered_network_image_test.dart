import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/widgets/images/tiered_network_image.dart';

void main() {
  test('normal display never requests original while variants exist', () {
    const urls = ImageTierUrls(
      previewUrl: 'https://cdn/preview.jpg',
      displayUrl: 'https://cdn/display.jpg',
      originalUrl: 'https://cdn/original.jpg',
    );
    expect(urls.candidates(ImageDisplayTier.display), [
      'https://cdn/preview.jpg',
      'https://cdn/display.jpg',
    ]);
    expect(urls.candidates(ImageDisplayTier.original), [
      'https://cdn/display.jpg',
      'https://cdn/original.jpg',
      'https://cdn/preview.jpg',
    ]);
  });

  test(
    'fullscreen requests display, then original, with preview failure fallback',
    () {
      const urls = ImageTierUrls(
        previewUrl: 'https://cdn/preview.jpg',
        displayUrl: 'https://cdn/display.jpg',
        originalUrl: 'https://cdn/original.jpg',
      );
      expect(urls.candidates(ImageDisplayTier.original), [
        'https://cdn/display.jpg',
        'https://cdn/original.jpg',
        'https://cdn/preview.jpg',
      ]);
    },
  );

  test('retains display when fullscreen original upgrade fails', () {
    final progress = ImageTierProgress(
      urls: const ['display', 'original', 'preview'],
      targetTier: ImageDisplayTier.original,
      upgradeFromFirst: true,
    );
    expect(progress.completeSuccess(), isTrue);
    expect(progress.currentUrl, 'original');
    expect(progress.completeFailure(), isFalse);
    expect(progress.bestLoadedUrl, 'display');
  });

  test('fullscreen display to original success never advances to preview', () {
    final progress = ImageTierProgress(
      urls: const ['display', 'original', 'preview'],
      targetTier: ImageDisplayTier.original,
      upgradeFromFirst: true,
    );

    expect(progress.currentUrl, 'display');
    expect(progress.completeSuccess(), isTrue);
    expect(progress.currentUrl, 'original');

    // The widget takes its next request directly from this state machine.
    // A successful original is terminal: preview is strictly failure-only.
    expect(progress.completeSuccess(), isFalse);
    expect(progress.currentUrl, 'original');
    expect(progress.bestLoadedUrl, 'original');
  });

  test('uses preview only when display and original both fail', () {
    final progress = ImageTierProgress(
      urls: const ['display', 'original', 'preview'],
      targetTier: ImageDisplayTier.original,
      upgradeFromFirst: true,
    );
    expect(progress.completeFailure(), isTrue);
    expect(progress.currentUrl, 'original');
    expect(progress.completeFailure(), isTrue);
    expect(progress.currentUrl, 'preview');
  });

  test('legacy original URL is still usable when variants are null', () {
    const urls = ImageTierUrls(originalUrl: 'https://cdn/original.jpg');
    expect(urls.candidates(ImageDisplayTier.display), [
      'https://cdn/original.jpg',
    ]);
    expect(urls.candidates(ImageDisplayTier.original), [
      'https://cdn/original.jpg',
    ]);
  });

  test('fullscreen original does not downgrade when display is absent', () {
    final progress = ImageTierProgress(
      urls: const ['original', 'preview'],
      targetTier: ImageDisplayTier.original,
      upgradeFromFirst: false,
    );
    expect(progress.completeSuccess(), isFalse);
    expect(progress.bestLoadedUrl, 'original');
    expect(progress.currentUrl, 'original');
  });
}
