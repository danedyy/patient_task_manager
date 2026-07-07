import 'task_status.dart';

/// A proven-legal status transition.
///
/// The constructor is private: the only way to obtain an instance is
/// [tryCreate], which returns null for transitions the state machine forbids.
/// Layers below the domain (repository, sync) accept only a [TaskTransition],
/// so an invalid transition is unrepresentable there.
class TaskTransition {
  final TaskStatus from;
  final TaskStatus to;

  const TaskTransition._(this.from, this.to);

  static TaskTransition? tryCreate(TaskStatus from, TaskStatus to) =>
      from.allowedNext.contains(to) ? TaskTransition._(from, to) : null;

  @override
  String toString() => 'TaskTransition($from -> $to)';
}
