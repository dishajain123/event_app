/// Mirrors `app/modules/events/models.py`'s `EventStatus` StrEnum exactly.
enum EventStatus {
  draft('draft'),
  configured('configured'),
  published('published'),
  registrationOpen('registration_open'),
  registrationClosed('registration_closed'),
  live('live'),
  completed('completed'),
  archived('archived');

  final String wireValue;
  const EventStatus(this.wireValue);

  static EventStatus fromWire(String value) {
    return EventStatus.values.firstWhere(
      (s) => s.wireValue == value,
      orElse: () =>
          throw FormatException('Unknown event status from backend: $value'),
    );
  }

  /// Human-readable label — mirrors the console's EVENT_STATUS_LABELS
  /// mapping so the same status reads the same way on both surfaces.
  String get label => switch (this) {
        EventStatus.draft => 'Draft',
        EventStatus.configured => 'Configured',
        EventStatus.published => 'Published',
        EventStatus.registrationOpen => 'Registration Open',
        EventStatus.registrationClosed => 'Registration Closed',
        EventStatus.live => 'Live',
        EventStatus.completed => 'Completed',
        EventStatus.archived => 'Archived',
      };

  /// Whether this event is far enough along in its lifecycle that a
  /// participant could reasonably expect to register — used to gate the
  /// event-detail screen's primary CTA (Section 8, Phase 2). The backend
  /// is still the real authority on whether a specific registration
  /// attempt succeeds; this only decides whether to SHOW the button.
  bool get acceptsRegistration => this == EventStatus.registrationOpen;
}
