import 'package:flutter_test/flutter_test.dart';
import 'package:patient_task_manager/data/models/patient_task_model.dart';
import 'package:patient_task_manager/domain/entities/patient_task.dart';
import 'package:patient_task_manager/domain/entities/task_status.dart';

void main() {
  const wireJson = {
    'id': 't1',
    'version': 3,
    'title': 'Draw blood',
    'status': 'in-progress',
    'priority': 'stat',
    'patientReference': 'Patient/1',
    'lastModified': '2026-01-01T00:00:00.000Z',
    'dueDate': null,
    'assignee': null,
  };

  test('fromJson maps FHIR wire names onto domain enums', () {
    final model = PatientTaskModel.fromJson(wireJson);
    expect(model.status, TaskStatus.inProgress);
    expect(model.priority, TaskPriority.stat);
  });

  test('toJson emits the wire names, not the enum identifiers', () {
    final json = PatientTaskModel.fromJson(wireJson).toJson();
    expect(json['status'], 'in-progress');
    expect(json['priority'], 'stat');
  });

  test('entity round-trips through the model', () {
    final entity = PatientTask(
      id: 't1',
      version: 3,
      title: 'Draw blood',
      status: TaskStatus.onHold,
      priority: TaskPriority.urgent,
      patientReference: 'Patient/1',
      lastModified: DateTime.utc(2026, 1, 1),
    );
    expect(PatientTaskModel.fromEntity(entity).toEntity(), entity);
  });
}
