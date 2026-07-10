import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patient_task_manager/core/connectivity/connectivity_monitor.dart';
import 'package:patient_task_manager/presentation/bloc/connectivity_cubit.dart';

class _MockConnectivity extends Mock implements ConnectivityMonitor {}

void main() {
  late _MockConnectivity source;
  late StreamController<bool> connectivity;

  setUp(() {
    source = _MockConnectivity();
    connectivity = StreamController<bool>.broadcast();
    when(() => source.connectivity).thenAnswer((_) => connectivity.stream);
  });

  tearDown(() => connectivity.close());

  test('starts optimistically online before any reading', () {
    expect(ConnectivityCubit(source).state, isTrue);
  });

  blocTest<ConnectivityCubit, bool>(
    'emits each connectivity reading from the source',
    build: () => ConnectivityCubit(source),
    act: (_) {
      connectivity
        ..add(false)
        ..add(true);
    },
    // Starts at true, so a leading `false` is a real change; distinct dedupe
    // lives in the repository stream, not here.
    expect: () => const [false, true],
  );
}
