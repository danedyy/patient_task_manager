import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patient_task_manager/core/cancellation.dart';
import 'package:patient_task_manager/domain/entities/patient_task.dart';
import 'package:patient_task_manager/domain/entities/sync_rejection.dart';
import 'package:patient_task_manager/domain/entities/task_status.dart';
import 'package:patient_task_manager/domain/repositories/patient_task_repository.dart';
import 'package:patient_task_manager/presentation/bloc/patient_task_bloc.dart';

class _MockRepo extends Mock implements PatientTaskRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(TaskStatus.requested);
    registerFallbackValue(CancellationToken());
  });

  final t0 = DateTime.utc(2026, 1, 1);

  PatientTask task(String id, TaskStatus status) => PatientTask(
        id: id,
        version: 1,
        title: 'task $id',
        status: status,
        priority: TaskPriority.routine,
        patientReference: 'Patient/1',
        lastModified: t0,
      );

  late _MockRepo repo;
  late StreamController<List<PatientTask>> tasks;
  late StreamController<int> counts;
  late StreamController<SyncRejection> rejections;
  late List<CancellationToken> capturedTokens;

  setUp(() {
    repo = _MockRepo();
    tasks = StreamController<List<PatientTask>>.broadcast();
    counts = StreamController<int>.broadcast();
    rejections = StreamController<SyncRejection>.broadcast();
    capturedTokens = [];
    when(() => repo.watchTasks()).thenAnswer((_) => tasks.stream);
    when(() => repo.watchPendingSyncCount()).thenAnswer((_) => counts.stream);
    when(() => repo.syncRejections).thenAnswer((_) => rejections.stream);
  });

  tearDown(() {
    tasks.close();
    counts.close();
    rejections.close();
  });

  PatientTaskBloc build() => PatientTaskBloc(repo);

  void emitList(List<PatientTask> t, [int count = 0]) {
    tasks.add(t);
    counts.add(count);
  }

  blocTest<PatientTaskBloc, PatientTaskState>(
    'subscribes and emits Loading then Loaded from the repository streams',
    build: build,
    act: (bloc) async {
      bloc.add(const TaskListSubscribed());
      await Future<void>.delayed(Duration.zero);
      emitList([task('t1', TaskStatus.requested)], 2);
    },
    expect: () => [
      const TaskLoading(),
      isA<TaskLoaded>()
          .having((s) => s.allTasks.length, 'tasks', 1)
          .having((s) => s.pendingSyncCount, 'pending', 2)
          .having((s) => s.isSyncing, 'isSyncing', true),
    ],
  );

  blocTest<PatientTaskBloc, PatientTaskState>(
    'forwards a status change to the repository',
    build: () {
      when(() => repo.updateStatus(any(), any())).thenAnswer((_) async {});
      return build();
    },
    act: (bloc) => bloc.add(
      const TaskStatusChangeRequested('t1', TaskStatus.inProgress),
    ),
    verify: (_) {
      verify(() => repo.updateStatus('t1', TaskStatus.inProgress)).called(1);
    },
  );

  // Proves the sequential() transformer: a slow updateStatus must never overlap
  // with the next one, and calls must reach the repo in dispatch order. Under a
  // concurrent transformer the two handlers would overlap (maxActive == 2).
  var active = 0;
  var maxActive = 0;
  final order = <TaskStatus>[];
  blocTest<PatientTaskBloc, PatientTaskState>(
    'sequential(): rapid status changes run one-at-a-time, in order',
    build: () {
      active = 0;
      maxActive = 0;
      order.clear();
      when(() => repo.updateStatus(any(), any())).thenAnswer((inv) async {
        active++;
        if (active > maxActive) maxActive = active;
        order.add(inv.positionalArguments[1] as TaskStatus);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        active--;
      });
      return build();
    },
    act: (bloc) {
      bloc.add(const TaskStatusChangeRequested('t1', TaskStatus.inProgress));
      bloc.add(const TaskStatusChangeRequested('t1', TaskStatus.onHold));
    },
    wait: const Duration(milliseconds: 100),
    verify: (_) {
      expect(maxActive, 1); // serialized — never overlapped
      expect(order, [TaskStatus.inProgress, TaskStatus.onHold]); // FIFO order
    },
  );

  blocTest<PatientTaskBloc, PatientTaskState>(
    'FilterChanged narrows visibleTasks without refetching',
    build: build,
    act: (bloc) async {
      bloc.add(const TaskListSubscribed());
      await Future<void>.delayed(Duration.zero);
      emitList([
        task('t1', TaskStatus.requested),
        task('t2', TaskStatus.completed),
      ]);
      await Future<void>.delayed(Duration.zero);
      bloc.add(const FilterChanged(TaskFilter.completed));
    },
    skip: 2, // Loading + first Loaded
    expect: () => [
      isA<TaskLoaded>()
          .having((s) => s.filter, 'filter', TaskFilter.completed)
          .having((s) => s.visibleTasks.single.id, 'visible', 't2'),
    ],
  );

  blocTest<PatientTaskBloc, PatientTaskState>(
    'SearchQueryChanged sets the query (debounced) and calls repo.search',
    build: () {
      when(() => repo.search(any(), cancelToken: any(named: 'cancelToken')))
          .thenAnswer((_) async {});
      return build();
    },
    act: (bloc) async {
      bloc.add(const TaskListSubscribed());
      await Future<void>.delayed(Duration.zero);
      emitList([
        task('blood-draw', TaskStatus.requested),
        task('vitals', TaskStatus.requested),
      ]);
      await Future<void>.delayed(Duration.zero);
      bloc.add(const SearchQueryChanged('blood'));
    },
    wait: const Duration(milliseconds: 350), // clear the 300ms debounce
    skip: 2,
    expect: () => [
      isA<TaskLoaded>()
          .having((s) => s.query, 'query', 'blood')
          .having((s) => s.visibleTasks.single.id, 'visible', 'blood-draw'),
    ],
    verify: (_) => verify(
      () => repo.search('blood', cancelToken: any(named: 'cancelToken')),
    ).called(1),
  );

  blocTest<PatientTaskBloc, PatientTaskState>(
    'a newer search cancels the previous search token',
    build: () {
      when(() => repo.search(any(), cancelToken: any(named: 'cancelToken')))
          .thenAnswer((inv) async {
        capturedTokens.add(
          inv.namedArguments[#cancelToken] as CancellationToken,
        );
      });
      return build();
    },
    act: (bloc) async {
      // Two searches spaced past the 300ms debounce so both handlers run.
      bloc.add(const SearchQueryChanged('a'));
      await Future<void>.delayed(const Duration(milliseconds: 350));
      bloc.add(const SearchQueryChanged('ab'));
      await Future<void>.delayed(const Duration(milliseconds: 350));
    },
    verify: (_) {
      expect(capturedTokens, hasLength(2));
      expect(capturedTokens[0].isCancelled, isTrue); // superseded
      expect(capturedTokens[1].isCancelled, isFalse); // current
    },
  );

  test('visibleTasks orders by urgency, then due date, then title', () {
    PatientTask p(String id, TaskPriority priority, {DateTime? due}) =>
        PatientTask(
          id: id,
          version: 1,
          title: id,
          status: TaskStatus.requested,
          priority: priority,
          patientReference: 'Patient/1',
          lastModified: t0,
          dueDate: due,
        );

    final loaded = TaskLoaded(
      pendingSyncCount: 0,
      allTasks: [
        p('c', TaskPriority.routine),
        p('a', TaskPriority.stat, due: DateTime.utc(2026, 2)),
        p('b', TaskPriority.stat, due: DateTime.utc(2026, 1)),
        p('d', TaskPriority.urgent),
      ],
    );

    // stat (soonest due first) -> urgent -> routine
    expect(loaded.visibleTasks.map((t) => t.id), ['b', 'a', 'd', 'c']);
  });

  blocTest<PatientTaskBloc, PatientTaskState>(
    'RefreshRequested calls repo.refresh',
    build: () {
      when(() => repo.refresh()).thenAnswer((_) async {});
      return build();
    },
    act: (bloc) => bloc.add(const RefreshRequested()),
    verify: (_) => verify(() => repo.refresh()).called(1),
  );

  blocTest<PatientTaskBloc, PatientTaskState>(
    'a sync rejection surfaces on the Loaded state',
    build: build,
    act: (bloc) async {
      bloc.add(const TaskListSubscribed());
      await Future<void>.delayed(Duration.zero);
      emitList([task('t1', TaskStatus.requested)]);
      await Future<void>.delayed(Duration.zero);
      rejections.add(const SyncRejection('t1', 'server moved it'));
    },
    skip: 2,
    expect: () => [
      isA<TaskLoaded>().having(
        (s) => s.rejection?.reason,
        'rejection',
        'server moved it',
      ),
    ],
  );
}
