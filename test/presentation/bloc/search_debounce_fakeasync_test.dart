import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patient_task_manager/core/cancellation.dart';
import 'package:patient_task_manager/core/connectivity/connectivity_monitor.dart';
import 'package:patient_task_manager/domain/repositories/patient_task_repository.dart';
import 'package:patient_task_manager/presentation/bloc/patient_task_bloc.dart';

class _MockRepo extends Mock implements PatientTaskRepository {}

class _MockConnectivity extends Mock implements ConnectivityMonitor {}

void main() {
  setUpAll(() => registerFallbackValue(CancellationToken()));

  // fakeAsync drives the 300ms debounce timer without spending real time: the
  // spec's "≥1 fakeAsync test for debounce/backoff" requirement.
  test('debounce collapses a burst of keystrokes into one server search', () {
    fakeAsync((async) {
      final repo = _MockRepo();
      final searched = <String>[];
      when(
        () => repo.fetchPage(
          any(),
          any(),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((inv) async {
        searched.add(inv.positionalArguments[0] as String);
        return false;
      });

      final connectivity = _MockConnectivity();
      when(
        () => connectivity.connectivity,
      ).thenAnswer((_) => const Stream.empty());
      final bloc = PatientTaskBloc(repo, connectivity);

      // Type "a" -> "ab" -> "abc", each within the 300ms window.
      bloc.add(const SearchQueryChanged('a'));
      async.elapse(const Duration(milliseconds: 100));
      bloc.add(const SearchQueryChanged('ab'));
      async.elapse(const Duration(milliseconds: 100));
      bloc.add(const SearchQueryChanged('abc'));

      // Not yet past the debounce, nothing fetched.
      async.elapse(const Duration(milliseconds: 100));
      expect(searched, isEmpty);

      // Cross the debounce boundary: exactly one fetch, for the final query.
      async.elapse(const Duration(milliseconds: 300));
      expect(searched, ['abc']);

      // A later, separate query debounces into its own single fetch.
      bloc.add(const SearchQueryChanged('vitals'));
      async.elapse(const Duration(milliseconds: 300));
      expect(searched, ['abc', 'vitals']);

      bloc.close();
    });
  });
}
