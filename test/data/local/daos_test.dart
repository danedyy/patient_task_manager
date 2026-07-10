import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_task_manager/data/local/app_database.dart';
import 'package:patient_task_manager/domain/entities/patient_task.dart';
import 'package:patient_task_manager/domain/entities/task_status.dart';

PatientTask _task({
  String id = 't1',
  int version = 1,
  TaskStatus status = TaskStatus.requested,
}) => PatientTask(
  id: id,
  version: version,
  title: 'Draw blood',
  status: status,
  priority: TaskPriority.routine,
  patientReference: 'Patient/1',
  lastModified: DateTime.utc(2026, 1, 1),
);

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('TaskDao', () {
    test('watchAll emits upserted tasks', () async {
      await db.taskDao.upsertFromServer(_task());
      expect(await db.taskDao.watchAll().first, [
        isA<PatientTask>().having((t) => t.id, 'id', 't1'),
      ]);
    });

    test('upsertFromServer only overwrites with a newer version', () async {
      await db.taskDao.upsertFromServer(_task(version: 5));
      // Stale push (lower version) is ignored.
      await db.taskDao.upsertFromServer(
        _task(version: 3, status: TaskStatus.completed),
      );
      var stored = (await db.taskDao.watchAll().first).single;
      expect(stored.version, 5);
      expect(stored.status, TaskStatus.requested);

      // Newer push wins.
      await db.taskDao.upsertFromServer(
        _task(version: 6, status: TaskStatus.inProgress),
      );
      stored = (await db.taskDao.watchAll().first).single;
      expect(stored.version, 6);
      expect(stored.status, TaskStatus.inProgress);
    });

    test('replaceAll swaps the whole table', () async {
      await db.taskDao.upsertFromServer(_task(id: 'old'));
      await db.taskDao.replaceAll([_task(id: 'new')]);
      final ids = (await db.taskDao.watchAll().first).map((t) => t.id);
      expect(ids, ['new']);
    });

    test(
      'upsertAllFromServer merges a page in one emission, not one per row',
      () async {
        final emissions = <int>[];
        final sub = db.taskDao.watchAll().listen(
          (rows) => emissions.add(rows.length),
        );
        await pumpEventQueue();
        emissions.clear(); // drop the initial (empty) emission

        await db.taskDao.upsertAllFromServer([
          _task(id: 't1'),
          _task(id: 't2'),
          _task(id: 't3'),
        ]);
        await pumpEventQueue();
        await sub.cancel();

        // One emission carrying all three, not [1, 2, 3] as a per-row loop gives:
        // that trickle is what made paginated tiles appear one at a time.
        expect(emissions, [3]);
      },
    );
  });

  group('SyncQueueDao', () {
    Future<void> enqueue(String taskId) => db.syncQueueDao.enqueue(
      taskId: taskId,
      from: TaskStatus.requested,
      to: TaskStatus.inProgress,
      baseVersion: 1,
      createdAt: DateTime.utc(2026, 1, 1),
    );

    test('watchCount reflects enqueued ops', () async {
      expect(await db.syncQueueDao.watchCount().first, 0);
      await enqueue('t1');
      await enqueue('t2');
      expect(await db.syncQueueDao.watchCount().first, 2);
    });

    test('next returns the oldest op (FIFO by seq)', () async {
      await enqueue('first');
      await enqueue('second');
      final op = await db.syncQueueDao.next();
      expect(op!.taskId, 'first');

      await db.syncQueueDao.deleteOp(op.seq);
      expect((await db.syncQueueDao.next())!.taskId, 'second');
    });

    test('bumpAttempt increments in place', () async {
      await enqueue('t1');
      final op = (await db.syncQueueDao.next())!;
      expect(op.attempt, 0);
      await db.syncQueueDao.bumpAttempt(op.seq);
      expect((await db.syncQueueDao.next())!.attempt, 1);
    });
  });
}
