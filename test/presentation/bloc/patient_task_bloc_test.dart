import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patient_task_manager/core/cancellation.dart';
import 'package:patient_task_manager/core/failure/failure_exceptions.dart';
import 'package:patient_task_manager/domain/entities/patient_task.dart';
import 'package:patient_task_manager/domain/entities/sync_rejection.dart';
import 'package:patient_task_manager/domain/entities/task_status.dart';
import 'package:patient_task_manager/core/connectivity/connectivity_monitor.dart';
import 'package:patient_task_manager/domain/repositories/patient_task_repository.dart';
import 'package:patient_task_manager/presentation/bloc/patient_task_bloc.dart';

class _MockRepo extends Mock implements PatientTaskRepository {}

class _MockConnectivity extends Mock implements ConnectivityMonitor {}

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
  late _MockConnectivity connectivitySource;
  late StreamController<List<PatientTask>> tasks;
  late StreamController<int> counts;
  late StreamController<SyncRejection> rejections;
  late StreamController<bool> connectivity;
  late List<CancellationToken> capturedTokens;

  setUp(() {
    repo = _MockRepo();
    connectivitySource = _MockConnectivity();
    tasks = StreamController<List<PatientTask>>.broadcast();
    counts = StreamController<int>.broadcast();
    rejections = StreamController<SyncRejection>.broadcast();
    connectivity = StreamController<bool>.broadcast();
    capturedTokens = [];
    when(() => repo.watchTasks()).thenAnswer((_) => tasks.stream);
    when(() => repo.watchPendingSyncCount()).thenAnswer((_) => counts.stream);
    when(() => repo.syncRejections).thenAnswer((_) => rejections.stream);
    when(
      () => connectivitySource.connectivity,
    ).thenAnswer((_) => connectivity.stream);
  });

  tearDown(() {
    tasks.close();
    counts.close();
    rejections.close();
    connectivity.close();
  });

  PatientTaskBloc build() => PatientTaskBloc(repo, connectivitySource);

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
    act: (bloc) =>
        bloc.add(const TaskStatusChangeRequested('t1', TaskStatus.inProgress)),
    verify: (_) {
      verify(() => repo.updateStatus('t1', TaskStatus.inProgress)).called(1);
    },
  );

  // Item 14: toggle (conflict -> resolution). The toggle reaches the repo; the
  // engine's server-wins resolution then arrives as a rejection + a reverted row
  // (the engine's own re-validation logic is unit-tested in sync_engine_test).
  blocTest<PatientTaskBloc, PatientTaskState>(
    'a toggle the server rejects surfaces the rejection and rolls the row back',
    build: () {
      when(() => repo.updateStatus(any(), any())).thenAnswer((_) async {});
      return build();
    },
    act: (bloc) async {
      bloc.add(const TaskListSubscribed());
      await Future<void>.delayed(Duration.zero);
      emitList([task('t1', TaskStatus.inProgress)]);
      await Future<void>.delayed(Duration.zero);
      bloc.add(const TaskStatusChangeRequested('t1', TaskStatus.completed));
      await Future<void>.delayed(Duration.zero);
      // Server had cancelled it: the engine drops the op, emits a rejection, and
      // the reverted confirmed row flows back through the list stream.
      rejections.add(const SyncRejection('t1', 'Server cancelled the task'));
      await Future<void>.delayed(Duration.zero);
      emitList([task('t1', TaskStatus.cancelled)]);
    },
    skip: 1, // the initial TaskLoading
    expect: () => [
      isA<TaskLoaded>()
          .having(
            (s) => s.allTasks.single.status,
            'status',
            TaskStatus.inProgress,
          )
          .having((s) => s.rejection, 'no rejection yet', isNull),
      isA<TaskLoaded>().having(
        (s) => s.rejection?.reason,
        'rejection',
        'Server cancelled the task',
      ),
      isA<TaskLoaded>()
          .having(
            (s) => s.allTasks.single.status,
            'rolled back',
            TaskStatus.cancelled,
          )
          .having((s) => s.rejection, 'rejection cleared', isNull),
    ],
    verify: (_) =>
        verify(() => repo.updateStatus('t1', TaskStatus.completed)).called(1),
  );

  // Edge case (item 13): API failure on the initial load with nothing cached.
  blocTest<PatientTaskBloc, PatientTaskState>(
    'RefreshRequested surfaces TaskError when the load fails and nothing is cached',
    build: () {
      when(
        () => repo.refresh(),
      ).thenAnswer((_) async => throw const TransientException('network down'));
      return build();
    },
    act: (bloc) => bloc.add(const RefreshRequested()),
    expect: () => [isA<TaskError>()],
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
      expect(maxActive, 1); // serialized, never overlapped
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
    'SearchQueryChanged sets the query (debounced) and calls repo.fetchPage',
    build: () {
      when(
        () => repo.fetchPage(
          any(),
          any(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => false);
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
      () => repo.fetchPage('blood', 0, cancelToken: any(named: 'cancelToken')),
    ).called(1),
  );

  blocTest<PatientTaskBloc, PatientTaskState>(
    'a newer search cancels the previous search token',
    build: () {
      when(
        () => repo.fetchPage(
          any(),
          any(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((inv) async {
        capturedTokens.add(
          inv.namedArguments[#cancelToken] as CancellationToken,
        );
        return false;
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

  test(
    'visibleTasks orders by id (stable, matches server pagination order)',
    () {
      PatientTask p(String id) => PatientTask(
        id: id,
        version: 1,
        title: id,
        status: TaskStatus.requested,
        priority: TaskPriority.routine,
        patientReference: 'Patient/1',
        lastModified: t0,
      );

      final loaded = TaskLoaded(
        pendingSyncCount: 0,
        allTasks: [p('t3'), p('t1'), p('t2')],
      );

      // id order, so a later loaded page appends at the bottom (no reshuffle).
      expect(loaded.visibleTasks.map((t) => t.id), ['t1', 't2', 't3']);
    },
  );

  blocTest<PatientTaskBloc, PatientTaskState>(
    'RefreshRequested calls repo.refresh',
    build: () {
      when(() => repo.refresh()).thenAnswer((_) async => false);
      return build();
    },
    act: (bloc) => bloc.add(const RefreshRequested()),
    verify: (_) => verify(() => repo.refresh()).called(1),
  );

  // Offline -> online must re-run refresh through the normal path (resets the
  // pagination cursor), so "load more" works after a launch-offline recovery.
  blocTest<PatientTaskBloc, PatientTaskState>(
    'an offline -> online transition re-dispatches a refresh',
    build: () {
      when(() => repo.refresh()).thenAnswer((_) async => true);
      return build();
    },
    act: (bloc) async {
      bloc.add(const TaskListSubscribed());
      await Future<void>.delayed(Duration.zero);
      connectivity.add(false); // offline
      await Future<void>.delayed(Duration.zero);
      connectivity.add(true); // back online -> should trigger a refresh
      await Future<void>.delayed(Duration.zero);
    },
    verify: (_) => verify(() => repo.refresh()).called(1),
  );

  blocTest<PatientTaskBloc, PatientTaskState>(
    'a first "online" reading (no prior offline) does not trigger a refresh',
    build: build,
    act: (bloc) async {
      bloc.add(const TaskListSubscribed());
      await Future<void>.delayed(Duration.zero);
      connectivity.add(true); // initial state, not an edge
      await Future<void>.delayed(Duration.zero);
    },
    verify: (_) => verifyNever(() => repo.refresh()),
  );

  blocTest<PatientTaskBloc, PatientTaskState>(
    'LoadMoreRequested fetches the next page and toggles the loading flag',
    build: () {
      when(
        () => repo.fetchPage(
          any(),
          any(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => false);
      return build();
    },
    seed: () =>
        const TaskLoaded(allTasks: [], pendingSyncCount: 0, hasMore: true),
    act: (bloc) => bloc.add(const LoadMoreRequested()),
    expect: () => [
      isA<TaskLoaded>().having((s) => s.isLoadingMore, 'loading', true),
      isA<TaskLoaded>()
          .having((s) => s.isLoadingMore, 'loading', false)
          .having((s) => s.hasMore, 'hasMore', false),
    ],
    verify: (_) => verify(
      () => repo.fetchPage('', 1, cancelToken: any(named: 'cancelToken')),
    ).called(1),
  );

  blocTest<PatientTaskBloc, PatientTaskState>(
    'LoadMoreRequested is a no-op when there are no more pages',
    build: build,
    seed: () => const TaskLoaded(allTasks: [], pendingSyncCount: 0),
    act: (bloc) => bloc.add(const LoadMoreRequested()),
    expect: () => const <PatientTaskState>[],
    verify: (_) => verifyNever(
      () =>
          repo.fetchPage(any(), any(), cancelToken: any(named: 'cancelToken')),
    ),
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
