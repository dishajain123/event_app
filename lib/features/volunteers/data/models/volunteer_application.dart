enum VolunteerApplicationStatus {
  submitted('submitted'),
  underReview('under_review'),
  contacted('contacted'),
  approved('approved'),
  rejected('rejected');

  final String wireValue;
  const VolunteerApplicationStatus(this.wireValue);

  static VolunteerApplicationStatus fromWire(String value) => values.firstWhere(
        (item) => item.wireValue == value,
        orElse: () => VolunteerApplicationStatus.submitted,
      );
}

enum VolunteerApplicationType {
  volunteer('volunteer'),
  eventManager('event_manager');

  final String wireValue;
  const VolunteerApplicationType(this.wireValue);

  static VolunteerApplicationType fromWire(String value) => values.firstWhere(
        (item) => item.wireValue == value,
        orElse: () => VolunteerApplicationType.volunteer,
      );
}

class VolunteerApplication {
  final String id;
  final String eventId;
  final VolunteerApplicationType applicationType;
  final String fullName;
  final String? email;
  final String? skillsExperience;
  final String? availability;
  final String? preferredResponsibility;
  final String? message;
  final VolunteerApplicationStatus status;
  final DateTime createdAt;
  final String? activatedStaffAssignmentId;

  const VolunteerApplication({
    required this.id,
    required this.eventId,
    required this.applicationType,
    required this.fullName,
    required this.email,
    required this.skillsExperience,
    required this.availability,
    required this.preferredResponsibility,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.activatedStaffAssignmentId,
  });

  factory VolunteerApplication.fromJson(Map<String, dynamic> json) =>
      VolunteerApplication(
        id: json['id'] as String,
        eventId: json['event_id'] as String,
        applicationType: VolunteerApplicationType.fromWire(
            json['application_type'] as String? ?? 'volunteer'),
        fullName: json['full_name'] as String,
        email: json['email'] as String?,
        skillsExperience: json['skills_experience'] as String?,
        availability: json['availability'] as String?,
        preferredResponsibility: json['preferred_responsibility'] as String?,
        message: json['message'] as String?,
        status: VolunteerApplicationStatus.fromWire(json['status'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        activatedStaffAssignmentId:
            json['activated_staff_assignment_id'] as String?,
      );
}
