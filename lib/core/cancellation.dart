class CancellationToken {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() => _cancelled = true;

  void throwIfCancelled() {
    if (_cancelled) throw const OperationCancelledException();
  }
}

/// Thrown by an operation that found its [CancellationToken] cancelled.
class OperationCancelledException implements Exception {
  const OperationCancelledException();

  @override
  String toString() => 'OperationCancelledException';
}
