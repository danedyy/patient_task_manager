import 'package:flutter/material.dart';

import '../../domain/entities/patient_task.dart';
import '../../domain/entities/task_status.dart';

class TaskTile extends StatelessWidget {
  final PatientTask task;
  final ValueChanged<TaskStatus> onAction;

  const TaskTile({super.key, required this.task, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final actions = TaskStatus.values
        .where(task.status.allowedNext.contains)
        .toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(task.title, style: text.titleMedium)),
                _PriorityChip(task.priority),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              [
                task.patientReference,
                _statusLabel(task.status),
                if (task.dueDate != null) 'due ${_fmtDate(task.dueDate!)}',
              ].join('  ·  '),
              style: text.bodySmall,
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final next in actions)
                    OutlinedButton(
                      onPressed: () => onAction(next),
                      child: Text(_actionLabel(task.status, next)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _actionLabel(TaskStatus from, TaskStatus to) => switch (to) {
  TaskStatus.inProgress => from == TaskStatus.onHold ? 'Resume' : 'Start',
  TaskStatus.onHold => 'Hold',
  TaskStatus.completed => 'Complete',
  TaskStatus.cancelled => 'Cancel',
  TaskStatus.requested => 'Reopen',
};

String _statusLabel(TaskStatus s) => switch (s) {
  TaskStatus.requested => 'Requested',
  TaskStatus.inProgress => 'In progress',
  TaskStatus.onHold => 'On hold',
  TaskStatus.completed => 'Completed',
  TaskStatus.cancelled => 'Cancelled',
};

String _fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class _PriorityChip extends StatelessWidget {
  final TaskPriority priority;
  const _PriorityChip(this.priority);

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      TaskPriority.stat => Colors.red,
      TaskPriority.asap => Colors.deepOrange,
      TaskPriority.urgent => Colors.orange,
      TaskPriority.routine => Colors.blueGrey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
