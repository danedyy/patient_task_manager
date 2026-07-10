import '../core/connectivity/connectivity_monitor.dart';
import '../data/local/app_database.dart';
import '../data/remote/mock_patient_task_api.dart';
import '../data/repositories/drift_patient_task_repository.dart';
import '../data/sync/sync_engine.dart';


/// Owns the lifecycle: [start] begins sync, [dispose] tears the graph
/// down (engine subscriptions + database).
class AppDependencies {
  final AppDatabase _db;
  final DriftPatientTaskRepository repository;
  final ConnectivityMonitor connectivity;

  AppDependencies._(this._db, this.repository, this.connectivity);

  factory AppDependencies.create() {
    final db = AppDatabase.open();
    final api = MockPatientTaskApi();

    final connectivity = ConnectivityMonitor();
    
    final engine = SyncEngine(
      api: api,
      taskDao: db.taskDao,
      queueDao: db.syncQueueDao,
      connectivity: connectivity,
    );

    final repository = DriftPatientTaskRepository(
      api: api,
      taskDao: db.taskDao,
      queueDao: db.syncQueueDao,
      engine: engine,
      connectivity: connectivity,
    );
    return AppDependencies._(db, repository, connectivity);
  }

  /// Begin background draining + server-push merge (the engine's single wake point).
  void start() => repository.start();

  Future<void> dispose() async {
    await repository.dispose();
    await _db.close();
  }
}
