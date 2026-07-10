import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/connectivity/connectivity_monitor.dart';

/// Starts optimistically online, matching the sync engine's default, until
/// the [ConnectivityMonitor] stream delivers the first reading.
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(ConnectivityMonitor source) : super(true) {
    _sub = source.connectivity.listen(emit);
  }

  late final StreamSubscription<bool> _sub;

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
