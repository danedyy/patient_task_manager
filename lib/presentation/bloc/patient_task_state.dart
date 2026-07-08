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

/// The loaded list. Holds the full folded list plus the active filter/query;
/// the widgets render [visibleTasks], so filtering stays a Bloc concern.
final class TaskLoaded extends PatientTaskState {
  final List<PatientTask> allTasks;
  final int pendingSyncCount;
  final TaskFilter filter;
  final String query;

  /// A one-shot rejection notice for the UI to surface once (snackbar). It is
  /// deliberately *not* carried by [copyWith]: the next list emission clears it.
  final SyncRejection? rejection;

  const TaskLoaded({
    required this.allTasks,
    required this.pendingSyncCount,
    this.filter = TaskFilter.all,
    this.query = '',
    this.rejection,
  });

  bool get isSyncing => pendingSyncCount > 0;

  /// The list to render: the folded tasks narrowed by [filter] and [query] and
  /// put in a stable, clinically-meaningful order (the DB stream has no inherent
  /// order, so without this the tiles would jump around as rows sync).
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
    }).toList()
      ..sort(_byUrgencyThenDueThenTitle);
  }

  TaskLoaded copyWith({
    List<PatientTask>? allTasks,
    int? pendingSyncCount,
    TaskFilter? filter,
    String? query,
  }) =>
      TaskLoaded(
        allTasks: allTasks ?? this.allTasks,
        pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
        filter: filter ?? this.filter,
        query: query ?? this.query,
        // rejection intentionally reset — it is a transient one-shot notice.
      );

  @override
  List<Object?> get props => [allTasks, pendingSyncCount, filter, query, rejection];
}

/// Most urgent first (stat > asap > urgent > routine), then soonest due (undated
/// last), then title as a stable tie-breaker.
int _byUrgencyThenDueThenTitle(PatientTask a, PatientTask b) {
  final byUrgency = b.priority.index.compareTo(a.priority.index);
  if (byUrgency != 0) return byUrgency;

  final ad = a.dueDate;
  final bd = b.dueDate;
  if (ad != null && bd != null && ad != bd) return ad.compareTo(bd);
  if (ad == null && bd != null) return 1; // undated after dated
  if (ad != null && bd == null) return -1;

  return a.title.compareTo(b.title);
}
