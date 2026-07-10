import '../../domain/entities/patient_task.dart';
import '../../domain/entities/task_status.dart';
import '../models/patient_task_model.dart';

/// A fixed spread of 50 tasks across patients, priorities, and statuses: the
/// default in-memory "server" contents for [MockPatientTaskApi]. Kept separate
/// from the API logic: it's fixture data, not behaviour. 50 rows (> one 20-row
/// page) is what makes server-side pagination and "load more" actually exercise.
List<PatientTaskModel> defaultTaskSeed() {
  final base = DateTime.utc(2026, 7, 1);
  const statuses = TaskStatus.values;
  const priorities = TaskPriority.values;
  const titles = [
    'Draw blood sample',
    'Administer medication',
    'Vitals check',
    'Wound dressing change',
    'Physiotherapy session',
    'ECG recording',
    'Insulin adjustment',
    'Discharge paperwork',
    'X-ray review',
    'IV line replacement',
    'Nutrition consult',
    'Pain reassessment',
    'Fall-risk assessment',
    'Catheter removal',
    'Post-op observation',
  ];

  return [
    // Cycle the title list so a search term (e.g. "blood") matches several rows
    // across pages, which is what makes paginated search meaningful.
    for (var i = 0; i < 50; i++)
      PatientTaskModel(
        id: 't${i + 1}',
        version: 1,
        title: titles[i % titles.length],
        status: statuses[i % statuses.length],
        priority: priorities[i % priorities.length],
        patientReference: 'Patient/${(i % 5) + 1}',
        lastModified: base.add(Duration(hours: i)),
        dueDate: i.isEven ? base.add(Duration(days: i + 1)) : null,
        assignee: i % 3 == 0 ? 'Practitioner/${(i % 4) + 1}' : null,
      ),
  ];
}
