import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/patient_task_bloc.dart';
import 'task_tile.dart';

class TaskListView extends StatelessWidget {
  final TaskLoaded state;
  const TaskListView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final tasks = state.visibleTasks;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<TaskFilter>(
            segments: const [
              ButtonSegment(value: TaskFilter.all, label: Text('All')),
              ButtonSegment(value: TaskFilter.pending, label: Text('Pending')),
              ButtonSegment(
                value: TaskFilter.completed,
                label: Text('Completed'),
              ),
              ButtonSegment(
                value: TaskFilter.cancelled,
                label: Text('Cancelled'),
              ),
            ],
            selected: {state.filter},
            onSelectionChanged: (s) =>
                context.read<PatientTaskBloc>().add(FilterChanged(s.first)),
          ),
        ),
        Expanded(
          child: tasks.isEmpty
              ? const Center(child: Text('No tasks'))
              : NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (state.hasMore &&
                        !state.isLoadingMore &&
                        n.metrics.pixels >= n.metrics.maxScrollExtent - 240) {
                      context.read<PatientTaskBloc>().add(
                        const LoadMoreRequested(),
                      );
                    }
                    return false;
                  },
                  child: ListView.builder(
                    // One extra row for the footer spinner while loading a page.
                    itemCount: tasks.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= tasks.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return TaskTile(
                        task: tasks[i],
                        onAction: (next) => context.read<PatientTaskBloc>().add(
                          TaskStatusChangeRequested(tasks[i].id, next),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
