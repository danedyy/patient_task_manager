import 'package:drift/drift.dart';

import '../../domain/entities/patient_task.dart';
import '../../domain/entities/task_status.dart';

/// This is the "confirmed" layer: server refreshes and pushes write here, and
/// the version-guarded upsert in the DAO keeps it monotonic. 
class ConfirmedTasks extends Table {
  TextColumn get id => text()();
  IntColumn get version => integer()();
  TextColumn get title => text()();
  TextColumn get status => textEnum<TaskStatus>()();
  TextColumn get priority => textEnum<TaskPriority>()();
  TextColumn get patientReference => text()();
  DateTimeColumn get lastModified => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get assignee => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}


/// Pending local mutations live in [PendingOperations] and are folded on top; they never
/// touch this table, so a server push can never clobber optimistic state.
/// It is an ordinary table so it survives an app kill and is re-read on launch.
class PendingOperations extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get taskId => text()();
  TextColumn get fromStatus => textEnum<TaskStatus>()();
  TextColumn get toStatus => textEnum<TaskStatus>()();

  /// Server version this op was created against: the 409 re-validation baseline.
  IntColumn get baseVersion => integer()();
  IntColumn get attempt => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}
