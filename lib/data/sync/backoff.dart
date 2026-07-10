import 'dart:math';

/// Exponential backoff with additive jitter for retrying transient sync
/// failures.
///
/// `delay = ceil - random(0 .. ceil/2)`, where `ceil = min(cap, base * (1 <<
/// min(attempt, 10)))`. The exponential term backs off fast; the cap bounds it;
/// the jitter (0–50% shaved off) spreads retries so many stalled ops don't
/// stampede the server in lockstep.
/// [Random] is injected so tests get a fixed, assertable sequence.
class Backoff {
  final Duration base;
  final Duration cap;
  final Random _random;

  Backoff({
    this.base = const Duration(milliseconds: 200),
    this.cap = const Duration(seconds: 10),
    Random? random,
  }) : _random = random ?? Random();

  Duration delayFor(int attempt) {
    final expMs = base.inMilliseconds * (1 << min(attempt, 10));
    final ceilMs = min(cap.inMilliseconds, expMs);
    final jitterMs = _random.nextInt((ceilMs ~/ 2) + 1);
    return Duration(milliseconds: ceilMs - jitterMs);
  }
}
