// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PatientTask _$PatientTaskFromJson(Map<String, dynamic> json) => _PatientTask(
  id: json['id'] as String,
  version: (json['version'] as num).toInt(),
  title: json['title'] as String,
  status: $enumDecode(_$TaskStatusEnumMap, json['status']),
  priority: $enumDecode(_$TaskPriorityEnumMap, json['priority']),
  patientReference: json['patientReference'] as String,
  lastModified: DateTime.parse(json['lastModified'] as String),
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  assignee: json['assignee'] as String?,
);

Map<String, dynamic> _$PatientTaskToJson(_PatientTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'version': instance.version,
      'title': instance.title,
      'status': _$TaskStatusEnumMap[instance.status]!,
      'priority': _$TaskPriorityEnumMap[instance.priority]!,
      'patientReference': instance.patientReference,
      'lastModified': instance.lastModified.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'assignee': instance.assignee,
    };

const _$TaskStatusEnumMap = {
  TaskStatus.requested: 'requested',
  TaskStatus.inProgress: 'in-progress',
  TaskStatus.onHold: 'on-hold',
  TaskStatus.completed: 'completed',
  TaskStatus.cancelled: 'cancelled',
};

const _$TaskPriorityEnumMap = {
  TaskPriority.routine: 'routine',
  TaskPriority.urgent: 'urgent',
  TaskPriority.asap: 'asap',
  TaskPriority.stat: 'stat',
};
