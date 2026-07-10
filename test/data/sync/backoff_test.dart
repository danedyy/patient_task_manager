import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:patient_task_manager/data/sync/backoff.dart';

void main() {
  test('grows exponentially from base until it hits the cap', () {
    // Zero-jitter Random (nextInt always 0) isolates the exponential term.
    final backoff = Backoff(
      base: const Duration(milliseconds: 100),
      cap: const Duration(seconds: 2),
      random: _ZeroRandom(),
    );

    expect(backoff.delayFor(0), const Duration(milliseconds: 100)); // 100 * 2^0
    expect(backoff.delayFor(1), const Duration(milliseconds: 200)); // 100 * 2^1
    expect(backoff.delayFor(3), const Duration(milliseconds: 800)); // 100 * 2^3
    expect(backoff.delayFor(10), const Duration(seconds: 2)); // capped
  });

  test('jitter stays within [ceil/2, ceil] of the capped delay', () {
    final backoff = Backoff(
      base: const Duration(milliseconds: 100),
      cap: const Duration(seconds: 10),
      random: Random(1),
    );

    for (var attempt = 0; attempt < 6; attempt++) {
      final ceilMs = min(10000, 100 * (1 << attempt));
      final delay = backoff.delayFor(attempt).inMilliseconds;
      // Jitter is shaved off the ceiling, never added past it.
      expect(delay, lessThanOrEqualTo(ceilMs));
      expect(delay, greaterThanOrEqualTo(ceilMs - ceilMs ~/ 2));
    }
  });
}

/// A [Random] whose `nextInt` is always 0, to remove jitter for exact assertions.
class _ZeroRandom implements Random {
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0;
}
