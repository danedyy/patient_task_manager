import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/patient_task.dart';
import '../../domain/entities/task_status.dart';

part 'patient_task_model.freezed.dart';
part 'patient_task_model.g.dart';

@freezed
abstract class PatientTaskModel with _$PatientTaskModel {
  const PatientTaskModel._();

  const factory PatientTaskModel({
    required String id,
    required int version,
    required String title,
    @JsonKey(fromJson: _statusFromWire, toJson: _statusToWire)
    required TaskStatus status,
    @JsonKey(fromJson: _priorityFromWire, toJson: _priorityToWire)
    required TaskPriority priority,
    required String patientReference,
    required DateTime lastModified,
    DateTime? dueDate,
    String? assignee,
  }) = _PatientTaskModel;

  factory PatientTaskModel.fromJson(Map<String, dynamic> json) =>
      _$PatientTaskModelFromJson(json);

  PatientTask toEntity() => PatientTask(
    id: id,
    version: version,
    title: title,
    status: status,
    priority: priority,
    patientReference: patientReference,
    lastModified: lastModified,
    dueDate: dueDate,
    assignee: assignee,
  );
}

// Wire-name mapping. Kept in the data layer (not on the domain enums) so the
// FHIR string format, and enum reordering never shifts it.
const _statusWire = {
  TaskStatus.requested: 'requested',
  TaskStatus.inProgress: 'in-progress',
  TaskStatus.onHold: 'on-hold',
  TaskStatus.completed: 'completed',
  TaskStatus.cancelled: 'cancelled',
};

const _priorityWire = {
  TaskPriority.routine: 'routine',
  TaskPriority.urgent: 'urgent',
  TaskPriority.asap: 'asap',
  TaskPriority.stat: 'stat',
};

String _statusToWire(TaskStatus s) => _statusWire[s]!;
TaskStatus _statusFromWire(String w) =>
    _statusWire.entries.firstWhere((e) => e.value == w).key;

String _priorityToWire(TaskPriority p) => _priorityWire[p]!;
TaskPriority _priorityFromWire(String w) =>
    _priorityWire.entries.firstWhere((e) => e.value == w).key;
