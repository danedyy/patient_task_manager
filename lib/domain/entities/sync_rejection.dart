/// UI-agnostic on purpose: the Bloc turns this into a snackbar, but the domain
/// only states *what* was rejected and *why*.
class SyncRejection {
  final String taskId;
  final String reason;

  const SyncRejection(this.taskId, this.reason);

  @override
  String toString() => 'SyncRejection($taskId: $reason)';
}
