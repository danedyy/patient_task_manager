import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:patient_task_manager/core/failure/failure_exceptions.dart';
import 'package:patient_task_manager/data/models/patient_task_model.dart';
import 'package:patient_task_manager/data/remote/mock_patient_task_api.dart';
import 'package:patient_task_manager/domain/entities/patient_task.dart';
import 'package:patient_task_manager/domain/entities/task_status.dart';

void main() {
  final clock = DateTime.utc(2026, 7, 7, 9);

  PatientTaskModel row(String id, TaskStatus status, {int version = 1}) =>
      PatientTaskModel(
        id: id,
        version: version,
        title: 'task $id',
        status: status,
        priority: TaskPriority.routine,
        patientReference: 'Patient/1',
        lastModified: DateTime.utc(2026, 1, 1),
      );

  // Deterministic API: no random failures, no latency, fixed seed + clock.
  MockPatientTaskApi api(List<PatientTaskModel> seed) => MockPatientTaskApi(
        seed: seed,
        random: Random(1),
        clock: () => clock,
        failureRate: 0,
      );

  group('fetchTasks', () {
    test('paginates deterministically and reports total', () async {
      final seed = [
        for (var i = 1; i <= 5; i++) row('t$i', TaskStatus.requested),
      ];
      final page0 = await api(seed).fetchTasks(page: 0, pageSize: 2);

      expect(page0.items.map((t) => t.id), ['t1', 't2']);
      expect(page0.total, 5);
      expect(page0.hasMore, isTrue);

      final page2 = await api(seed).fetchTasks(page: 2, pageSize: 2);
      expect(page2.items.map((t) => t.id), ['t5']);
      expect(page2.hasMore, isFalse);
    });

    test('filters by title query, case-insensitively', () async {
      final seed = [
        row('t1', TaskStatus.requested).copyWith(title: 'Draw blood'),
        row('t2', TaskStatus.requested).copyWith(title: 'Vitals check'),
      ];
      final page = await api(seed).fetchTasks(query: 'BLOOD');

      expect(page.items.single.id, 't1');
      expect(page.total, 1);
    });

    test('throws TransientException when the failure rate fires', () async {
      final failing = MockPatientTaskApi(
        seed: [row('t1', TaskStatus.requested)],
        random: Random(1),
        failureRate: 1,
      );
      expect(failing.fetchTasks(), throwsA(isA<TransientException>()));
    });
  });

  group('patchStatus', () {
    test('increments version and stamps lastModified on success', () async {
      final subject = api([row('t1', TaskStatus.requested)]);

      final updated = await subject.patchStatus(
        taskId: 't1',
        status: TaskStatus.inProgress,
        expectedVersion: 1,
      );

      expect(updated.status, TaskStatus.inProgress);
      expect(updated.version, 2);
      expect(updated.lastModified, clock);
    });

    test('throws ConflictException on a stale expectedVersion', () async {
      final subject = api([row('t1', TaskStatus.requested, version: 4)]);

      expect(
        subject.patchStatus(
          taskId: 't1',
          status: TaskStatus.inProgress,
          expectedVersion: 3,
        ),
        throwsA(isA<ConflictException>()
            .having((e) => e.serverVersion, 'serverVersion', 4)),
      );
    });
  });

  group('taskUpdates', () {
    test('emits only legal transitions of non-terminal tasks', () async {
      final subject = MockPatientTaskApi(
        seed: [row('t1', TaskStatus.requested)],
        random: Random(1),
        clock: () => clock,
        pushInterval: const Duration(milliseconds: 1),
      );

      final event = await subject.taskUpdates().first;

      expect(event.id, 't1');
      expect(TaskStatus.requested.allowedNext, contains(event.status));
      expect(event.version, 2);
    });

    test('stays silent once every task is terminal', () async {
      final subject = MockPatientTaskApi(
        seed: [row('t1', TaskStatus.completed)],
        pushInterval: const Duration(milliseconds: 1),
      );

      final event = await subject
          .taskUpdates()
          .map<PatientTaskModel?>((e) => e)
          .first
          .timeout(const Duration(milliseconds: 20), onTimeout: () => null);

      expect(event, isNull);
    });
  });

  group('getTask', () {
    test('returns the current row, or null when unknown', () async {
      final subject = api([row('t1', TaskStatus.requested)]);

      expect((await subject.getTask('t1'))?.id, 't1');
      expect(await subject.getTask('missing'), isNull);
    });
  });
}
