import '../../../../auth/data/models/role_name.dart';

/// Mirrors `app/modules/staff/models.py`'s `StaffAssignmentStatus`
/// StrEnum exactly.
enum StaffAssignmentStatus {
  invited('invited'),
  active('active'),
  revoked('revoked');

  final String wireValue;
  const StaffAssignmentStatus(this.wireValue);

  static StaffAssignmentStatus fromWire(String value) {
    return StaffAssignmentStatus.values.firstWhere(
      (s) => s.wireValue == value,
      orElse: () => throw FormatException(
          'Unknown staff assignment status from backend: $value'),
    );
  }

  String get label => switch (this) {
        StaffAssignmentStatus.invited => 'Pending',
        StaffAssignmentStatus.active => 'Active',
        StaffAssignmentStatus.revoked => 'Revoked',
      };
}

/// Mirrors `app/modules/staff/schemas.py`'s `StaffAssignmentOut` exactly.
class StaffAssignment {
  final String id;
  final String eventId;
  final String? venueId;
  final String? userId;
  final String inviteeMobile;
  final String? fullName;
  final RoleName? roleName;
  final String roleLabel;
  final StaffAssignmentStatus status;
  final String invitedBy;
  final String? acceptedBy;
  final DateTime? acceptedAt;
  final DateTime? revokedAt;
  // Only populated by GET /staff/assignments/mine — see StaffAssignmentOut's
  // doc comment in app/modules/staff/schemas.py. Lets "My Events" show which
  // event/when/where an assignment is for, instead of just a role label.
  final String? eventName;
  final DateTime? eventStartDate;
  final DateTime? eventEndDate;
  final String? venueName;

  const StaffAssignment({
    required this.id,
    required this.eventId,
    required this.venueId,
    required this.userId,
    required this.inviteeMobile,
    required this.fullName,
    required this.roleName,
    required this.roleLabel,
    required this.status,
    required this.invitedBy,
    required this.acceptedBy,
    required this.acceptedAt,
    required this.revokedAt,
    this.eventName,
    this.eventStartDate,
    this.eventEndDate,
    this.venueName,
  });

  bool get isPastEvent =>
      eventEndDate != null && eventEndDate!.isBefore(DateTime.now());

  factory StaffAssignment.fromJson(Map<String, dynamic> json) {
    return StaffAssignment(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      venueId: json['venue_id'] as String?,
      userId: json['user_id'] as String?,
      inviteeMobile: json['invitee_mobile'] as String,
      fullName: json['full_name'] as String?,
      roleName: json['role_name'] != null
          ? RoleName.fromWire(json['role_name'] as String)
          : null,
      roleLabel: json['role_label'] as String,
      status: StaffAssignmentStatus.fromWire(json['status'] as String),
      invitedBy: json['invited_by'] as String,
      acceptedBy: json['accepted_by'] as String?,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      revokedAt: json['revoked_at'] != null
          ? DateTime.parse(json['revoked_at'] as String)
          : null,
      eventName: json['event_name'] as String?,
      eventStartDate: json['event_start_date'] != null
          ? DateTime.parse(json['event_start_date'] as String)
          : null,
      eventEndDate: json['event_end_date'] != null
          ? DateTime.parse(json['event_end_date'] as String)
          : null,
      venueName: json['venue_name'] as String?,
    );
  }
}

/// Mirrors `app/modules/staff/schemas.py`'s `StaffAssignmentHistoryOut`
/// exactly.
class StaffAssignmentHistoryEntry {
  final String id;
  final String assignmentId;
  final String action;
  final String? actorUserId;
  final String? notes;
  final DateTime createdAt;

  const StaffAssignmentHistoryEntry({
    required this.id,
    required this.assignmentId,
    required this.action,
    required this.actorUserId,
    required this.notes,
    required this.createdAt,
  });

  factory StaffAssignmentHistoryEntry.fromJson(Map<String, dynamic> json) {
    return StaffAssignmentHistoryEntry(
      id: json['id'] as String,
      assignmentId: json['assignment_id'] as String,
      action: json['action'] as String,
      actorUserId: json['actor_user_id'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
