import 'package:drift/drift.dart';

import '../../domain/entities/patient_task.dart';
import '../../domain/entities/task_status.dart';

/// The last known **server** state — one row per task, keyed by [id].
///
/// This is the "confirmed" layer: server refreshes and pushes write here, and
/// the version-guarded upsert in the DAO keeps it monotonic. Pending local
/// mutations live in [PendingOperations] and are folded on top; they never
/// touch this table, so a server push can never clobber optimistic state.
class ConfirmedTasks extends Table {
  TextColumn get id => text()();
  IntColumn get version => integer()();
  TextColumn get title => text()();
  // textEnum stores the enum's name (not its index) — readable rows, no
  // fragility if the enum is reordered; replaces a hand-written TypeConverter.
  TextColumn get status => textEnum<TaskStatus>()();
  TextColumn get priority => textEnum<TaskPriority>()();
  TextColumn get patientReference => text()();
  DateTimeColumn get lastModified => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get assignee => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The persistent sync queue — the "pending-ops" layer.
///
/// It is an ordinary table so it survives an app kill and is re-read on launch.
class PendingOperations extends Table {
  /// Autoincrement rowid: doubles as the op's identity and the global FIFO
  /// order. Draining oldest-[seq]-first preserves per-task order automatically.
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get taskId => text()();
  TextColumn get fromStatus => textEnum<TaskStatus>()();
  TextColumn get toStatus => textEnum<TaskStatus>()();

  /// Server version this op was created against — the 409 re-validation baseline.
  IntColumn get baseVersion => integer()();
  IntColumn get attempt => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}
