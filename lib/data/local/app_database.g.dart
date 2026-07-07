// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ConfirmedTasksTable extends ConfirmedTasks
    with TableInfo<$ConfirmedTasksTable, ConfirmedTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfirmedTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TaskStatus>($ConfirmedTasksTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<TaskPriority, String> priority =
      GeneratedColumn<String>(
        'priority',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TaskPriority>($ConfirmedTasksTable.$converterpriority);
  static const VerificationMeta _patientReferenceMeta = const VerificationMeta(
    'patientReference',
  );
  @override
  late final GeneratedColumn<String> patientReference = GeneratedColumn<String>(
    'patient_reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assigneeMeta = const VerificationMeta(
    'assignee',
  );
  @override
  late final GeneratedColumn<String> assignee = GeneratedColumn<String>(
    'assignee',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    version,
    title,
    status,
    priority,
    patientReference,
    lastModified,
    dueDate,
    assignee,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'confirmed_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConfirmedTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('patient_reference')) {
      context.handle(
        _patientReferenceMeta,
        patientReference.isAcceptableOrUnknown(
          data['patient_reference']!,
          _patientReferenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patientReferenceMeta);
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastModifiedMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('assignee')) {
      context.handle(
        _assigneeMeta,
        assignee.isAcceptableOrUnknown(data['assignee']!, _assigneeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConfirmedTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfirmedTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      status: $ConfirmedTasksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      priority: $ConfirmedTasksTable.$converterpriority.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}priority'],
        )!,
      ),
      patientReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_reference'],
      )!,
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      assignee: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignee'],
      ),
    );
  }

  @override
  $ConfirmedTasksTable createAlias(String alias) {
    return $ConfirmedTasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskStatus, String, String> $converterstatus =
      const EnumNameConverter<TaskStatus>(TaskStatus.values);
  static JsonTypeConverter2<TaskPriority, String, String> $converterpriority =
      const EnumNameConverter<TaskPriority>(TaskPriority.values);
}

class ConfirmedTask extends DataClass implements Insertable<ConfirmedTask> {
  final String id;
  final int version;
  final String title;
  final TaskStatus status;
  final TaskPriority priority;
  final String patientReference;
  final DateTime lastModified;
  final DateTime? dueDate;
  final String? assignee;
  const ConfirmedTask({
    required this.id,
    required this.version,
    required this.title,
    required this.status,
    required this.priority,
    required this.patientReference,
    required this.lastModified,
    this.dueDate,
    this.assignee,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['title'] = Variable<String>(title);
    {
      map['status'] = Variable<String>(
        $ConfirmedTasksTable.$converterstatus.toSql(status),
      );
    }
    {
      map['priority'] = Variable<String>(
        $ConfirmedTasksTable.$converterpriority.toSql(priority),
      );
    }
    map['patient_reference'] = Variable<String>(patientReference);
    map['last_modified'] = Variable<DateTime>(lastModified);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || assignee != null) {
      map['assignee'] = Variable<String>(assignee);
    }
    return map;
  }

  ConfirmedTasksCompanion toCompanion(bool nullToAbsent) {
    return ConfirmedTasksCompanion(
      id: Value(id),
      version: Value(version),
      title: Value(title),
      status: Value(status),
      priority: Value(priority),
      patientReference: Value(patientReference),
      lastModified: Value(lastModified),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      assignee: assignee == null && nullToAbsent
          ? const Value.absent()
          : Value(assignee),
    );
  }

