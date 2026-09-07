enum IncidentStatus {
  open,
  acknowledged,
  inProgress,
  resolved,
  closed,
  cancelled
}

enum IncidentSeverity { low, medium, high, critical }

IncidentSeverity incidentSeverityFromWire(String value) =>
    IncidentSeverity.values.firstWhere((v) => v.name == value);
IncidentStatus incidentStatusFromWire(String value) =>
    IncidentStatus.values.firstWhere((v) => v.name == value);

class Incident {
  final String id;
  final String eventId;
  final String reporterUserId;
  final String? assignedUserId;
  final String category;
  final String title;
  final String description;
  final IncidentStatus status;
  final IncidentSeverity severity;
  final DateTime createdAt;

  const Incident(
      {required this.id,
      required this.eventId,
      required this.reporterUserId,
      required this.assignedUserId,
      required this.category,
      required this.title,
      required this.description,
      required this.status,
      required this.severity,
      required this.createdAt});

  factory Incident.fromJson(Map<String, dynamic> json) => Incident(
        id: json['id'] as String,
        eventId: json['event_id'] as String,
        reporterUserId: json['reporter_user_id'] as String,
        assignedUserId: json['assigned_user_id'] as String?,
        category: json['category'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        status: incidentStatusFromWire(json['status'] as String),
        severity: incidentSeverityFromWire(json['severity'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class IncidentPage {
  final List<Incident> items;
  final int total;
  const IncidentPage({required this.items, required this.total});
  factory IncidentPage.fromJson(Map<String, dynamic> json) => IncidentPage(
        items: (json['items'] as List<dynamic>)
            .map((item) => Incident.fromJson(item as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int,
      );
}
