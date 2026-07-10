import 'package:flutter_test/flutter_test.dart';
import 'package:patient_task_manager/domain/entities/task_status.dart';
import 'package:patient_task_manager/domain/entities/task_transition.dart';

void main() {
  test('tryCreate returns a transition for a legal move, carrying from/to', () {
    final t = TaskTransition.tryCreate(
      TaskStatus.requested,
      TaskStatus.inProgress,
    );

    expect(t, isNotNull);
    expect(t!.from, TaskStatus.requested);
    expect(t.to, TaskStatus.inProgress);
  });

  test(
    'tryCreate returns null for an illegal move (impossible to construct)',
    () {
      // From a terminal status, and a machine-forbidden jump.
      expect(
        TaskTransition.tryCreate(TaskStatus.completed, TaskStatus.inProgress),
        isNull,
      );
      expect(
        TaskTransition.tryCreate(TaskStatus.requested, TaskStatus.completed),
        isNull,
      );
    },
  );
}
