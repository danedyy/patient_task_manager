import 'package:rxdart/rxdart.dart';

import '../../core/cancellation.dart';
import '../../core/failure/failure_exceptions.dart';
import '../../domain/entities/patient_task.dart';
import '../../domain/entities/sync_rejection.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repositories/patient_task_repository.dart';
import '../local/app_database.dart';
import '../local/daos/sync_queue_dao.dart';
import '../local/daos/task_dao.dart';
import '../remote/patient_task_api.dart';
import '../sync/sync_engine.dart';

/// Drift-backed repository: the confirmed layer ([TaskDao]) plus the pending
/// queue ([SyncQueueDao]), reconciled at read time by [_fold]. Owns the
/// [SyncEngine]'s lifecycle and re-exposes its rejection stream.
class DriftPatientTaskRepository implements PatientTaskRepository {
  final PatientTaskApi _api;
  final TaskDao _taskDao;
  final SyncQueueDao _queueDao;
  final SyncEngine _engine;
  final DateTime Function() _clock;

  DriftPatientTaskRepository({
    required this._api,
    required this._taskDao,
    required this._queueDao,
    required this._engine,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Begins background draining + server-push merge. Call once after wiring.
  void start() => _engine.start();

  Future<void> dispose() => _engine.dispose();

  @override
  Stream<SyncRejection> get syncRejections => _engine.rejections;

  @override
  Stream<int> watchPendingSyncCount() => _queueDao.watchCount();

  @override
  Stream<List<PatientTask>> watchTasks() =>
      Rx.combineLatest2(_taskDao.watchAll(), _queueDao.watchAll(), _fold);

  @override
  Future<void> updateStatus(String taskId, TaskStatus next) async {
    // Validate against the *effective* status (confirmed + pending), so a chain
    // of optimistic edits is checked against the latest intent, not stale
    // server state. `version` is untouched by the fold, so it is the confirmed
    // server version — exactly the baseline the op must be created against.
    final current = (await watchTasks().first).firstWhere((t) => t.id == taskId);
    if (!current.status.canTransitionTo(next)) {
      throw InvalidTransitionException(current.status, next);
    }
    await _queueDao.enqueue(
      taskId: taskId,
      from: current.status,
      to: next,
      baseVersion: current.version,
      createdAt: _clock(),
    );
  }

  @override
  Future<void> refresh() async {
    // fetchTasks throws before replaceAll runs on failure, so local state is
    // left untouched. replaceAll is itself transactional (see TaskDao).
    final page = await _api.fetchTasks();
    await _taskDao.replaceAll([for (final m in page.items) m.toEntity()]);
  }

  @override
  Future<void> search(String query, {CancellationToken? cancelToken}) async {
    // Merge (not replace): matching rows are refreshed via the version-guarded
    // upsert so search results and sync state can never disagree, and locally
    // cached non-matching tasks are left intact. If the fetch was cancelled
    // (superseded), it throws before we reach the upsert, so nothing is written.
    final page = await _api.fetchTasks(query: query, cancelToken: cancelToken);
    for (final m in page.items) {
      await _taskDao.upsertFromServer(m.toEntity());
    }
  }

  /// Confirmed rows with the latest queued intent per task applied on top.
  /// Optimistic state is derived here, never stored — rolling back is simply
  /// the op disappearing from the queue.
  List<PatientTask> _fold(
    List<PatientTask> confirmed,
    List<PendingOperation> pending,
  ) {
    if (pending.isEmpty) return confirmed;
    // Ops arrive in `seq` order; the last per task is the net intent, because
    // each was validated against the previous — they form a legal chain.
    final latest = <String, TaskStatus>{};
    for (final op in pending) {
      latest[op.taskId] = op.toStatus;
    }
    return [
      for (final task in confirmed)
        latest.containsKey(task.id)
            ? task.copyWith(status: latest[task.id]!)
            : task,
    ];
  }
}
