/// Status of a patient task, shaped after the FHIR Task lifecycle.
///
/// A pure domain entity: no serialization concerns live here. Wire-name
/// mapping is the data layer's job (see `PatientTaskModel`).
enum TaskStatus {
  requested,
  inProgress,
  onHold,
  completed,
  cancelled;

  /// Statuses this one may legally transition to. The single source of truth
  /// for the state machine: [TaskTransition.tryCreate] and the UI's action
  /// buttons both derive from it.
  Set<TaskStatus> get allowedNext => switch (this) {
    requested => const {inProgress, cancelled},
    inProgress => const {onHold, completed, cancelled},
    onHold => const {inProgress, cancelled},
    completed || cancelled => const {},
  };

  bool get isTerminal => allowedNext.isEmpty;
}