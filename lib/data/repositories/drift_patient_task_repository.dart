import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../../core/cancellation.dart';
import '../../core/connectivity/connectivity_monitor.dart';
import '../../core/failure/failure_exceptions.dart';
import '../../domain/entities/patient_task.dart';
import '../../domain/entities/sync_rejection.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/entities/task_transition.dart';
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
  final ConnectivityMonitor _connectivity;
  final DateTime Function() _clock;

  DriftPatientTaskRepository({
    required this._api,
    required this._taskDao,
    required this._queueDao,
    required this._engine,
    required this._connectivity,
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
    final current = (await watchTasks().first).firstWhere(
      (t) => t.id == taskId,
    );
    // Impossible-to-construct enforcement: no proven transition, no enqueue.
    final transition = TaskTransition.tryCreate(current.status, next);
    if (transition == null) {
      throw InvalidTransitionException(current.status, next);
    }
    await _queueDao.enqueue(
      taskId: taskId,
      from: transition.from,
      to: transition.to,
      baseVersion: current.version,
      createdAt: _clock(),
    );
  }

  /// A remote read needs a link. Offline, a real HTTP client fails with a network
  /// error, so we throw one too (callers fall back to the cached Drift data).
  Future<void> _requireOnline() async {
    if (!await _connectivity.isOnline()) {
      throw const TransientException('offline: no network for a server fetch');
    }
  }

  @override
  Future<bool> refresh() async {
    await _requireOnline();
  
    final page = await _api.fetchTasks();
    await _taskDao.replaceAll([for (final m in page.items) m.toEntity()]);
    return page.pageSize < page.total; // more pages beyond the first
  }

  @override
  Future<bool> fetchPage(
    String query,
    int page, {
    CancellationToken? cancelToken,
  }) async {
    await _requireOnline(); 

    final result = await _api.fetchTasks(
      query: query,
      page: page,
      cancelToken: cancelToken,
    );
    // Batch the merge so the whole page lands in one list emission (a per-row
    // loop makes the tiles trickle in one at a time).
    await _taskDao.upsertAllFromServer([
      for (final m in result.items) m.toEntity(),
    ]);
    return (page + 1) * result.pageSize < result.total; // more pages remain
  }

  List<PatientTask> _fold(
    List<PatientTask> confirmed,
    List<PendingOperation> pending,
  ) {
    if (pending.isEmpty) return confirmed;
    // Ops arrive in `seq` order; the last per task is the net intent, because
    // each was validated against the previous, so they form a legal chain.
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
