import 'registration_status.dart';

/// Mirrors `app/modules/registrations/schemas.py`'s
/// `RegistrationParticipantOut` exactly.
class RegistrationParticipant {
  final String id;
  final String registrationId;
  final String? userId;
  final String fullName;
  final DateTime? dateOfBirth;
  final bool isCaptain;

  const RegistrationParticipant({
    required this.id,
    required this.registrationId,
    required this.userId,
    required this.fullName,
    required this.dateOfBirth,
    required this.isCaptain,
  });

  factory RegistrationParticipant.fromJson(Map<String, dynamic> json) {
    return RegistrationParticipant(
      id: json['id'] as String,
      registrationId: json['registration_id'] as String,
      userId: json['user_id'] as String?,
      fullName: json['full_name'] as String,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth'] as String) : null,
      isCaptain: json['is_captain'] as bool,
    );
  }
}

/// Mirrors `app/modules/registrations/schemas.py`'s `RegistrationOut`
/// exactly.
class AppRegistration {
  final String id;
  final String eventId;
  final String userId;
  final String? childId;
  final String? teamId;
  final String participationType;
  final RegistrationStatus status;
  final DateTime? submittedAt;
  final String? approvedBy;
  final String? rejectedBy;
  final String? rejectionReason;
  final DateTime? checkedInAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RegistrationParticipant> participants;

  const AppRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.childId,
    required this.teamId,
    required this.participationType,
    required this.status,
    required this.submittedAt,
    required this.approvedBy,
    required this.rejectedBy,
    required this.rejectionReason,
    required this.checkedInAt,
    required this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.participants,
  });

  factory AppRegistration.fromJson(Map<String, dynamic> json) {
    final rawParticipants = json['participants'] as List<dynamic>? ?? [];
    return AppRegistration(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      childId: json['child_id'] as String?,
      teamId: json['team_id'] as String?,
      participationType: json['participation_type'] as String,
      status: RegistrationStatus.fromWire(json['status'] as String),
      submittedAt: json['submitted_at'] != null ? DateTime.parse(json['submitted_at'] as String) : null,
      approvedBy: json['approved_by'] as String?,
      rejectedBy: json['rejected_by'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      checkedInAt: json['checked_in_at'] != null ? DateTime.parse(json['checked_in_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      participants: rawParticipants
          .map((p) => RegistrationParticipant.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Mirrors `RegistrationParticipantIn` — the request-side shape for a
/// participant when creating a registration.
class RegistrationParticipantInput {
  final String fullName;
  final String? dateOfBirthIso;
  final bool isCaptain;

  const RegistrationParticipantInput({
    required this.fullName,
    this.dateOfBirthIso,
    this.isCaptain = false,
  });

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        if (dateOfBirthIso != null) 'date_of_birth': dateOfBirthIso,
        'is_captain': isCaptain,
      };
}
