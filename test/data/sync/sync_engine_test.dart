import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patient_task_manager/core/failure/failure_exceptions.dart';
import 'package:patient_task_manager/data/local/app_database.dart';
import 'package:patient_task_manager/data/local/daos/sync_queue_dao.dart';
import 'package:patient_task_manager/data/local/daos/task_dao.dart';
import 'package:patient_task_manager/data/models/patient_task_model.dart';
import 'package:patient_task_manager/data/remote/patient_task_api.dart';
import 'package:patient_task_manager/data/sync/sync_engine.dart';
import 'package:patient_task_manager/domain/entities/patient_task.dart';
import 'package:patient_task_manager/domain/entities/sync_rejection.dart';
import 'package:patient_task_manager/domain/entities/task_status.dart';

import '../../support/connectivity_fakes.dart';

class _MockApi extends Mock implements PatientTaskApi {}

void main() {
  setUpAll(() => registerFallbackValue(TaskStatus.requested));

  final t0 = DateTime.utc(2026, 1, 1);

  PatientTaskModel model(String id, TaskStatus status, int version) =>
      PatientTaskModel(
        id: id,
        version: version,
        title: 'task $id',
        status: status,
        priority: TaskPriority.routine,
        patientReference: 'Patient/1',
        lastModified: t0,
      );

  late AppDatabase db;
  late TaskDao taskDao;
  late SyncQueueDao queueDao;
  late _MockApi api;
  late SyncEngine engine;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    taskDao = db.taskDao;
    queueDao = db.syncQueueDao;
    api = _MockApi();
    // Instant delay so backoff never spends real time.
    engine = SyncEngine(
      api: api,
      taskDao: taskDao,
      queueDao: queueDao,
      connectivity: const AlwaysOnline(),
      delay: (_) async {},
    );
  });

  tearDown(() async {
    await engine.dispose();
    await db.close();
  });

  Future<void> seed(PatientTaskModel m) =>
      taskDao.upsertFromServer(m.toEntity());

  Future<PatientTask> confirmed(String id) async =>
      (await taskDao.watchAll().first).firstWhere((t) => t.id == id);
  Future<int> pending() => queueDao.watchCount().first;

  test(
    'drains a queued op: patches, confirms new version, clears queue',
    () async {
      await seed(model('t1', TaskStatus.requested, 1));
      await queueDao.enqueue(
        taskId: 't1',
        from: TaskStatus.requested,
        to: TaskStatus.inProgress,
        baseVersion: 1,
        createdAt: t0,
      );
      when(
        () => api.patchStatus(
          taskId: 't1',
          status: TaskStatus.inProgress,
          expectedVersion: 1,
        ),
      ).thenAnswer((_) async => model('t1', TaskStatus.inProgress, 2));

      await engine.drain();

      final row = await confirmed('t1');
      expect(row.status, TaskStatus.inProgress);
      expect(row.version, 2);
      expect(await pending(), 0);
    },
  );

  test('retries a transient failure and eventually succeeds', () async {
    await seed(model('t1', TaskStatus.requested, 1));
    await queueDao.enqueue(
      taskId: 't1',
      from: TaskStatus.requested,
      to: TaskStatus.inProgress,
      baseVersion: 1,
      createdAt: t0,
    );
    var calls = 0;
    when(
      () => api.patchStatus(
        taskId: 't1',
        status: TaskStatus.inProgress,
        expectedVersion: 1,
      ),
    ).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw const TransientException('boom');
      return model('t1', TaskStatus.inProgress, 2);
    });

    await engine.drain();

    expect(calls, 2);
    expect(await pending(), 0);
  });

  test('keeps the op and stops after maxAttempts transient failures', () async {
    engine = SyncEngine(
      api: api,
      taskDao: taskDao,
      queueDao: queueDao,
      connectivity: const AlwaysOnline(),
      delay: (_) async {},
      maxAttempts: 3,
    );
    await seed(model('t1', TaskStatus.requested, 1));
    await queueDao.enqueue(
      taskId: 't1',
      from: TaskStatus.requested,
      to: TaskStatus.inProgress,
      baseVersion: 1,
      createdAt: t0,
    );
    when(
      () => api.patchStatus(
        taskId: any(named: 'taskId'),
        status: any(named: 'status'),
        expectedVersion: any(named: 'expectedVersion'),
      ),
    ).thenThrow(const TransientException('down'));

    await engine.drain();

    verify(
      () => api.patchStatus(
        taskId: any(named: 'taskId'),
        status: any(named: 'status'),
        expectedVersion: any(named: 'expectedVersion'),
      ),
    ).called(3);
    expect(await pending(), 1); // retained, not dropped
  });

  test('resolves a conflict: re-reads server, re-bases, retries', () async {
    await seed(model('t1', TaskStatus.requested, 1));
    await queueDao.enqueue(
      taskId: 't1',
      from: TaskStatus.requested,
      to: TaskStatus.inProgress,
      baseVersion: 1,
      createdAt: t0,
    );
    var calls = 0;
    when(
      () => api.patchStatus(
        taskId: any(named: 'taskId'),
        status: any(named: 'status'),
        expectedVersion: any(named: 'expectedVersion'),
      ),
    ).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw const ConflictException('t1', 5);
      return model('t1', TaskStatus.inProgress, 6);
    });
    when(
      () => api.getTask('t1'),
    ).thenAnswer((_) async => model('t1', TaskStatus.requested, 5));

    await engine.drain();

    expect(calls, 2);
    verify(() => api.getTask('t1')).called(1);
    final row = await confirmed('t1');
    expect(row.version, 6);
    expect(row.status, TaskStatus.inProgress);
    expect(await pending(), 0);
  });

  test(
    'drops the op and emits a rejection when the server made it illegal',
    () async {
      await seed(model('t1', TaskStatus.inProgress, 1));
      await queueDao.enqueue(
        taskId: 't1',
        from: TaskStatus.inProgress,
        to: TaskStatus.onHold,
        baseVersion: 1,
        createdAt: t0,
      );
      when(
        () => api.patchStatus(
          taskId: any(named: 'taskId'),
          status: any(named: 'status'),
          expectedVersion: any(named: 'expectedVersion'),
        ),
      ).thenThrow(const ConflictException('t1', 9));
      when(
        () => api.getTask('t1'),
      ).thenAnswer((_) async => model('t1', TaskStatus.completed, 9));

      final rejections = <SyncRejection>[];
      final sub = engine.rejections.listen(rejections.add);

      await engine.drain();
      await pumpEventQueue();

      expect(rejections, hasLength(1));
      expect(rejections.single.taskId, 't1');
      expect(
        await confirmed('t1'),
        isA<PatientTask>().having(
          (t) => t.status,
          'status',
          TaskStatus.completed,
        ),
      );
      expect(await pending(), 0);
      await sub.cancel();
    },
  );

  test(
    'drops the op and emits a rejection when the task no longer exists',
    () async {
      await seed(model('t1', TaskStatus.requested, 1));
      await queueDao.enqueue(
        taskId: 't1',
        from: TaskStatus.requested,
        to: TaskStatus.inProgress,
        baseVersion: 1,
        createdAt: t0,
      );
      when(
        () => api.patchStatus(
          taskId: any(named: 'taskId'),
          status: any(named: 'status'),
          expectedVersion: any(named: 'expectedVersion'),
        ),
      ).thenThrow(const ConflictException('t1', 2));
      when(() => api.getTask('t1')).thenAnswer((_) async => null);

      final rejections = <SyncRejection>[];
      final sub = engine.rejections.listen(rejections.add);

      await engine.drain();
      await pumpEventQueue();

      expect(rejections.single.reason, contains('no longer exists'));
      expect(await pending(), 0);
      await sub.cancel();
    },
  );

  test('start(): merges a server push into the confirmed layer', () async {
    await seed(model('t1', TaskStatus.requested, 1));
    final pushes = StreamController<PatientTaskModel>();
    when(() => api.taskUpdates()).thenAnswer((_) => pushes.stream);

    engine.start();
    pushes.add(model('t1', TaskStatus.inProgress, 2));
    await pumpEventQueue();

    final row = await confirmed('t1');
    expect(row.status, TaskStatus.inProgress);
    expect(row.version, 2);
    await pushes.close();
  });
}
