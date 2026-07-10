import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_task_manager/domain/entities/patient_task.dart';
import 'package:patient_task_manager/domain/entities/sync_rejection.dart';
import 'package:patient_task_manager/domain/entities/task_status.dart';
import 'package:patient_task_manager/presentation/bloc/connectivity_cubit.dart';
import 'package:patient_task_manager/presentation/bloc/patient_task_bloc.dart';
import 'package:patient_task_manager/presentation/pages/task_list_page.dart';

class _MockBloc extends MockBloc<PatientTaskEvent, PatientTaskState>
    implements PatientTaskBloc {}

class _MockConnectivityCubit extends MockCubit<bool>
    implements ConnectivityCubit {}

void main() {
  final t0 = DateTime.utc(2026, 1, 1);

  PatientTask task(String id, TaskStatus status) => PatientTask(
    id: id,
    version: 1,
    title: 'Task $id',
    status: status,
    priority: TaskPriority.routine,
    patientReference: 'Patient/1',
    lastModified: t0,
  );

  late _MockBloc bloc;
  late _MockConnectivityCubit connectivity;

  setUp(() {
    bloc = _MockBloc();
    connectivity = _MockConnectivityCubit();
    whenListen(connectivity, const Stream<bool>.empty(), initialState: true);
  });

  Widget host() => MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<PatientTaskBloc>.value(value: bloc),
        BlocProvider<ConnectivityCubit>.value(value: connectivity),
      ],
      child: const TaskListPage(),
    ),
  );

  testWidgets('offers only the state-machine-legal actions', (tester) async {
    whenListen(
      bloc,
      const Stream<PatientTaskState>.empty(),
      initialState: TaskLoaded(
        allTasks: [
          task('1', TaskStatus.requested),
          task('2', TaskStatus.completed), // terminal -> no actions
        ],
        pendingSyncCount: 0,
      ),
    );
    await tester.pumpWidget(host());

    // requested -> {inProgress ("Start"), cancelled ("Cancel")}
    expect(find.widgetWithText(OutlinedButton, 'Start'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);
    // completed is terminal -> no action buttons anywhere
    expect(find.widgetWithText(OutlinedButton, 'Complete'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Hold'), findsNothing);
  });

  testWidgets('a sync rejection surfaces as a snackbar', (tester) async {
    whenListen(
      bloc,
      Stream<PatientTaskState>.fromIterable(const [
        TaskLoaded(
          allTasks: [],
          pendingSyncCount: 0,
          rejection: SyncRejection('1', 'Server moved the task to completed'),
        ),
      ]),
      initialState: const TaskLoaded(allTasks: [], pendingSyncCount: 0),
    );
    await tester.pumpWidget(host());
    await tester.pump(); // deliver the emitted state + run the listener

    expect(find.text('Server moved the task to completed'), findsOneWidget);
  });
}
