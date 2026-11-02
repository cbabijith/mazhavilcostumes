/// Opt-in timings contain no user data, URLs or credentials.
library;

import 'package:flutter/foundation.dart';

abstract final class StartupTiming {
  static final _clock = Stopwatch();
  static const enabled = bool.fromEnvironment('PERFORMANCE_LOGS');

  static void start() {
    if (enabled) _clock.start();
  }

  static void mark(String event) {
    if (enabled) {
      debugPrint('[StartupTiming] $event ${_clock.elapsedMilliseconds}ms');
    }
  }
}
