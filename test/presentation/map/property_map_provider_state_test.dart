import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';
import 'package:ideal_mobile/presentation/map/services/property_map_attachment_guard.dart';
import 'package:ideal_mobile/presentation/map/widgets/providers/google_camera_move_reason_tracker.dart';
import 'package:ideal_mobile/services/mapkit_service.dart';

void main() {
  test('attachment guard rejects a late native callback after disposal', () {
    final guard = PropertyMapAttachmentGuard();
    expect(guard.acceptAttachment(), isTrue);

    guard.invalidate();

    expect(guard.isActive, isFalse);
    expect(guard.acceptAttachment(), isFalse);
  });

  test('Yandex lifecycle lease stops the replaced lifecycle before start', () {
    final first = _FakeYandexLifecycle();
    final second = _FakeYandexLifecycle();
    final lease = YandexMapLifecycleLease();

    lease.start(first);
    lease.start(second);

    expect(first.startCount, 1);
    expect(first.stopCount, 1);
    expect(second.startCount, 1);
    expect(second.stopCount, 0);

    lease.stop();
    expect(second.stopCount, 1);
  });

  test('Google reason tracker labels interruption as a user gesture', () {
    final tracker = GoogleCameraMoveReasonTracker();
    tracker.expectProgrammaticMove();

    expect(
      tracker.onCameraMoveStarted(),
      PropertyMapCameraMoveReason.programmatic,
    );
    expect(tracker.onCameraMoveStarted(), PropertyMapCameraMoveReason.gesture);
    expect(tracker.onCameraIdle(), PropertyMapCameraMoveReason.gesture);
    tracker.dispose();
  });

  test('expired programmatic expectation cannot mislabel a later gesture', () {
    fakeAsync((async) {
      final tracker = GoogleCameraMoveReasonTracker(
        programmaticStartTimeout: const Duration(milliseconds: 10),
      );
      tracker.expectProgrammaticMove();

      async.elapse(const Duration(milliseconds: 10));

      expect(
        tracker.onCameraMoveStarted(),
        PropertyMapCameraMoveReason.gesture,
      );
      tracker.dispose();
    });
  });
}

class _FakeYandexLifecycle implements YandexMapLifecycle {
  int startCount = 0;
  int stopCount = 0;

  @override
  bool get isAvailable => true;

  @override
  Future<bool> initialize() async => true;

  @override
  void start() {
    startCount++;
  }

  @override
  void stop() {
    stopCount++;
  }
}
