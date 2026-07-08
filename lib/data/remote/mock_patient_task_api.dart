import 'dart:math';

import '../../core/failure/failure_exceptions.dart';
import '../../domain/entities/patient_task.dart';
import '../../domain/entities/task_status.dart';
import '../models/patient_task_model.dart';
import 'patient_task_api.dart';

/// In-memory implementation of [PatientTaskApi] backed by a seeded task table.
///
/// Everything nondeterministic — failures and the push interval — is injected,
/// so the exact same class runs fully deterministic under tests (fixed [Random]
/// seed) and lively in the app.
class MockPatientTaskApi implements PatientTaskApi {
  /// Server rows keyed by id; each carries its own version counter.
  final Map<String, PatientTaskModel> _tasks;
  final Random _random;
  final DateTime Function() _clock;

  /// Probability a [fetchTasks]/[patchStatus] call fails transiently (0..1).
  final double _failureRate;

  /// How often [taskUpdates] emits a server-side change.
  final Duration _pushInterval;

  MockPatientTaskApi({
    List<PatientTaskModel>? seed,
    Random? random,
    DateTime Function()? clock,
    this._failureRate = 0.15,
    this._pushInterval = const Duration(seconds: 5),
  })  : _tasks = {for (final t in seed ?? _defaultSeed()) t.id: t},
        _random = random ?? Random(),
        _clock = clock ?? DateTime.now;

  @override
  Future<TaskPage> fetchTasks({
    int page = 0,
    int pageSize = 20,
    String? query,
  }) async {
    _maybeFail();

    final q = query?.trim().toLowerCase() ?? '';
    // Stable sort by id so pagination is deterministic across calls.
    final matches = _tasks.values
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
  Stream<PatientTaskModel> taskUpdates() =>
      Stream.periodic(_pushInterval, (_) => _pushOne())
          .where((t) => t != null)
          .cast<PatientTaskModel>();

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

/// A fixed spread of ~15 tasks across patients, priorities, and statuses.
List<PatientTaskModel> _defaultSeed() {
  final base = DateTime.utc(2026, 7, 1);
  const statuses = TaskStatus.values;
  const priorities = TaskPriority.values;
  const titles = [
    'Draw blood sample',
    'Administer medication',
    'Vitals check',
    'Wound dressing change',
    'Physiotherapy session',
    'ECG recording',
    'Insulin adjustment',
    'Discharge paperwork',
    'X-ray review',
    'IV line replacement',
    'Nutrition consult',
    'Pain reassessment',
    'Fall-risk assessment',
    'Catheter removal',
    'Post-op observation',
  ];

  return [
    for (var i = 0; i < titles.length; i++)
      PatientTaskModel(
        id: 't${i + 1}',
        version: 1,
        title: titles[i],
        status: statuses[i % statuses.length],
        priority: priorities[i % priorities.length],
        patientReference: 'Patient/${(i % 5) + 1}',
        lastModified: base.add(Duration(hours: i)),
        dueDate: i.isEven ? base.add(Duration(days: i + 1)) : null,
        assignee: i % 3 == 0 ? 'Practitioner/${(i % 4) + 1}' : null,
      ),
  ];
}
