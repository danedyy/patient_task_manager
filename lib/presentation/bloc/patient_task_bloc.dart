import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../core/cancellation.dart';
import '../../core/failure/failure_exceptions.dart';
import '../../domain/entities/patient_task.dart';
import '../../domain/entities/sync_rejection.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repositories/patient_task_repository.dart';

part 'patient_task_event.dart';
part 'patient_task_state.dart';

/// Debounce a burst of events, then treat the handler as `restartable` so a new
/// event cancels the previous handler's in-flight work (switchMap semantics).
EventTransformer<T> _debounceRestartable<T>(Duration duration) {
  return (events, mapper) =>
      restartable<T>()(events.debounceTime(duration), mapper);
}

class PatientTaskBloc extends Bloc<PatientTaskEvent, PatientTaskState> {
  final PatientTaskRepository _repo;

  StreamSubscription<PatientTaskEvent>? _listSub;
  StreamSubscription<SyncRejection>? _rejectionSub;

  /// The in-flight search's cancellation token, cancelled when a newer search
  /// supersedes it — real request cancellation, not just handler teardown.
  CancellationToken? _searchToken;

  PatientTaskBloc(this._repo) : super(const TaskInitial()) {
    on<TaskListSubscribed>(_onSubscribed);
    on<_TasksUpdated>(_onTasksUpdated);
    on<_SyncRejected>(_onRejected);

    // sequential: rapid status changes must reach the repository in order, so
    // each one validates against the previous intent (droppable would lose
    // intents, restartable would cancel a half-recorded one).
    on<TaskStatusChangeRequested>(_onStatusChange, transformer: sequential());

    // debounce collapses keystrokes; restartable cancels the in-flight search
    // fetch when the query changes again before it returns.
    on<SearchQueryChanged>(
      _onSearch,
      transformer: _debounceRestartable(const Duration(milliseconds: 300)),
    );

    on<FilterChanged>(_onFilterChanged);

    // droppable: a refresh while one is already running is a no-op, not a queue.
    on<RefreshRequested>(_onRefresh, transformer: droppable());
  }

  Future<void> _onSubscribed(
    TaskListSubscribed event,
    Emitter<PatientTaskState> emit,
  ) async {
    if (state is TaskInitial) emit(const TaskLoading());

    // Re-subscribe cleanly (no leaked subscriptions) if called again.
    await _listSub?.cancel();
    await _rejectionSub?.cancel();

    _rejectionSub = _repo.syncRejections.listen((r) => add(_SyncRejected(r)));
    _listSub = Rx.combineLatest2(
      _repo.watchTasks(),
      _repo.watchPendingSyncCount(),
      (List<PatientTask> tasks, int count) => _TasksUpdated(tasks, count),
    ).listen(add);
  }

  void _onTasksUpdated(_TasksUpdated event, Emitter<PatientTaskState> emit) {
    final s = state;
    emit(
      TaskLoaded(
        allTasks: event.tasks,
        pendingSyncCount: event.pendingSyncCount,
        filter: s is TaskLoaded ? s.filter : TaskFilter.all,
        query: s is TaskLoaded ? s.query : '',
      ),
    );
  }

  void _onRejected(_SyncRejected event, Emitter<PatientTaskState> emit) {
    final s = state;
    if (s is TaskLoaded) {
      emit(
        TaskLoaded(
          allTasks: s.allTasks,
          pendingSyncCount: s.pendingSyncCount,
          filter: s.filter,
          query: s.query,
          rejection: event.rejection,
        ),
      );
    }
  }

  Future<void> _onStatusChange(
    TaskStatusChangeRequested event,
    Emitter<PatientTaskState> emit,
  ) async {
    // The optimistic update flows back through watchTasks -> _TasksUpdated, so
    // there is nothing to emit here. Illegal moves are already filtered out by
    // the UI (buttons come from allowedNext); guard anyway.
    try {
      await _repo.updateStatus(event.taskId, event.next);
    } on InvalidTransitionException {
      // ignore — not offered by the UI
    }
  }

  Future<void> _onSearch(
    SearchQueryChanged event,
    Emitter<PatientTaskState> emit,
  ) async {
    // Cancel any still-in-flight search: a newer query supersedes it, so its
    // (stale) result must not land. Then arm a fresh token for this one.
    _searchToken?.cancel();
    final token = _searchToken = CancellationToken();

    final s = state;
    if (s is TaskLoaded) emit(s.copyWith(query: event.query));

    // Best-effort server refresh; the local filter is the source of truth for
    // what is shown, so a failed or cancelled search never breaks the list.
    try {
      await _repo.search(event.query, cancelToken: token);
    } on OperationCancelledException {
      // superseded by a newer search — expected, nothing to do
    } on Exception {
      // ignore — cached results remain visible
    }
  }

  void _onFilterChanged(FilterChanged event, Emitter<PatientTaskState> emit) {
    final s = state;
    if (s is TaskLoaded) emit(s.copyWith(filter: event.filter));
  }

  Future<void> _onRefresh(
    RefreshRequested event,
    Emitter<PatientTaskState> emit,
  ) async {
    try {
      await _repo.refresh();
    } on Exception catch (e) {
      // Offline-first: keep cached data; only error when there is nothing shown.
      final s = state;
      if (s is! TaskLoaded || s.allTasks.isEmpty) emit(TaskError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _listSub?.cancel();
    await _rejectionSub?.cancel();
    return super.close();
  }
}
