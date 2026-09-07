/// Mirrors `app/modules/teams/models.py`'s `TeamStatus` StrEnum exactly.
enum TeamStatus {
  draft('draft'),
  inviting('inviting'),
  submitted('submitted'),
  approved('approved'),
  rejected('rejected'),
  archived('archived');

  final String wireValue;
  const TeamStatus(this.wireValue);

  static TeamStatus fromWire(String value) {
    return TeamStatus.values.firstWhere(
      (s) => s.wireValue == value,
      orElse: () =>
          throw FormatException('Unknown team status from backend: $value'),
    );
  }

  String get label => switch (this) {
        TeamStatus.draft => 'Draft',
        TeamStatus.inviting => 'Inviting',
        TeamStatus.submitted => 'Submitted',
        TeamStatus.approved => 'Approved',
        TeamStatus.rejected => 'Rejected',
        TeamStatus.archived => 'Archived',
      };
}

enum TeamMemberRole {
  captain('captain'),
  manager('manager'),
  member('member');

  final String wireValue;
  const TeamMemberRole(this.wireValue);
  static TeamMemberRole fromWire(String? value) =>
      TeamMemberRole.values.firstWhere(
        (role) => role.wireValue == value,
        orElse: () => TeamMemberRole.member,
      );
}

/// Mirrors `app/modules/teams/models.py`'s `InvitationStatus` StrEnum
/// exactly.
enum InvitationStatus {
  pending('pending'),
  accepted('accepted'),
  rejected('rejected');

  final String wireValue;
  const InvitationStatus(this.wireValue);

  static InvitationStatus fromWire(String value) {
    return InvitationStatus.values.firstWhere(
      (s) => s.wireValue == value,
      orElse: () => throw FormatException(
          'Unknown invitation status from backend: $value'),
    );
  }
}

/// Mirrors `app/modules/teams/schemas.py`'s `TeamOut` exactly.
class AppTeam {
  final String id;
  final String eventId;
  final String captainUserId;
  final String name;
  final String teamCode;
  final String? managerUserId;
  final String? registrationId;
  final TeamStatus status;
  final DateTime? captainDateOfBirth;
  final DateTime? submittedAt;
  final String? approvedBy;
  final String? rejectedBy;
  final String? rejectionReason;

  const AppTeam({
    required this.id,
    required this.eventId,
    required this.captainUserId,
    required this.name,
    required this.teamCode,
    required this.managerUserId,
    required this.registrationId,
    required this.status,
    required this.captainDateOfBirth,
    required this.submittedAt,
    required this.approvedBy,
    required this.rejectedBy,
    required this.rejectionReason,
  });

  factory AppTeam.fromJson(Map<String, dynamic> json) {
    return AppTeam(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      captainUserId: json['captain_user_id'] as String,
      name: json['name'] as String,
      teamCode: json['team_code'] as String? ?? '',
      managerUserId: json['manager_user_id'] as String?,
      registrationId: json['registration_id'] as String?,
      status: TeamStatus.fromWire(json['status'] as String),
      captainDateOfBirth: json['captain_date_of_birth'] != null
          ? DateTime.parse(json['captain_date_of_birth'] as String)
          : null,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      approvedBy: json['approved_by'] as String?,
      rejectedBy: json['rejected_by'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }
}

/// Mirrors `app/modules/teams/schemas.py`'s `TeamMemberOut` exactly.
class TeamMember {
  final String id;
  final String teamId;
  final String? userId;
  final String fullName;
  final DateTime? dateOfBirth;
  final bool isCaptain;
  final TeamMemberRole role;

  const TeamMember({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.fullName,
    required this.dateOfBirth,
    required this.isCaptain,
    required this.role,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      userId: json['user_id'] as String?,
      fullName: json['full_name'] as String,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      isCaptain: json['is_captain'] as bool,
      role: TeamMemberRole.fromWire(json['role'] as String?),
    );
  }
}

/// Mirrors `app/modules/teams/schemas.py`'s `TeamInvitationOut` exactly.
class TeamInvitation {
  final String id;
  final String teamId;
  final String inviteeMobile;
  final String token;
  final InvitationStatus status;
  final DateTime? respondedAt;

  const TeamInvitation({
    required this.id,
    required this.teamId,
    required this.inviteeMobile,
    required this.token,
    required this.status,
    required this.respondedAt,
  });

  factory TeamInvitation.fromJson(Map<String, dynamic> json) {
    return TeamInvitation(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      inviteeMobile: json['invitee_mobile'] as String,
      token: json['token'] as String,
      status: InvitationStatus.fromWire(json['status'] as String),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
    );
  }
}
