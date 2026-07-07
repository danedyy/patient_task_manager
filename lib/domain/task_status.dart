import 'package:json_annotation/json_annotation.dart';

/// Status of a patient task, shaped after the FHIR Task lifecycle.
enum TaskStatus {
  @JsonValue('requested')
  requested,
  @JsonValue('in-progress')
  inProgress,
  @JsonValue('on-hold')
  onHold,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
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
