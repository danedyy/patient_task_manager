import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/patient_task_bloc.dart';

class SyncBadge extends StatelessWidget {
  const SyncBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientTaskBloc, PatientTaskState>(
      buildWhen: (a, b) => _syncing(a) != _syncing(b) || _count(a) != _count(b),
      builder: (context, state) {
        if (state is! TaskLoaded || !state.isSyncing) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text('Syncing ${state.pendingSyncCount}…'),
            ],
          ),
        );
      },
    );
  }

  bool _syncing(PatientTaskState s) => s is TaskLoaded && s.isSyncing;
  int _count(PatientTaskState s) => s is TaskLoaded ? s.pendingSyncCount : 0;
}
