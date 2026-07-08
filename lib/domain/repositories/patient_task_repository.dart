import '../entities/patient_task.dart';
import '../entities/sync_rejection.dart';
import '../entities/task_status.dart';

/// Domain-facing persistence boundary. The Bloc depends on this, never on Drift
/// or the API directly, so the storage + sync implementation is swappable.
abstract interface class PatientTaskRepository {

  /// Reactive stream of the current local view (optimistic state included).
  Stream<List<PatientTask>> watchTasks();

  /// Stream of pending sync operations (useful for a "syncing..." UI badge).
  Stream<int> watchPendingSyncCount();

  /// Local changes the server ultimately rejected. The UI turns these into a
  /// notice; the fold rolls the affected row back automatically.
  Stream<SyncRejection> get syncRejections;


  /// Records the intent locally, applies it optimistically, and enqueues a
  /// sync operation. Throws [InvalidTransitionException] if [next] is not
  /// reachable from the current status.
  Future<void> updateStatus(String taskId, TaskStatus next);


  /// Triggers a refresh from the remote API. Errors propagate; local state
  /// is not cleared on failure.
  Future<void> refresh();
}
