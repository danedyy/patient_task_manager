import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patient_task_manager/data/local/app_database.dart';
import 'package:patient_task_manager/data/models/patient_task_model.dart';
import 'package:patient_task_manager/data/remote/patient_task_api.dart';
import 'package:patient_task_manager/data/sync/sync_engine.dart';
import 'package:patient_task_manager/domain/entities/patient_task.dart';
import 'package:patient_task_manager/domain/entities/task_status.dart';

class _MockApi extends Mock implements PatientTaskApi {}

void main() {
  setUpAll(() => registerFallbackValue(TaskStatus.requested));

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

  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('ptm_persistence');
    file = File('${dir.path}/tasks.sqlite');
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('a queued op survives an app restart and drains on relaunch', () async {
    // First launch: enqueue an optimistic op, then close the app (DB).
    var db = AppDatabase(NativeDatabase(file));
    await db.taskDao.upsertFromServer(entity('t1', TaskStatus.requested, 1));
    await db.syncQueueDao.enqueue(
      taskId: 't1',
      from: TaskStatus.requested,
      to: TaskStatus.inProgress,
      baseVersion: 1,
      createdAt: t0,
    );
    await db.close();

    // Relaunch: reopen a brand-new database on the same on-disk file.
    db = AppDatabase(NativeDatabase(file));
    expect(await db.syncQueueDao.watchCount().first, 1, reason: 'op survived');

    // The engine on the fresh instance drains whatever it finds on startup.
    final api = _MockApi();
    when(() => api.patchStatus(
          taskId: any(named: 'taskId'),
          status: any(named: 'status'),
          expectedVersion: any(named: 'expectedVersion'),
        )).thenAnswer((_) async => model('t1', TaskStatus.inProgress, 2));
    final engine = SyncEngine(
      api: api,
      taskDao: db.taskDao,
      queueDao: db.syncQueueDao,
      delay: (_) async {},
    );

    await engine.drain();

    expect(await db.syncQueueDao.watchCount().first, 0, reason: 'drained');
    final task = (await db.taskDao.watchAll().first).single;
    expect(task.status, TaskStatus.inProgress);
    expect(task.version, 2);

    await engine.dispose();
    await db.close();
  });
}
