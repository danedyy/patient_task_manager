import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../../domain/entities/patient_task.dart';
import '../../domain/entities/task_status.dart';
import 'daos/sync_queue_dao.dart';
import 'daos/task_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [ConfirmedTasks, PendingOperations],
  daos: [TaskDao, SyncQueueDao],
)
class AppDatabase extends _$AppDatabase {
  /// Takes a [QueryExecutor] so tests can inject `NativeDatabase.memory()`.
  AppDatabase(super.e);

  /// Production opener: an on-disk SQLite file.
  factory AppDatabase.open() =>
      AppDatabase(driftDatabase(name: 'patient_tasks'));

  @override
  int get schemaVersion => 1;
}
