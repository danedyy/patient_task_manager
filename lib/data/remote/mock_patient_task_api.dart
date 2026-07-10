import 'dart:math';

import '../../core/cancellation.dart';
import '../../core/failure/failure_exceptions.dart';
import '../../domain/entities/task_status.dart';
import '../models/patient_task_model.dart';
import 'mock_task_seed.dart';
import 'patient_task_api.dart';

/// In-memory implementation of [PatientTaskApi] backed by a seeded task table.
///
/// Everything nondeterministic failures, and the push interval is
/// injected, so the exact same class runs fully deterministic under tests
/// (fixed [Random] seed, zero delay) and lively in the app.
class MockPatientTaskApi implements PatientTaskApi {
  /// Server rows keyed by id; each carries its own version counter.
  final Map<String, PatientTaskModel> _tasks;
  final Random _random;
  final DateTime Function() _clock;

  final double _failureRate;

  /// How often [taskUpdates] emits a server-side change.
  final Duration _pushInterval;

  MockPatientTaskApi({
    List<PatientTaskModel>? seed,
    Random? random,
    DateTime Function()? clock,
    this._failureRate = 0.15,
    this._pushInterval = const Duration(seconds: 5),
  }) : _tasks = {for (final t in seed ?? defaultTaskSeed()) t.id: t},
       _random = random ?? Random(),
       _clock = clock ?? DateTime.now;

  @override
  Future<TaskPage> fetchTasks({
    int page = 0,
    int pageSize = 20,
    String? query,
    CancellationToken? cancelToken,
  }) async {
    _maybeFail();
    // The "network" gap: after it, honour a cancellation that arrived while the
    // request was in flight (a newer search superseded this one).
    await Future<void>.delayed(Duration.zero);
    cancelToken?.throwIfCancelled();

    final q = query?.trim().toLowerCase() ?? '';
    // Stable sort by id so pagination is deterministic across calls.
    final matches =
        _tasks.values
            .where((t) => q.isEmpty || t.title.toLowerCase().contains(q))
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));

    final start = page * pageSize;
    final items = start >= matches.length
        ? const <PatientTaskModel>[]
        : matches.sublist(start, min(start + pageSize, matches.length));

    return TaskPage(
      items: items,
      page: page,
      pageSize: pageSize,
      total: matches.length,
    );
  }

  @override
  Future<PatientTaskModel> patchStatus({
    required String taskId,
    required TaskStatus status,
    required int expectedVersion,
  }) async {
    _maybeFail();

    final current = _tasks[taskId];
    if (current == null) throw StateError('unknown task $taskId');

    // Optimistic concurrency: reject a write built on a stale version.
    if (current.version != expectedVersion) {
      throw ConflictException(taskId, current.version);
    }

    final updated = current.copyWith(
      status: status,
      version: current.version + 1,
      lastModified: _clock(),
    );
    _tasks[taskId] = updated;
    return updated;
  }

  // Deterministic on purpose: conflict resolution reads through this, and a
  // reliable re-read keeps that path bounded. Failures are injected on the
  // write path ([patchStatus]) and the list path ([fetchTasks]) instead.
  @override
  Future<PatientTaskModel?> getTask(String id) async => _tasks[id];

  @override
  Stream<PatientTaskModel> taskUpdates() => Stream.periodic(
    _pushInterval,
    (_) => _pushOne(),
  ).where((t) => t != null).cast<PatientTaskModel>();

  /// Advances one random non-terminal task along a legal transition and
  /// returns the new row, or null when every task is already terminal.
  PatientTaskModel? _pushOne() {
    final open = _tasks.values.where((t) => !t.status.isTerminal).toList();
    if (open.isEmpty) return null;

    final task = open[_random.nextInt(open.length)];
    final next = task.status.allowedNext.toList();
    final updated = task.copyWith(
      status: next[_random.nextInt(next.length)],
      version: task.version + 1,
      lastModified: _clock(),
    );
    _tasks[task.id] = updated;
    return updated;
  }

  void _maybeFail() {
    if (_random.nextDouble() < _failureRate) {
      throw const TransientException('simulated network error');
    }
  }
}
