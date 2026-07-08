import 'dart:async';

import '../../core/failure/failure_exceptions.dart';
import '../../domain/entities/sync_rejection.dart';
import '../local/app_database.dart';
import '../local/daos/sync_queue_dao.dart';
import '../local/daos/task_dao.dart';
import '../models/patient_task_model.dart';
import '../remote/patient_task_api.dart';
import 'backoff.dart';

/// Drains the persistent [PendingOperations] queue to the server and merges
/// server-originated pushes back into the confirmed layer.
///
/// - **single in-flight**: one op is synced at a time, in FIFO `seq` order, so
///   per-task ordering is preserved without any locking.
/// - **retries are awaited inline** with injected [Backoff] delay rather than a
///   detached timer — simpler, and the injected [delay] keeps tests instant.
/// - **conflicts are re-validated** against the live server status: still-legal
///   transitions are re-based and retried; illegal ones are dropped and a
///   [SyncRejection] is emitted for the UI to surface.
class SyncEngine {
  final PatientTaskApi _api;
  final TaskDao _taskDao;
  final SyncQueueDao _queueDao;
  final Backoff _backoff;
  final Future<void> Function(Duration) _delay;
  final int _maxAttempts;

  final _rejections = StreamController<SyncRejection>.broadcast();

  StreamSubscription<void>? _queueSub;
  StreamSubscription<void>? _pushSub;
  bool _draining = false;

  SyncEngine({
    required this._api,
    required this._taskDao,
    required this._queueDao,
    Backoff? backoff,
    Future<void> Function(Duration)? delay,
    this._maxAttempts = 5,
  })  : _backoff = backoff ?? Backoff(),
        // Wall-clock delay by default; tests inject an instant no-op so backoff
        // never spends real time in a fake environment.
        _delay = delay ?? Future.delayed;

  /// Rejected changes the UI should notify the user about.
  Stream<SyncRejection> get rejections => _rejections.stream;

  /// Begins draining on every queue change and merging server pushes.
  void start() {
    _queueSub = _queueDao.watchAll().listen((_) => drain());
    _pushSub = _api.taskUpdates().listen(_onServerPush);
  }

  Future<void> dispose() async {
    await _queueSub?.cancel();
    await _pushSub?.cancel();
    await _rejections.close();
  }

  /// Drains the queue until it is empty or the head op stalls. Re-entrant calls
  /// are ignored so only one op is ever in flight.
  Future<void> drain() async {
    if (_draining) return;
    _draining = true;
    try {
      while (true) {
        final op = await _queueDao.next();
        if (op == null) break;
        final progressed = await _attempt(op);
        if (!progressed) break; // stalled — wait for the next queue change
      }
    } finally {
      _draining = false;
    }
  }

  /// A server push wins the confirmed layer (version-guarded). Pending ops live
  /// in a separate table, so this can never clobber an optimistic change; if the
  /// push makes a pending op illegal, the drain's conflict path drops it later.
  Future<void> _onServerPush(PatientTaskModel row) =>
      _taskDao.upsertFromServer(row.toEntity());

  /// Attempts one op. Returns true if the queue moved forward (op resolved, or a
  /// retry was scheduled), false if the op stalled and draining should pause.
  Future<bool> _attempt(PendingOperation op) async {
    try {
      await _syncOnce(op);
      return true;
    } on TransientException {
      if (op.attempt + 1 >= _maxAttempts) return false; // keep op, stop
      await _queueDao.bumpAttempt(op.seq);
      await _delay(_backoff.delayFor(op.attempt));
      return true; // loop retries the same head op
    }
  }

  Future<void> _syncOnce(PendingOperation op) async {
    try {
      final updated = await _api.patchStatus(
        taskId: op.taskId,
        status: op.toStatus,
        expectedVersion: op.baseVersion,
      );
      await _taskDao.upsertFromServer(updated.toEntity());
      await _queueDao.deleteOp(op.seq);
    } on ConflictException {
      await _resolveConflict(op);
    }
  }

  /// Server-wins + re-validate. Pulls the authoritative row, lets it win the
  /// confirmed layer, then re-checks the pending transition against it.
  Future<void> _resolveConflict(PendingOperation op) async {
    final server = await _api.getTask(op.taskId);
    if (server == null) {
      await _drop(op, 'Task no longer exists on the server');
      return;
    }

    await _taskDao.upsertFromServer(server.toEntity());

    if (server.status.canTransitionTo(op.toStatus)) {
      // Still legal from the new server state — re-base and retry.
      await _queueDao.setBaseVersion(op.seq, server.version);
    } else {
      await _drop(op, 'Server moved the task to ${server.status.name}');
    }
  }

  Future<void> _drop(PendingOperation op, String reason) async {
    await _queueDao.deleteOp(op.seq);
    _rejections.add(SyncRejection(op.taskId, reason));
  }
}
