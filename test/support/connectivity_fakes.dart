import 'dart:async';

import 'package:patient_task_manager/core/connectivity/connectivity_monitor.dart';

/// Always-online [ConnectivityMonitor] for tests whose subject is not
/// connectivity. Connectivity gating itself is covered in
/// test/data/sync/connectivity_gating_test.dart.
class AlwaysOnline implements ConnectivityMonitor {
  const AlwaysOnline();

  @override
  Stream<bool> get connectivity => Stream.value(true);

  @override
  Stream<bool> get onStatusChange => const Stream.empty();

  @override
  Future<bool> isOnline() async => true;
}

/// Connectivity a test drives by hand: [isOnline] seeds the initial state,
/// [emit] pushes later transitions. Broadcast so several consumers (engine,
/// repository) can subscribe at once.
class EmittableConnectivity implements ConnectivityMonitor {
  EmittableConnectivity([this._initial = true]);

  final bool _initial;
  final _controller = StreamController<bool>.broadcast();

  @override
  Stream<bool> get connectivity => onStatusChange;

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  @override
  Future<bool> isOnline() async => _initial;

  void emit(bool online) => _controller.add(online);
  Future<void> dispose() => _controller.close();
}
