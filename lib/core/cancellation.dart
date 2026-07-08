/// A cooperative cancellation signal. The caller holds the token and calls
/// [cancel]; the callee checks it at each async boundary via [throwIfCancelled]
/// and aborts.
///
/// Deliberately minimal — a single one-way flag, no `package:async` dependency.
/// That is all "a newer search supersedes the older one" needs, and it mirrors
/// the `CancelToken` a real HTTP client would carry.
class CancellationToken {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() => _cancelled = true;

  void throwIfCancelled() {
    if (_cancelled) throw const OperationCancelledException();
  }
}

/// Thrown by an operation that found its [CancellationToken] cancelled. it
/// was superseded and its result is no longer wanted.
class OperationCancelledException implements Exception {
  const OperationCancelledException();

  @override
  String toString() => 'OperationCancelledException';
}
