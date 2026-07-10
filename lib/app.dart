import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'di/app_dependencies.dart';
import 'domain/repositories/patient_task_repository.dart';
import 'presentation/bloc/connectivity_cubit.dart';
import 'presentation/bloc/patient_task_bloc.dart';
import 'presentation/pages/task_list_page.dart';
import 'presentation/theme/app_theme.dart';

class PatientTaskManagerApp extends StatefulWidget {
  const PatientTaskManagerApp({super.key});

  @override
  State<PatientTaskManagerApp> createState() => _PatientTaskManagerAppState();
}

class _PatientTaskManagerAppState extends State<PatientTaskManagerApp> {
  late final AppDependencies _deps;

  @override
  void initState() {
    super.initState();
    _deps = AppDependencies.create()..start();
  }

  @override
  void dispose() {
    _deps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<PatientTaskRepository>.value(
      value: _deps.repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => PatientTaskBloc(
              context.read<PatientTaskRepository>(),
              _deps.connectivity,
            ),
          ),
          BlocProvider(
            create: (context) => ConnectivityCubit(_deps.connectivity),
          ),
        ],
        child: MaterialApp(
          title: 'Patient Task Manager',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const TaskListPage(),
        ),
      ),
    );
  }
}
