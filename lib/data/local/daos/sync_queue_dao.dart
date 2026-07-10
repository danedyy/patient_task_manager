import 'package:drift/drift.dart';

import '../../../domain/entities/task_status.dart';
import '../app_database.dart';
import '../tables.dart';

part 'sync_queue_dao.g.dart';

/// Reads and writes the persistent sync queue ([PendingOperations]).
@DriftAccessor(tables: [PendingOperations])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  /// Drives the "syncing…" indicator.
  Stream<int> watchCount() {
    final count = pendingOperations.seq.count();
    final query = selectOnly(pendingOperations)..addColumns([count]);
    return query.map((row) => row.read(count)!).watchSingle();
  }

  /// All ops in FIFO order; the repository folds these onto the confirmed rows.
  Stream<List<PendingOperation>> watchAll() => (select(
    pendingOperations,
  )..orderBy([(t) => OrderingTerm.asc(t.seq)])).watch();

  Future<void> enqueue({
    required String taskId,
    required TaskStatus from,
    required TaskStatus to,
    required int baseVersion,
    required DateTime createdAt,
  }) => into(pendingOperations).insert(
    PendingOperationsCompanion.insert(
      taskId: taskId,
      fromStatus: from,
      toStatus: to,
      baseVersion: baseVersion,
      createdAt: createdAt,
    ),
  );

  /// The next op to attempt: global oldest by [seq].
  Future<PendingOperation?> next() =>
      (select(pendingOperations)
            ..orderBy([(t) => OrderingTerm.asc(t.seq)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> deleteOp(int seq) =>
      (delete(pendingOperations)..where((t) => t.seq.equals(seq))).go();

  /// Increments the retry counter in place (attempt = attempt + 1).
  Future<void> bumpAttempt(int seq) => customUpdate(
    'UPDATE pending_operations SET attempt = attempt + 1 WHERE seq = ?',
    variables: [Variable.withInt(seq)],
    updates: {pendingOperations},
  );

  /// Re-baselines an op after a 409 was resolved as "still legal".
  Future<void> setBaseVersion(int seq, int baseVersion) =>
      (update(pendingOperations)..where((t) => t.seq.equals(seq))).write(
        PendingOperationsCompanion(baseVersion: Value(baseVersion)),
      );
}
