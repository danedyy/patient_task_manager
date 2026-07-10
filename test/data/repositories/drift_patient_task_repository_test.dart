import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_task_manager/core/cancellation.dart';
import 'package:patient_task_manager/core/failure/failure_exceptions.dart';
import 'package:patient_task_manager/data/local/app_database.dart';
import 'package:patient_task_manager/data/local/daos/sync_queue_dao.dart';
import 'package:patient_task_manager/data/local/daos/task_dao.dart';
import 'package:patient_task_manager/data/models/patient_task_model.dart';
import 'package:patient_task_manager/data/remote/mock_patient_task_api.dart';
import 'package:patient_task_manager/data/remote/patient_task_api.dart';
import 'package:patient_task_manager/data/repositories/drift_patient_task_repository.dart';
import 'package:patient_task_manager/data/sync/sync_engine.dart';
import 'package:patient_task_manager/domain/entities/patient_task.dart';
import 'package:patient_task_manager/domain/entities/task_status.dart';

import '../../support/connectivity_fakes.dart';

void main() {
  final t0 = DateTime.utc(2026, 1, 1);

  PatientTask entity(String id, TaskStatus status, int version) => PatientTask(
    id: id,
    version: version,
    title: 'task $id',
    status: status,
    priority: TaskPriority.routine,
    patientReference: 'Patient/1',
    lastModified: t0,
  );

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
  late DriftPatientTaskRepository repo;

  DriftPatientTaskRepository makeRepo(PatientTaskApi api) {
    final engine = SyncEngine(
      api: api,
      taskDao: taskDao,
      queueDao: queueDao,
      connectivity: const AlwaysOnline(),
      delay: (_) async {},
    );
    return DriftPatientTaskRepository(
      api: api,
      taskDao: taskDao,
      queueDao: queueDao,
      engine: engine,
      connectivity: const AlwaysOnline(),
      clock: () => t0,
    );
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    taskDao = db.taskDao;
    queueDao = db.syncQueueDao;
    // Default api is unused by the fold/updateStatus tests; refresh tests build
    // their own with a controlled seed / failure rate.
    repo = makeRepo(MockPatientTaskApi(failureRate: 0));
  });

  tearDown(() => db.close());

  test(
    'watchTasks folds pending ops onto confirmed rows (version untouched)',
    () async {
      await taskDao.upsertFromServer(entity('t1', TaskStatus.requested, 1));
      await queueDao.enqueue(
        taskId: 't1',
        from: TaskStatus.requested,
        to: TaskStatus.inProgress,
        baseVersion: 1,
        createdAt: t0,
      );

      final tasks = await repo.watchTasks().first;

      expect(tasks.single.status, TaskStatus.inProgress); // optimistic
      expect(tasks.single.version, 1); // still the server's version
    },
  );

  test(
    'updateStatus enqueues a legal transition and shows it optimistically',
    () async {
      await taskDao.upsertFromServer(entity('t1', TaskStatus.requested, 1));

      await repo.updateStatus('t1', TaskStatus.inProgress);

      expect(await queueDao.watchCount().first, 1);
      final tasks = await repo.watchTasks().first;
      expect(tasks.single.status, TaskStatus.inProgress);
    },
  );

  test(
    'updateStatus throws on an illegal transition and enqueues nothing',
    () async {
      await taskDao.upsertFromServer(entity('t1', TaskStatus.completed, 1));

      await expectLater(
        repo.updateStatus('t1', TaskStatus.inProgress),
        throwsA(isA<InvalidTransitionException>()),
      );
      expect(await queueDao.watchCount().first, 0);
    },
  );

  test(
    'updateStatus validates against the folded intent, not the server row',
    () async {
      await taskDao.upsertFromServer(entity('t1', TaskStatus.requested, 1));

      // onHold is illegal from `requested` but legal from `inProgress`; the second
      // call must see the first op's intent, or it would be rejected.
      await repo.updateStatus('t1', TaskStatus.inProgress);
      await repo.updateStatus('t1', TaskStatus.onHold);

      expect(await queueDao.watchCount().first, 2);
      final tasks = await repo.watchTasks().first;
      expect(tasks.single.status, TaskStatus.onHold);
    },
  );

  test(
    'refresh replaces the confirmed layer with the server snapshot',
    () async {
      await taskDao.upsertFromServer(entity('stale', TaskStatus.requested, 1));
      final freshRepo = makeRepo(
        MockPatientTaskApi(
          seed: [model('t1', TaskStatus.inProgress, 3)],
          failureRate: 0,
        ),
      );

      await freshRepo.refresh();

      final tasks = await freshRepo.watchTasks().first;
      expect(tasks.map((t) => t.id), ['t1']);
      expect(tasks.single.status, TaskStatus.inProgress);
    },
  );

  test('refresh leaves local state untouched when the fetch fails', () async {
    await taskDao.upsertFromServer(entity('t1', TaskStatus.requested, 1));
    final failingRepo = makeRepo(
      MockPatientTaskApi(
        seed: [model('t2', TaskStatus.inProgress, 1)],
        failureRate: 1,
      ),
    );

    await expectLater(
      failingRepo.refresh(),
      throwsA(isA<TransientException>()),
    );
    final tasks = await failingRepo.watchTasks().first;
    expect(tasks.single.id, 't1');
  });

  test(
    'search merges matching server rows without dropping local ones',
    () async {
      await taskDao.upsertFromServer(entity('local', TaskStatus.onHold, 1));
      final searchRepo = makeRepo(
        MockPatientTaskApi(
          seed: [model('hit', TaskStatus.requested, 1)],
          failureRate: 0,
        ),
      );

      await searchRepo.fetchPage('task hit', 0);

      final ids = (await searchRepo.watchTasks().first)
          .map((t) => t.id)
          .toSet();
      expect(ids, containsAll(['local', 'hit'])); // merged, not replaced
    },
  );

  test(
    'search aborts without writing when its token is cancelled mid-flight',
    () async {
      await taskDao.upsertFromServer(entity('local', TaskStatus.onHold, 1));
      final searchRepo = makeRepo(
        MockPatientTaskApi(
          seed: [model('hit', TaskStatus.requested, 1)],
          failureRate: 0,
        ),
      );

      final token = CancellationToken();
      final pending = searchRepo.fetchPage('task hit', 0, cancelToken: token);
      token.cancel(); // a newer search supersedes this one while it's in flight

      await expectLater(pending, throwsA(isA<OperationCancelledException>()));
      final ids = (await searchRepo.watchTasks().first)
          .map((t) => t.id)
          .toSet();
      expect(ids, {'local'}); // 'hit' was never merged: the fetch aborted
    },
  );

  test('fetchPage reports whether more server pages remain', () async {
    final pagedRepo = makeRepo(
      MockPatientTaskApi(
        seed: [
          for (var i = 1; i <= 25; i++) model('t$i', TaskStatus.requested, 1),
        ],
        failureRate: 0,
      ),
    );

    // 25 rows, default pageSize 20: page 0 has more, page 1 is the last.
    expect(await pagedRepo.fetchPage('', 0), isTrue);
    expect(await pagedRepo.fetchPage('', 1), isFalse);

    // Both pages merged into the local cache.
    expect((await pagedRepo.watchTasks().first).length, 25);
  });

  test('a server push does not clobber a pending optimistic change', () async {
    await taskDao.upsertFromServer(entity('t1', TaskStatus.requested, 1));
    await repo.updateStatus(
      't1',
      TaskStatus.inProgress,
    ); // optimistic op @ base v1

    // A server push advances the confirmed row to v2 with a different status
    // (another client); the version-guarded upsert accepts it.
    await taskDao.upsertFromServer(entity('t1', TaskStatus.onHold, 2));

    final task = (await repo.watchTasks().first).single;
    expect(task.status, TaskStatus.inProgress); // optimistic intent still wins
    expect(task.version, 2); // confirmed layer advanced underneath the fold
  });

  test('watchPendingSyncCount reflects the queue', () async {
    await taskDao.upsertFromServer(entity('t1', TaskStatus.requested, 1));

    expect(await repo.watchPendingSyncCount().first, 0);
    await repo.updateStatus('t1', TaskStatus.inProgress);
    expect(await repo.watchPendingSyncCount().first, 1);
  });

  // Reconnect reconciliation is now a Bloc concern (it re-dispatches
  // RefreshRequested so the pagination cursor resets); see the bloc test
  // 'an offline -> online transition re-dispatches a refresh'.
  test(
    'offline: reads fail and leave the cache intact (no live seed/fetch)',
    () async {
      final offline = EmittableConnectivity(false); // isOnline() -> false
      final api = MockPatientTaskApi(
        seed: [model('server-only', TaskStatus.requested, 1)],
        failureRate: 0,
      );
      final offlineRepo = DriftPatientTaskRepository(
        api: api,
        taskDao: taskDao,
        queueDao: queueDao,
        engine: SyncEngine(
          api: api,
          taskDao: taskDao,
          queueDao: queueDao,
          connectivity: offline,
          delay: (_) async {},
        ),
        connectivity: offline,
        clock: () => t0,
      );
      addTearDown(offline.dispose);

      // Whatever was previously persisted locally is all the user should see.
      await taskDao.upsertFromServer(entity('cached', TaskStatus.requested, 1));

      await expectLater(
        offlineRepo.refresh(),
        throwsA(isA<TransientException>()),
      );
      await expectLater(
        offlineRepo.fetchPage('', 0),
        throwsA(isA<TransientException>()),
      );
      await expectLater(
        offlineRepo.fetchPage('', 1), // "load more" is gated too
        throwsA(isA<TransientException>()),
      );

      // The server's `server-only` row never reached local state; cache is intact.
      expect((await offlineRepo.watchTasks().first).map((t) => t.id), [
        'cached',
      ]);
    },
  );
}
