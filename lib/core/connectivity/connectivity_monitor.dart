import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';

/// The device's network link, in one place. [connectivity] is the app-facing
/// signal (badge, refresh-on-reconnect); [onStatusChange]/[isOnline] are the
/// raw pieces the sync engine gates on. Everyone consumes this; nothing
/// re-implements the seed/merge.
class ConnectivityMonitor {
  ConnectivityMonitor([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// onStatusChange doesn't replay the current value, so a one-shot isOnline()
  /// read seeds the first emission; distinct drops no-op repeats.
  Stream<bool> get connectivity =>
      Rx.merge([isOnline().asStream(), onStatusChange]).distinct();

  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map(_isOnline);

  Future<bool> isOnline() async =>
      _isOnline(await _connectivity.checkConnectivity());

  static bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
