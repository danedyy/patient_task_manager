enum TaskStatus {
  requested,
  inProgress,
  onHold,
  completed,
  cancelled;

  /// The single source of truth
  /// for the state machine: transition validation and the UI's action buttons
  /// both derive from it.
  Set<TaskStatus> get allowedNext => switch (this) {
    requested => const {inProgress, cancelled},
    inProgress => const {onHold, completed, cancelled},
    onHold => const {inProgress, cancelled},
    completed || cancelled => const {},
  };

  bool get isTerminal => allowedNext.isEmpty;

  /// Whether moving to [next] is a legal transition from this status.
  bool canTransitionTo(TaskStatus next) => allowedNext.contains(next);
}
