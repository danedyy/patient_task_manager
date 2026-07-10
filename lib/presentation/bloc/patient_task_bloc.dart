import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../core/cancellation.dart';
import '../../core/connectivity/connectivity_monitor.dart';
import '../../core/failure/failure_exceptions.dart';
import '../../domain/entities/patient_task.dart';
import '../../domain/entities/sync_rejection.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repositories/patient_task_repository.dart';

part 'patient_task_event.dart';
part 'patient_task_state.dart';

/// Debounce a burst of events, then treat the handler as `restartable` so a new
/// event cancels the previous handler's in-flight work.
EventTransformer<T> _debounceRestartable<T>(Duration duration) {
  return (events, mapper) =>
      restartable<T>()(events.debounceTime(duration), mapper);
}

class PatientTaskBloc extends Bloc<PatientTaskEvent, PatientTaskState> {
  final PatientTaskRepository _repo;
  final ConnectivityMonitor _connectivity;

  StreamSubscription<PatientTaskEvent>? _listSub;
  StreamSubscription<SyncRejection>? _rejectionSub;
  StreamSubscription<bool>? _connectivitySub;

  /// Last known link state, to fire a reconcile only on the offline->online edge.
  bool? _wasOnline;

  /// The in-flight search's cancellation token, cancelled when a newer search
  /// supersedes it: real request cancellation, not just handler teardown.
  CancellationToken? _searchToken;

  /// The highest server page merged into the local cache for the current query.
  /// Reset to 0 on refresh / a new search; incremented by "load more".
  int _page = 0;

  /// TaskLoaded emission reads these.
  bool _hasMore = false;
  bool _loadingMore = false;

  PatientTaskBloc(this._repo, this._connectivity)
    : super(const TaskInitial()) {
    on<TaskListSubscribed>(_onSubscribed);
    on<_TasksUpdated>(_onTasksUpdated);
    on<_SyncRejected>(_onRejected);

    // droppable: while one page is loading, ignore further "load more" triggers
    // (scroll fires many); the in-flight fetch already covers the next page.
    on<LoadMoreRequested>(_onLoadMore, transformer: droppable());

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
    await _connectivitySub?.cancel();

    _rejectionSub = _repo.syncRejections.listen((r) => add(_SyncRejected(r)));
    
    _listSub = Rx.combineLatest2(
      _repo.watchTasks(),
      _repo.watchPendingSyncCount(),
      (List<PatientTask> tasks, int count) => _TasksUpdated(tasks, count),
    ).listen(add);

    // On the offline->online edge, re-run the normal refresh so authoritative
    // state is reconciled *and* the pagination cursor (`_page`/`_hasMore`) is
    // reset. Going through RefreshRequested (not a bare repo.refresh) is what
    // keeps "load more" working after a launch-offline -> online recovery.
    _connectivitySub = _connectivity.connectivity.listen((online) {
      if (_wasOnline == false && online) add(const RefreshRequested());
      _wasOnline = online;
    });
  }

  void _onTasksUpdated(_TasksUpdated event, Emitter<PatientTaskState> emit) {
    final s = state;
    emit(
      TaskLoaded(
        allTasks: event.tasks,
        pendingSyncCount: event.pendingSyncCount,
        filter: s is TaskLoaded ? s.filter : TaskFilter.all,
        query: s is TaskLoaded ? s.query : '',
        hasMore: _hasMore,
        isLoadingMore: _loadingMore,
      ),
    );
  }

  /// Push the current pagination fields into the Loaded state (for the cases a
  /// fetch finishes without a following list emission to carry them).
  void _syncPagination(Emitter<PatientTaskState> emit) {
    final s = state;
    if (s is TaskLoaded && !emit.isDone) {
      emit(s.copyWith(hasMore: _hasMore, isLoadingMore: _loadingMore));
    }
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
          hasMore: _hasMore,
          isLoadingMore: _loadingMore,
          rejection: event.rejection,
        ),
      );
    }
  }

  Future<void> _onStatusChange(
    TaskStatusChangeRequested event,
    Emitter<PatientTaskState> emit,
  ) async {
    
    try {
      await _repo.updateStatus(event.taskId, event.next);
    } on InvalidTransitionException {
      // TODO (InvalidTransitionException): not in scope
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
    _page = 0; // a new query restarts pagination

    final s = state;
    if (s is TaskLoaded) emit(s.copyWith(query: event.query));

    try {
      _hasMore = await _repo.fetchPage(event.query, 0, cancelToken: token);
      _syncPagination(emit);
    } on OperationCancelledException {
      // superseded by a newer search: expected
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
      final more = await _repo.refresh();
      _page = 0; 
      _hasMore = more;

      _syncPagination(emit); 

    } on Exception catch (e) {

      final s = state;
      if (!emit.isDone && (s is! TaskLoaded || s.allTasks.isEmpty)) {
        emit(TaskError(e.toString()));
      }
    }
  }

  Future<void> _onLoadMore(
    LoadMoreRequested event,
    Emitter<PatientTaskState> emit,
  ) async {
    final s = state;
    if (s is! TaskLoaded || !s.hasMore || s.isLoadingMore) return;
    _loadingMore = true;
    emit(s.copyWith(isLoadingMore: true)); // footer spinner while fetching

    // Reuse the current query's token so a query change mid-load cancels this
    // fetch too (the required "cancel in-flight requests when the query changes"
    // covers load-more, not just the search itself).
    final token = _searchToken;
    try {
      _hasMore = await _repo.fetchPage(s.query, _page + 1, cancelToken: token);
      _page += 1;
    } on OperationCancelledException {
      // The query changed under us; the new search now owns pagination.
    } on Exception {
      // Keep what is loaded; just clear the spinner below.
    } finally {
      _loadingMore = false;
      _syncPagination(emit);
    }
  }

  @override
  Future<void> close() async {
    await _listSub?.cancel();
    await _rejectionSub?.cancel();
    await _connectivitySub?.cancel();
    return super.close();
  }
}
