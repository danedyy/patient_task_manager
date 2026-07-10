part of 'patient_task_bloc.dart';

/// The view filter the user picks. `pending` = anything not yet terminal.
enum TaskFilter { all, pending, completed, cancelled }

sealed class PatientTaskState extends Equatable {
  const PatientTaskState();

  @override
  List<Object?> get props => [];
}

final class TaskInitial extends PatientTaskState {
  const TaskInitial();
}

final class TaskLoading extends PatientTaskState {
  const TaskLoading();
}

final class TaskError extends PatientTaskState {
  final String message;
  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}


final class TaskLoaded extends PatientTaskState {
  final List<PatientTask> allTasks;
  final int pendingSyncCount;
  final TaskFilter filter;
  final String query;

  /// Server-side pagination: whether more pages exist beyond what's been loaded,
  /// and whether a "load more" fetch is in flight (drives the footer spinner).
  final bool hasMore;
  final bool isLoadingMore;

  /// A one-shot rejection notice for the UI to surface once (snackbar). It is
  /// deliberately *not* carried by [copyWith]: the next list emission clears it.
  final SyncRejection? rejection;

  const TaskLoaded({
    required this.allTasks,
    required this.pendingSyncCount,
    this.filter = TaskFilter.all,
    this.query = '',
    this.hasMore = false,
    this.isLoadingMore = false,
    this.rejection,
  });

  bool get isSyncing => pendingSyncCount > 0;

  /// The list to render: the folded tasks narrowed by [filter] and [query],
  /// ordered by `id`. The DB stream has no inherent order, so an explicit sort
  /// keeps tiles from jumping as rows sync; `id` (matching the server's own
  /// pagination order) means each loaded page appends at the bottom rather than
  /// reshuffling the list. (No clinical/urgency sort: not in the spec, and it
  /// fought pagination by re-ordering the whole list on every "load more".)
  List<PatientTask> get visibleTasks {
    final q = query.trim().toLowerCase();
    return allTasks.where((t) {
      final matchesQuery = q.isEmpty || t.title.toLowerCase().contains(q);
      final matchesFilter = switch (filter) {
        TaskFilter.all => true,
        TaskFilter.pending => !t.status.isTerminal,
        TaskFilter.completed => t.status == TaskStatus.completed,
        TaskFilter.cancelled => t.status == TaskStatus.cancelled,
      };
      return matchesQuery && matchesFilter;
    }).toList()..sort((a, b) => a.id.compareTo(b.id));
  }

  TaskLoaded copyWith({
    List<PatientTask>? allTasks,
    int? pendingSyncCount,
    TaskFilter? filter,
    String? query,
    bool? hasMore,
    bool? isLoadingMore,
  }) => TaskLoaded(
    allTasks: allTasks ?? this.allTasks,
    pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
    filter: filter ?? this.filter,
    query: query ?? this.query,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    // rejection intentionally reset: it is a transient one-shot notice.
  );

  @override
  List<Object?> get props => [
    allTasks,
    pendingSyncCount,
    filter,
    query,
    hasMore,
    isLoadingMore,
    rejection,
  ];
}
