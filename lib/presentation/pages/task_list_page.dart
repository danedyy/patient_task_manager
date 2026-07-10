import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/patient_task_bloc.dart';
import '../widgets/error_retry_view.dart';
import '../widgets/online_indicator.dart';
import '../widgets/sync_badge.dart';
import '../widgets/task_list_view.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  @override
  void initState() {
    super.initState();
    // Subscribe to the reactive local list, then pull a fresh server snapshot.
    context.read<PatientTaskBloc>()
      ..add(const TaskListSubscribed())
      ..add(const RefreshRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Tasks'),
        actions: const [SyncBadge(), OnlineIndicator()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              // Debouncing lives in the Bloc, not here.
              onChanged: (q) =>
                  context.read<PatientTaskBloc>().add(SearchQueryChanged(q)),
              decoration: const InputDecoration(
                isDense: true,
                prefixIcon: Icon(Icons.search),
                hintText: 'Search tasks',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ),
      body: BlocConsumer<PatientTaskBloc, PatientTaskState>(
        // Synchronous listener: no BuildContext across an await.
        listenWhen: (_, s) => s is TaskLoaded && s.rejection != null,
        listener: (context, state) {
          final rejection = (state as TaskLoaded).rejection!;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(rejection.reason)));
        },
        builder: (context, state) => switch (state) {
          TaskInitial() ||
          TaskLoading() => const Center(child: CircularProgressIndicator()),
          TaskError(:final message) => ErrorRetryView(message: message),
          TaskLoaded() => TaskListView(state: state),
        },
      ),
    );
  }
}
