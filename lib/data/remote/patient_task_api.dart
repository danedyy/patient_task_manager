import '../../domain/entities/task_status.dart';
import '../models/patient_task_model.dart';

/// One page of a server-side paginated task list.
///
/// [total] is the count of tasks matching the query across all pages, so the
/// caller can tell whether another page exists without fetching it.
class TaskPage {
  final List<PatientTaskModel> items;
  final int page;
  final int pageSize;
  final int total;

  const TaskPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  bool get hasMore => (page + 1) * pageSize < total;
}

/// The remote boundary. The repository depends on this interface, never on a
/// concrete client, so the in-memory [MockPatientTaskApi] and a future HTTP
/// implementation are drop-in swappable.
///
/// It speaks [PatientTaskModel] — the wire DTO — because a real HTTP client
/// would hand back exactly `PatientTaskModel.fromJson(response)`.
abstract interface class PatientTaskApi {
  /// Server-side paginated fetch. [query] filters by title when non-empty.
  /// Throws [TransientException] to simulate an intermittent network failure.
  Future<TaskPage> fetchTasks({int page, int pageSize, String? query});

  /// Optimistic-concurrency status write. Returns the updated server row.
  ///
  /// Throws [ConflictException] when [expectedVersion] no longer matches the
  /// server's version, or [TransientException] on a simulated 5xx.
  Future<PatientTaskModel> patchStatus({
    required String taskId,
    required TaskStatus status,
    required int expectedVersion,
  });

  /// A live feed of server-originated task changes (another client).
  /// Each event is the full updated row.
  Stream<PatientTaskModel> taskUpdates();
}
