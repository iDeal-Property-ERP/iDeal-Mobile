import 'dart:async';

import 'package:ideal_mobile/presentation/map/domain/property_map_models.dart';

class GoogleCameraMoveReasonTracker {
  GoogleCameraMoveReasonTracker({
    this.programmaticStartTimeout = const Duration(seconds: 1),
  });

  final Duration programmaticStartTimeout;
  Timer? _programmaticStartTimer;
  bool _expectsProgrammaticStart = false;
  PropertyMapCameraMoveReason _reason =
      PropertyMapCameraMoveReason.programmatic;

  PropertyMapCameraMoveReason get reason => _reason;

  void expectProgrammaticMove() {
    _expectsProgrammaticStart = true;
    _programmaticStartTimer?.cancel();
    _programmaticStartTimer = Timer(programmaticStartTimeout, () {
      _expectsProgrammaticStart = false;
    });
  }

  PropertyMapCameraMoveReason onCameraMoveStarted() {
    if (_expectsProgrammaticStart) {
      _expectsProgrammaticStart = false;
      _programmaticStartTimer?.cancel();
      _reason = PropertyMapCameraMoveReason.programmatic;
    } else {
      _reason = PropertyMapCameraMoveReason.gesture;
    }
    return _reason;
  }

  PropertyMapCameraMoveReason onCameraIdle() {
    _expectsProgrammaticStart = false;
    _programmaticStartTimer?.cancel();
    final settledReason = _reason;
    _reason = PropertyMapCameraMoveReason.gesture;
    return settledReason;
  }

  void cancelProgrammaticMove() {
    _expectsProgrammaticStart = false;
    _programmaticStartTimer?.cancel();
  }

  void dispose() {
    _programmaticStartTimer?.cancel();
  }
}
