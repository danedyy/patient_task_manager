// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PatientTaskModel _$PatientTaskModelFromJson(Map<String, dynamic> json) =>
    _PatientTaskModel(
      id: json['id'] as String,
      version: (json['version'] as num).toInt(),
      title: json['title'] as String,
      status: _statusFromWire(json['status'] as String),
      priority: _priorityFromWire(json['priority'] as String),
      patientReference: json['patientReference'] as String,
      lastModified: DateTime.parse(json['lastModified'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      assignee: json['assignee'] as String?,
    );

Map<String, dynamic> _$PatientTaskModelToJson(_PatientTaskModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'version': instance.version,
      'title': instance.title,
      'status': _statusToWire(instance.status),
      'priority': _priorityToWire(instance.priority),
      'patientReference': instance.patientReference,
      'lastModified': instance.lastModified.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'assignee': instance.assignee,
    };
