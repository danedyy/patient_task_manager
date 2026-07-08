import 'dart:math';

/// Exponential backoff with additive jitter for retrying transient sync
/// failures.
///
/// `delay = min(cap, base * 2^attempt) + random(0 .. capped/2)`. The exponential
/// term backs off fast; the cap bounds it; the jitter (0–50% on top) spreads
/// retries so many stalled ops don't stampede the server in lockstep.
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
    final expMs = base.inMilliseconds * pow(2, attempt).toDouble();
    final cappedMs = min(cap.inMilliseconds.toDouble(), expMs).toInt();
    final jitterMs = _random.nextInt((cappedMs ~/ 2) + 1);
    return Duration(milliseconds: cappedMs + jitterMs);
  }
}
