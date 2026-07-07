// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_dao.dart';

// ignore_for_file: type=lint
mixin _$TaskDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConfirmedTasksTable get confirmedTasks => attachedDatabase.confirmedTasks;
  TaskDaoManager get managers => TaskDaoManager(this);
}

class TaskDaoManager {
  final _$TaskDaoMixin _db;
  TaskDaoManager(this._db);
  $$ConfirmedTasksTableTableManager get confirmedTasks =>
      $$ConfirmedTasksTableTableManager(
        _db.attachedDatabase,
        _db.confirmedTasks,
      );
}
