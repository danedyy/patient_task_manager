import 'package:freezed_annotation/freezed_annotation.dart';

import 'task_status.dart';

part 'patient_task.freezed.dart';

/// Clinical urgency of a task. Pure entity; wire names live in the model.
enum TaskPriority { routine, urgent, asap, stat }

/// A patient-related task, loosely shaped after a FHIR Task resource.
@freezed
abstract class PatientTask with _$PatientTask {
  const factory PatientTask({
    required String id,

    /// Server-assigned, monotonically increasing.
    required int version,
    required String title,
    required TaskStatus status,
    required TaskPriority priority,

    /// e.g. "Patient/123"
    required String patientReference,

    /// Server time of the last accepted write.
    required DateTime lastModified,
    DateTime? dueDate,

    /// e.g. "Practitioner/45"
    String? assignee,
  }) = _PatientTask;
}
