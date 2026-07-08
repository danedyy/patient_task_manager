import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_task_manager/data/local/app_database.dart';
import 'package:patient_task_manager/data/remote/mock_patient_task_api.dart';
import 'package:patient_task_manager/data/repositories/drift_patient_task_repository.dart';
import 'package:patient_task_manager/data/sync/sync_engine.dart';
import 'package:patient_task_manager/domain/entities/patient_task.dart';
import 'package:patient_task_manager/domain/entities/task_status.dart';
import 'package:patient_task_manager/presentation/bloc/patient_task_bloc.dart';

/// End-to-end (bloc -> real repository -> in-memory DB): a status change shows up
/// optimistically in the Loaded state before any sync runs. The engine is left
/// unstarted on purpose, so the op stays pending and the visible status can only
/// come from the fold — proving the optimism, not a server round-trip.
void main() {
  final t0 = DateTime.utc(2026, 1, 1);

  test('a status change is reflected optimistically before any sync', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final api = MockPatientTaskApi(seed: const [], failureRate: 0);
    final engine = SyncEngine(
      api: api,
      taskDao: db.taskDao,
      queueDao: db.syncQueueDao,
      delay: (_) async {},
    );
    final repo = DriftPatientTaskRepository(
      api: api,
      taskDao: db.taskDao,
      queueDao: db.syncQueueDao,
      engine: engine,
      clock: () => t0,
    );

    await db.taskDao.upsertFromServer(
      PatientTask(
        id: 't1',
        version: 1,
        title: 'Draw blood',
        status: TaskStatus.requested,
        priority: TaskPriority.routine,
        patientReference: 'Patient/1',
        lastModified: t0,
      ),
    );

    final bloc = PatientTaskBloc(repo);
    bloc.add(const TaskListSubscribed());

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<TaskLoaded>().having(
          (s) => s.visibleTasks.single.status,
          'initial status',
          TaskStatus.requested,
        ),
      ),
    );

    bloc.add(const TaskStatusChangeRequested('t1', TaskStatus.inProgress));

    await expectLater(
      bloc.stream,
      emitsThrough(
        isA<TaskLoaded>()
            .having(
              (s) => s.visibleTasks.single.status,
              'optimistic status',
              TaskStatus.inProgress,
            )
            .having((s) => s.pendingSyncCount, 'pending', 1),
      ),
    );

    await bloc.close();
    await repo.dispose();
    await db.close();
  });
}
