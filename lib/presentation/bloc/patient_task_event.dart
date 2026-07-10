part of 'patient_task_bloc.dart';

sealed class PatientTaskEvent extends Equatable {
  const PatientTaskEvent();

  @override
  List<Object?> get props => [];
}

/// Subscribe to the reactive local list + pending-count + rejection streams.
final class TaskListSubscribed extends PatientTaskEvent {
  const TaskListSubscribed();
}

/// User asked to move a task to [next].
final class TaskStatusChangeRequested extends PatientTaskEvent {
  final String taskId;
  final TaskStatus next;
  const TaskStatusChangeRequested(this.taskId, this.next);

  @override
  List<Object?> get props => [taskId, next];
}

/// The search box changed.
final class SearchQueryChanged extends PatientTaskEvent {
  final String query;
  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// The status filter changed.
final class FilterChanged extends PatientTaskEvent {
  final TaskFilter filter;
  const FilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Pull-to-refresh from the server.
final class RefreshRequested extends PatientTaskEvent {
  const RefreshRequested();
}

/// Reached the end of the list; pull the next server page into the cache.
final class LoadMoreRequested extends PatientTaskEvent {
  const LoadMoreRequested();
}


final class _TasksUpdated extends PatientTaskEvent {
  final List<PatientTask> tasks;
  final int pendingSyncCount;
  const _TasksUpdated(this.tasks, this.pendingSyncCount);

  @override
  List<Object?> get props => [tasks, pendingSyncCount];
}

final class _SyncRejected extends PatientTaskEvent {
  final SyncRejection rejection;
  const _SyncRejected(this.rejection);

  @override
  List<Object?> get props => [rejection];
}
