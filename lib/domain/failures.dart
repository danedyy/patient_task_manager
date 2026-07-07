import 'task_status.dart';

/// Thrown by the repository when a requested status change is not reachable
/// from the task's current status.
class InvalidTransitionException implements Exception {
  final TaskStatus from;
  final TaskStatus to;

  const InvalidTransitionException(this.from, this.to);

  @override
  String toString() => 'InvalidTransitionException: $from -> $to';
}

/// HTTP 409: the expected version no longer matches the server's version.
class ConflictException implements Exception {
  final String taskId;
  final int serverVersion;

  const ConflictException(this.taskId, this.serverVersion);

  @override
  String toString() =>
      'ConflictException: task $taskId is at server version $serverVersion';
}

/// Simulated 5xx / network error; the operation may be retried.
class TransientException implements Exception {
  final String message;

  const TransientException(this.message);

  @override
  String toString() => 'TransientException: $message';
}