  factory ConfirmedTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfirmedTask(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      title: serializer.fromJson<String>(json['title']),
      status: $ConfirmedTasksTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      priority: $ConfirmedTasksTable.$converterpriority.fromJson(
        serializer.fromJson<String>(json['priority']),
      ),
      patientReference: serializer.fromJson<String>(json['patientReference']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      assignee: serializer.fromJson<String?>(json['assignee']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<String>(
        $ConfirmedTasksTable.$converterstatus.toJson(status),
      ),
      'priority': serializer.toJson<String>(
        $ConfirmedTasksTable.$converterpriority.toJson(priority),
      ),
      'patientReference': serializer.toJson<String>(patientReference),
      'lastModified': serializer.toJson<DateTime>(lastModified),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'assignee': serializer.toJson<String?>(assignee),
    };
  }

  ConfirmedTask copyWith({
    String? id,
    int? version,
    String? title,
    TaskStatus? status,
    TaskPriority? priority,
    String? patientReference,
    DateTime? lastModified,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<String?> assignee = const Value.absent(),
  }) => ConfirmedTask(
    id: id ?? this.id,
    version: version ?? this.version,
    title: title ?? this.title,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    patientReference: patientReference ?? this.patientReference,
    lastModified: lastModified ?? this.lastModified,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    assignee: assignee.present ? assignee.value : this.assignee,
  );
  ConfirmedTask copyWithCompanion(ConfirmedTasksCompanion data) {
    return ConfirmedTask(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      patientReference: data.patientReference.present
          ? data.patientReference.value
          : this.patientReference,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      assignee: data.assignee.present ? data.assignee.value : this.assignee,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfirmedTask(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('patientReference: $patientReference, ')
          ..write('lastModified: $lastModified, ')
          ..write('dueDate: $dueDate, ')
          ..write('assignee: $assignee')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    version,
    title,
    status,
    priority,
    patientReference,
    lastModified,
    dueDate,
    assignee,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfirmedTask &&
          other.id == this.id &&
          other.version == this.version &&
          other.title == this.title &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.patientReference == this.patientReference &&
          other.lastModified == this.lastModified &&
          other.dueDate == this.dueDate &&
          other.assignee == this.assignee);
}

class ConfirmedTasksCompanion extends UpdateCompanion<ConfirmedTask> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> title;
  final Value<TaskStatus> status;
  final Value<TaskPriority> priority;
  final Value<String> patientReference;
  final Value<DateTime> lastModified;
  final Value<DateTime?> dueDate;
  final Value<String?> assignee;
  final Value<int> rowid;
  const ConfirmedTasksCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.patientReference = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.assignee = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfirmedTasksCompanion.insert({
    required String id,
    required int version,
    required String title,
    required TaskStatus status,
    required TaskPriority priority,
    required String patientReference,
    required DateTime lastModified,
    this.dueDate = const Value.absent(),
    this.assignee = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       version = Value(version),
       title = Value(title),
       status = Value(status),
       priority = Value(priority),
       patientReference = Value(patientReference),
       lastModified = Value(lastModified);
  static Insertable<ConfirmedTask> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? title,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<String>? patientReference,
    Expression<DateTime>? lastModified,
    Expression<DateTime>? dueDate,
    Expression<String>? assignee,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (patientReference != null) 'patient_reference': patientReference,
      if (lastModified != null) 'last_modified': lastModified,
      if (dueDate != null) 'due_date': dueDate,
      if (assignee != null) 'assignee': assignee,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfirmedTasksCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? title,
    Value<TaskStatus>? status,
    Value<TaskPriority>? priority,
    Value<String>? patientReference,
    Value<DateTime>? lastModified,
    Value<DateTime?>? dueDate,
    Value<String?>? assignee,
    Value<int>? rowid,
  }) {
    return ConfirmedTasksCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      title: title ?? this.title,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      patientReference: patientReference ?? this.patientReference,
      lastModified: lastModified ?? this.lastModified,
      dueDate: dueDate ?? this.dueDate,
      assignee: assignee ?? this.assignee,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ConfirmedTasksTable.$converterstatus.toSql(status.value),
      );
    }
    if (priority.present) {
      map['priority'] = Variable<String>(
        $ConfirmedTasksTable.$converterpriority.toSql(priority.value),
      );
    }
    if (patientReference.present) {
      map['patient_reference'] = Variable<String>(patientReference.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (assignee.present) {
      map['assignee'] = Variable<String>(assignee.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfirmedTasksCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('patientReference: $patientReference, ')
          ..write('lastModified: $lastModified, ')
          ..write('dueDate: $dueDate, ')
          ..write('assignee: $assignee, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingOperationsTable extends PendingOperations
    with TableInfo<$PendingOperationsTable, PendingOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskStatus, String> fromStatus =
      GeneratedColumn<String>(
        'from_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TaskStatus>($PendingOperationsTable.$converterfromStatus);
  @override
  late final GeneratedColumnWithTypeConverter<TaskStatus, String> toStatus =
      GeneratedColumn<String>(
        'to_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TaskStatus>($PendingOperationsTable.$convertertoStatus);
  static const VerificationMeta _baseVersionMeta = const VerificationMeta(
    'baseVersion',
  );
  @override
  late final GeneratedColumn<int> baseVersion = GeneratedColumn<int>(
    'base_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptMeta = const VerificationMeta(
    'attempt',
  );
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
    'attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    taskId,
    fromStatus,
    toStatus,
    baseVersion,
    attempt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('base_version')) {
      context.handle(
        _baseVersionMeta,
        baseVersion.isAcceptableOrUnknown(
          data['base_version']!,
          _baseVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseVersionMeta);
    }
    if (data.containsKey('attempt')) {
      context.handle(
        _attemptMeta,
        attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  PendingOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingOperation(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      fromStatus: $PendingOperationsTable.$converterfromStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}from_status'],
        )!,
      ),
      toStatus: $PendingOperationsTable.$convertertoStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}to_status'],
        )!,
      ),
      baseVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_version'],
      )!,
      attempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingOperationsTable createAlias(String alias) {
    return $PendingOperationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskStatus, String, String> $converterfromStatus =
      const EnumNameConverter<TaskStatus>(TaskStatus.values);
  static JsonTypeConverter2<TaskStatus, String, String> $convertertoStatus =
      const EnumNameConverter<TaskStatus>(TaskStatus.values);
}

class PendingOperation extends DataClass
    implements Insertable<PendingOperation> {
  /// Autoincrement rowid: doubles as the op's identity and the global FIFO
  /// order. Draining oldest-[seq]-first preserves per-task order automatically.
  final int seq;
  final String taskId;
  final TaskStatus fromStatus;
  final TaskStatus toStatus;

  /// Server version this op was created against — the 409 re-validation baseline.
  final int baseVersion;
  final int attempt;
  final DateTime createdAt;
  const PendingOperation({
    required this.seq,
    required this.taskId,
    required this.fromStatus,
    required this.toStatus,
    required this.baseVersion,
    required this.attempt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['task_id'] = Variable<String>(taskId);
    {
      map['from_status'] = Variable<String>(
        $PendingOperationsTable.$converterfromStatus.toSql(fromStatus),
      );
    }
    {
      map['to_status'] = Variable<String>(
        $PendingOperationsTable.$convertertoStatus.toSql(toStatus),
      );
    }
    map['base_version'] = Variable<int>(baseVersion);
    map['attempt'] = Variable<int>(attempt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingOperationsCompanion toCompanion(bool nullToAbsent) {
    return PendingOperationsCompanion(
      seq: Value(seq),
      taskId: Value(taskId),
      fromStatus: Value(fromStatus),
      toStatus: Value(toStatus),
      baseVersion: Value(baseVersion),
      attempt: Value(attempt),
      createdAt: Value(createdAt),
    );
  }

  factory PendingOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingOperation(
      seq: serializer.fromJson<int>(json['seq']),
      taskId: serializer.fromJson<String>(json['taskId']),
      fromStatus: $PendingOperationsTable.$converterfromStatus.fromJson(
        serializer.fromJson<String>(json['fromStatus']),
      ),
      toStatus: $PendingOperationsTable.$convertertoStatus.fromJson(
        serializer.fromJson<String>(json['toStatus']),
      ),
      baseVersion: serializer.fromJson<int>(json['baseVersion']),
      attempt: serializer.fromJson<int>(json['attempt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'taskId': serializer.toJson<String>(taskId),
      'fromStatus': serializer.toJson<String>(
        $PendingOperationsTable.$converterfromStatus.toJson(fromStatus),
      ),
      'toStatus': serializer.toJson<String>(
        $PendingOperationsTable.$convertertoStatus.toJson(toStatus),
      ),
      'baseVersion': serializer.toJson<int>(baseVersion),
      'attempt': serializer.toJson<int>(attempt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingOperation copyWith({
    int? seq,
    String? taskId,
    TaskStatus? fromStatus,
    TaskStatus? toStatus,
    int? baseVersion,
    int? attempt,
    DateTime? createdAt,
  }) => PendingOperation(
    seq: seq ?? this.seq,
    taskId: taskId ?? this.taskId,
    fromStatus: fromStatus ?? this.fromStatus,
    toStatus: toStatus ?? this.toStatus,
    baseVersion: baseVersion ?? this.baseVersion,
    attempt: attempt ?? this.attempt,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingOperation copyWithCompanion(PendingOperationsCompanion data) {
    return PendingOperation(
      seq: data.seq.present ? data.seq.value : this.seq,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      fromStatus: data.fromStatus.present
          ? data.fromStatus.value
          : this.fromStatus,
      toStatus: data.toStatus.present ? data.toStatus.value : this.toStatus,
      baseVersion: data.baseVersion.present
          ? data.baseVersion.value
          : this.baseVersion,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperation(')
          ..write('seq: $seq, ')
          ..write('taskId: $taskId, ')
          ..write('fromStatus: $fromStatus, ')
          ..write('toStatus: $toStatus, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('attempt: $attempt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seq,
    taskId,
    fromStatus,
    toStatus,
    baseVersion,
    attempt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingOperation &&
          other.seq == this.seq &&
          other.taskId == this.taskId &&
          other.fromStatus == this.fromStatus &&
          other.toStatus == this.toStatus &&
          other.baseVersion == this.baseVersion &&
          other.attempt == this.attempt &&
          other.createdAt == this.createdAt);
}

class PendingOperationsCompanion extends UpdateCompanion<PendingOperation> {
  final Value<int> seq;
  final Value<String> taskId;
  final Value<TaskStatus> fromStatus;
  final Value<TaskStatus> toStatus;
  final Value<int> baseVersion;
  final Value<int> attempt;
  final Value<DateTime> createdAt;
  const PendingOperationsCompanion({
    this.seq = const Value.absent(),
    this.taskId = const Value.absent(),
    this.fromStatus = const Value.absent(),
    this.toStatus = const Value.absent(),
    this.baseVersion = const Value.absent(),
    this.attempt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PendingOperationsCompanion.insert({
    this.seq = const Value.absent(),
    required String taskId,
    required TaskStatus fromStatus,
    required TaskStatus toStatus,
    required int baseVersion,
    this.attempt = const Value.absent(),
    required DateTime createdAt,
  }) : taskId = Value(taskId),
       fromStatus = Value(fromStatus),
       toStatus = Value(toStatus),
       baseVersion = Value(baseVersion),
       createdAt = Value(createdAt);
  static Insertable<PendingOperation> custom({
    Expression<int>? seq,
    Expression<String>? taskId,
    Expression<String>? fromStatus,
    Expression<String>? toStatus,
    Expression<int>? baseVersion,
    Expression<int>? attempt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (taskId != null) 'task_id': taskId,
      if (fromStatus != null) 'from_status': fromStatus,
      if (toStatus != null) 'to_status': toStatus,
      if (baseVersion != null) 'base_version': baseVersion,
      if (attempt != null) 'attempt': attempt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PendingOperationsCompanion copyWith({
    Value<int>? seq,
    Value<String>? taskId,
    Value<TaskStatus>? fromStatus,
    Value<TaskStatus>? toStatus,
    Value<int>? baseVersion,
    Value<int>? attempt,
    Value<DateTime>? createdAt,
  }) {
    return PendingOperationsCompanion(
      seq: seq ?? this.seq,
      taskId: taskId ?? this.taskId,
      fromStatus: fromStatus ?? this.fromStatus,
      toStatus: toStatus ?? this.toStatus,
      baseVersion: baseVersion ?? this.baseVersion,
      attempt: attempt ?? this.attempt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (fromStatus.present) {
      map['from_status'] = Variable<String>(
        $PendingOperationsTable.$converterfromStatus.toSql(fromStatus.value),
      );
    }
    if (toStatus.present) {
      map['to_status'] = Variable<String>(
        $PendingOperationsTable.$convertertoStatus.toSql(toStatus.value),
      );
    }
    if (baseVersion.present) {
      map['base_version'] = Variable<int>(baseVersion.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperationsCompanion(')
          ..write('seq: $seq, ')
          ..write('taskId: $taskId, ')
          ..write('fromStatus: $fromStatus, ')
          ..write('toStatus: $toStatus, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('attempt: $attempt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ConfirmedTasksTable confirmedTasks = $ConfirmedTasksTable(this);
  late final $PendingOperationsTable pendingOperations =
      $PendingOperationsTable(this);
  late final TaskDao taskDao = TaskDao(this as AppDatabase);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    confirmedTasks,
    pendingOperations,
  ];
}

typedef $$ConfirmedTasksTableCreateCompanionBuilder =
    ConfirmedTasksCompanion Function({
      required String id,
      required int version,
      required String title,
      required TaskStatus status,
      required TaskPriority priority,
      required String patientReference,
      required DateTime lastModified,
      Value<DateTime?> dueDate,
      Value<String?> assignee,
      Value<int> rowid,
    });
typedef $$ConfirmedTasksTableUpdateCompanionBuilder =
    ConfirmedTasksCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> title,
      Value<TaskStatus> status,
      Value<TaskPriority> priority,
      Value<String> patientReference,
      Value<DateTime> lastModified,
      Value<DateTime?> dueDate,
      Value<String?> assignee,
      Value<int> rowid,
    });

class $$ConfirmedTasksTableFilterComposer
    extends Composer<_$AppDatabase, $ConfirmedTasksTable> {
  $$ConfirmedTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TaskStatus, TaskStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<TaskPriority, TaskPriority, String>
  get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get patientReference => $composableBuilder(
    column: $table.patientReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignee => $composableBuilder(
    column: $table.assignee,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConfirmedTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfirmedTasksTable> {
  $$ConfirmedTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientReference => $composableBuilder(
    column: $table.patientReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignee => $composableBuilder(
    column: $table.assignee,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConfirmedTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfirmedTasksTable> {
  $$ConfirmedTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskPriority, String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get patientReference => $composableBuilder(
    column: $table.patientReference,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get assignee =>
      $composableBuilder(column: $table.assignee, builder: (column) => column);
}

class $$ConfirmedTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfirmedTasksTable,
          ConfirmedTask,
          $$ConfirmedTasksTableFilterComposer,
          $$ConfirmedTasksTableOrderingComposer,
          $$ConfirmedTasksTableAnnotationComposer,
          $$ConfirmedTasksTableCreateCompanionBuilder,
          $$ConfirmedTasksTableUpdateCompanionBuilder,
          (
            ConfirmedTask,
            BaseReferences<_$AppDatabase, $ConfirmedTasksTable, ConfirmedTask>,
          ),
          ConfirmedTask,
          PrefetchHooks Function()
        > {
  $$ConfirmedTasksTableTableManager(
    _$AppDatabase db,
    $ConfirmedTasksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfirmedTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfirmedTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfirmedTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<TaskStatus> status = const Value.absent(),
                Value<TaskPriority> priority = const Value.absent(),
                Value<String> patientReference = const Value.absent(),
                Value<DateTime> lastModified = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String?> assignee = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfirmedTasksCompanion(
                id: id,
                version: version,
                title: title,
                status: status,
                priority: priority,
                patientReference: patientReference,
                lastModified: lastModified,
                dueDate: dueDate,
                assignee: assignee,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int version,
                required String title,
                required TaskStatus status,
                required TaskPriority priority,
                required String patientReference,
                required DateTime lastModified,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String?> assignee = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfirmedTasksCompanion.insert(
                id: id,
                version: version,
                title: title,
                status: status,
                priority: priority,
                patientReference: patientReference,
                lastModified: lastModified,
                dueDate: dueDate,
                assignee: assignee,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConfirmedTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfirmedTasksTable,
      ConfirmedTask,
      $$ConfirmedTasksTableFilterComposer,
      $$ConfirmedTasksTableOrderingComposer,
      $$ConfirmedTasksTableAnnotationComposer,
      $$ConfirmedTasksTableCreateCompanionBuilder,
      $$ConfirmedTasksTableUpdateCompanionBuilder,
      (
        ConfirmedTask,
        BaseReferences<_$AppDatabase, $ConfirmedTasksTable, ConfirmedTask>,
      ),
      ConfirmedTask,
      PrefetchHooks Function()
    >;
typedef $$PendingOperationsTableCreateCompanionBuilder =
    PendingOperationsCompanion Function({
      Value<int> seq,
      required String taskId,
      required TaskStatus fromStatus,
      required TaskStatus toStatus,
      required int baseVersion,
      Value<int> attempt,
      required DateTime createdAt,
    });
typedef $$PendingOperationsTableUpdateCompanionBuilder =
    PendingOperationsCompanion Function({
      Value<int> seq,
      Value<String> taskId,
      Value<TaskStatus> fromStatus,
      Value<TaskStatus> toStatus,
      Value<int> baseVersion,
      Value<int> attempt,
      Value<DateTime> createdAt,
    });

class $$PendingOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TaskStatus, TaskStatus, String>
  get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<TaskStatus, TaskStatus, String> get toStatus =>
      $composableBuilder(
        column: $table.toStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromStatus => $composableBuilder(
    column: $table.fromStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toStatus => $composableBuilder(
    column: $table.toStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskStatus, String> get fromStatus =>
      $composableBuilder(
        column: $table.fromStatus,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<TaskStatus, String> get toStatus =>
      $composableBuilder(column: $table.toStatus, builder: (column) => column);

  GeneratedColumn<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingOperationsTable,
          PendingOperation,
          $$PendingOperationsTableFilterComposer,
          $$PendingOperationsTableOrderingComposer,
          $$PendingOperationsTableAnnotationComposer,
          $$PendingOperationsTableCreateCompanionBuilder,
          $$PendingOperationsTableUpdateCompanionBuilder,
          (
            PendingOperation,
            BaseReferences<
              _$AppDatabase,
              $PendingOperationsTable,
              PendingOperation
            >,
          ),
          PendingOperation,
          PrefetchHooks Function()
        > {
  $$PendingOperationsTableTableManager(
    _$AppDatabase db,
    $PendingOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<TaskStatus> fromStatus = const Value.absent(),
                Value<TaskStatus> toStatus = const Value.absent(),
                Value<int> baseVersion = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PendingOperationsCompanion(
                seq: seq,
                taskId: taskId,
                fromStatus: fromStatus,
                toStatus: toStatus,
                baseVersion: baseVersion,
                attempt: attempt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String taskId,
                required TaskStatus fromStatus,
                required TaskStatus toStatus,
                required int baseVersion,
                Value<int> attempt = const Value.absent(),
                required DateTime createdAt,
              }) => PendingOperationsCompanion.insert(
                seq: seq,
                taskId: taskId,
                fromStatus: fromStatus,
                toStatus: toStatus,
                baseVersion: baseVersion,
                attempt: attempt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingOperationsTable,
      PendingOperation,
      $$PendingOperationsTableFilterComposer,
      $$PendingOperationsTableOrderingComposer,
      $$PendingOperationsTableAnnotationComposer,
      $$PendingOperationsTableCreateCompanionBuilder,
      $$PendingOperationsTableUpdateCompanionBuilder,
      (
        PendingOperation,
        BaseReferences<
          _$AppDatabase,
          $PendingOperationsTable,
          PendingOperation
        >,
      ),
      PendingOperation,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ConfirmedTasksTableTableManager get confirmedTasks =>
      $$ConfirmedTasksTableTableManager(_db, _db.confirmedTasks);
  $$PendingOperationsTableTableManager get pendingOperations =>
      $$PendingOperationsTableTableManager(_db, _db.pendingOperations);
}
