import 'task_status.dart';
/// It is load-bearing, not ceremony: callers pass the validated [from]/[to] on
/// to persistence, so a transition cannot be *recorded* without first being
/// proven legal.
class TaskTransition {
  final TaskStatus from;
  final TaskStatus to;

  const TaskTransition._(this.from, this.to);

  /// A transition object if [from] -> [to] is legal, otherwise null.
  static TaskTransition? tryCreate(TaskStatus from, TaskStatus to) =>
      from.canTransitionTo(to) ? TaskTransition._(from, to) : null;
}
