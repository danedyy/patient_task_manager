import 'package:flutter_test/flutter_test.dart';
import 'package:patient_task_manager/domain/entities/task_status.dart';

void main() {
  const allowed = <TaskStatus, Set<TaskStatus>>{
    TaskStatus.requested: {TaskStatus.inProgress, TaskStatus.cancelled},
    TaskStatus.inProgress: {
      TaskStatus.onHold,
      TaskStatus.completed,
      TaskStatus.cancelled,
    },
    TaskStatus.onHold: {TaskStatus.inProgress, TaskStatus.cancelled},
    TaskStatus.completed: {},
    TaskStatus.cancelled: {},
  };

  group('canTransitionTo (exhaustive 5x5 matrix)', () {
    for (final from in TaskStatus.values) {
      for (final to in TaskStatus.values) {
        final legal = allowed[from]!.contains(to);
        test('$from -> $to is ${legal ? 'allowed' : 'rejected'}', () {
          expect(from.canTransitionTo(to), legal);
        });
      }
    }
  });

  test('allowedNext matches the spec table for every status', () {
    for (final status in TaskStatus.values) {
      expect(status.allowedNext, allowed[status]);
    }
  });

  test('only completed and cancelled are terminal', () {
    final terminal = TaskStatus.values.where((s) => s.isTerminal).toSet();
    expect(terminal, {TaskStatus.completed, TaskStatus.cancelled});
  });
}
