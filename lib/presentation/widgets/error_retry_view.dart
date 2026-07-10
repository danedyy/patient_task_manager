import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/patient_task_bloc.dart';

class ErrorRetryView extends StatelessWidget {
  final String message;
  const ErrorRetryView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () =>
                context.read<PatientTaskBloc>().add(const RefreshRequested()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
