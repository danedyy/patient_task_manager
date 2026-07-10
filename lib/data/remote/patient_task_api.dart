import '../../core/cancellation.dart';
import '../../domain/entities/task_status.dart';
import '../models/patient_task_model.dart';
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
}

/// The remote boundary. The repository depends on this interface, never on a
/// concrete client, so the in-memory [MockPatientTaskApi] and a future HTTP
/// implementation are drop-in swappable.
///
/// It speaks [PatientTaskModel], the wire DTO, because a real HTTP client
/// would hand back exactly `PatientTaskModel.fromJson(response)`.
abstract interface class PatientTaskApi {
  /// Server-side paginated fetch. [query] filters by title when non-empty.
  /// Throws [TransientException] to simulate an intermittent network failure,
  /// or [OperationCancelledException] if [cancelToken] is cancelled in flight.
  Future<TaskPage> fetchTasks({
    int page,
    int pageSize,
    String? query,
    CancellationToken? cancelToken,
  });

  /// Optimistic-concurrency status write. Returns the updated server row.
  ///
  /// Throws [ConflictException] when [expectedVersion] no longer matches the
  /// server's version, or [TransientException] on a simulated 5xx.
  Future<PatientTaskModel> patchStatus({
    required String taskId,
    required TaskStatus status,
    required int expectedVersion,
  });

  /// Fetches a single task's current server row, or null if it no longer
  /// exists. Used by conflict resolution to re-read the authoritative status.
  Future<PatientTaskModel?> getTask(String id);

  /// A live feed of server-originated task changes (another client).
  /// Each event is the full updated row.
  Stream<PatientTaskModel> taskUpdates();
}
