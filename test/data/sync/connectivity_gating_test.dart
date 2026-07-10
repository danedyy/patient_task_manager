import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patient_task_manager/core/connectivity/connectivity_monitor.dart';
import 'package:patient_task_manager/data/local/app_database.dart';
import 'package:patient_task_manager/data/local/daos/sync_queue_dao.dart';
import 'package:patient_task_manager/data/local/daos/task_dao.dart';
import 'package:patient_task_manager/data/models/patient_task_model.dart';
import 'package:patient_task_manager/data/remote/patient_task_api.dart';
import 'package:patient_task_manager/data/sync/sync_engine.dart';
import 'package:patient_task_manager/domain/entities/patient_task.dart';
import 'package:patient_task_manager/domain/entities/task_status.dart';

class _MockApi extends Mock implements PatientTaskApi {}

/// Drives connectivity by hand: [isOnline] seeds the initial state, [emit]
/// pushes later transitions.
class _FakeConnectivity implements ConnectivityMonitor {
  _FakeConnectivity(this._initial);

  final bool _initial;
  final _controller = StreamController<bool>();

  @override
  Stream<bool> get connectivity => onStatusChange;

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  @override
  Future<bool> isOnline() async => _initial;

  void emit(bool online) => _controller.add(online);
  Future<void> dispose() => _controller.close();
}

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
  late _FakeConnectivity connectivity;
  late SyncEngine engine;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    taskDao = db.taskDao;
    queueDao = db.syncQueueDao;
    api = _MockApi();
    // Never a real server push; connectivity is what this test exercises.
    when(api.taskUpdates).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() async {
    await engine.dispose();
    await connectivity.dispose();
    await db.close();
  });

  Future<int> pending() => queueDao.watchCount().first;

  Future<void> enqueueOne() => queueDao.enqueue(
    taskId: 't1',
    from: TaskStatus.requested,
    to: TaskStatus.inProgress,
    baseVersion: 1,
    createdAt: t0,
  );

  test('offline: a queued op is not sent and stays in the queue', () async {
    connectivity = _FakeConnectivity(false);
    engine = SyncEngine(
      api: api,
      taskDao: taskDao,
      queueDao: queueDao,
      connectivity: connectivity,
      delay: (_) async {},
    )..start();
    await taskDao.upsertFromServer(
      model('t1', TaskStatus.requested, 1).toEntity(),
    );

    await enqueueOne();
    await pumpEventQueue();

    verifyNever(
      () => api.patchStatus(
        taskId: any(named: 'taskId'),
        status: any(named: 'status'),
        expectedVersion: any(named: 'expectedVersion'),
      ),
    );
    expect(await pending(), 1);
  });

  test('reconnecting flushes the ops that piled up while offline', () async {
    connectivity = _FakeConnectivity(false);
    engine = SyncEngine(
      api: api,
      taskDao: taskDao,
      queueDao: queueDao,
      connectivity: connectivity,
      delay: (_) async {},
    )..start();
    await taskDao.upsertFromServer(
      model('t1', TaskStatus.requested, 1).toEntity(),
    );
    when(
      () => api.patchStatus(
        taskId: 't1',
        status: TaskStatus.inProgress,
        expectedVersion: 1,
      ),
    ).thenAnswer((_) async => model('t1', TaskStatus.inProgress, 2));

    await enqueueOne();
    await pumpEventQueue();
    expect(await pending(), 1); // still queued while offline

    connectivity.emit(true);
    await pumpEventQueue();

    verify(
      () => api.patchStatus(
        taskId: 't1',
        status: TaskStatus.inProgress,
        expectedVersion: 1,
      ),
    ).called(1);
    expect(await pending(), 0);
  });

  test(
    'offline: an inbound server push is dropped, not applied or replayed',
    () async {
      final pushes = StreamController<PatientTaskModel>();
      when(api.taskUpdates).thenAnswer((_) => pushes.stream);

      connectivity = _FakeConnectivity(false);
      engine = SyncEngine(
        api: api,
        taskDao: taskDao,
        queueDao: queueDao,
        connectivity: connectivity,
        delay: (_) async {},
      )..start();
      await taskDao.upsertFromServer(
        model('t1', TaskStatus.requested, 1).toEntity(),
      );
      await pumpEventQueue(); // let the offline seed land

      // A delta arrives while we are offline: it is dropped, not applied.
      pushes.add(model('t1', TaskStatus.completed, 2));
      await pumpEventQueue();
      var row = (await taskDao.watchAll().first).single;
      expect(row.status, TaskStatus.requested);
      expect(row.version, 1);

      // Reconnecting does NOT replay the missed delta (reconciliation is the
      // repository's refetch job, not a buffered stream).
      connectivity.emit(true);
      await pumpEventQueue();
      row = (await taskDao.watchAll().first).single;
      expect(row.status, TaskStatus.requested);

      // A delta that arrives while online is applied normally.
      pushes.add(model('t1', TaskStatus.completed, 2));
      await pumpEventQueue();
      row = (await taskDao.watchAll().first).single;
      expect(row.status, TaskStatus.completed);
      expect(row.version, 2);

      await pushes.close();
    },
  );
}
