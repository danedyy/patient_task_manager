import 'package:drift/drift.dart';

import '../../../domain/entities/patient_task.dart';
import '../app_database.dart';
import '../tables.dart';

part 'task_dao.g.dart';

/// Reads and writes the confirmed-server layer, speaking the domain
/// [PatientTask] so the repository never sees Drift row types.
@DriftAccessor(tables: [ConfirmedTasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Stream<List<PatientTask>> watchAll() =>
      select(confirmedTasks).watch().map((rows) => rows.map(_toDomain).toList());

  /// Upserts a server snapshot, but only when it is **newer** than the row we
  /// already hold. This makes server pushes idempotent and safe against
  /// out-of-order arrival: a stale push can never roll the confirmed state back.
  Future<void> upsertFromServer(PatientTask task) =>
      into(confirmedTasks).insert(
        _toCompanion(task),
        onConflict: DoUpdate(
          (_) => _toCompanion(task),
          where: (old) => old.version.isSmallerThanValue(task.version),
        ),
      );

  /// Replaces the whole confirmed table in one transaction — used by refresh.
  Future<void> replaceAll(List<PatientTask> tasks) => transaction(() async {
    await delete(confirmedTasks).go();
    await batch((b) => b.insertAll(confirmedTasks, tasks.map(_toCompanion)));
  });

  PatientTask _toDomain(ConfirmedTask row) => PatientTask(
    id: row.id,
    version: row.version,
    title: row.title,
    status: row.status,
    priority: row.priority,
    patientReference: row.patientReference,
    lastModified: row.lastModified,
    dueDate: row.dueDate,
    assignee: row.assignee,
  );

  ConfirmedTasksCompanion _toCompanion(PatientTask t) =>
      ConfirmedTasksCompanion.insert(
        id: t.id,
        version: t.version,
        title: t.title,
        status: t.status,
        priority: t.priority,
        patientReference: t.patientReference,
        lastModified: t.lastModified,
        dueDate: Value.absentIfNull(t.dueDate),
        assignee: Value.absentIfNull(t.assignee),
      );
}
