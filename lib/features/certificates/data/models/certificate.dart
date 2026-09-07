class AppCertificate {
  final String id;
  final String certificateNumber;
  final String status;
  final String eventId;
  final String templateId;
  final String? artifactUrl;
  final DateTime issuedAt;
  final String? eventName;
  final String? certificateType;
  final String? title;
  final String? issuerName;
  final Map<String, dynamic>? criteria;
  const AppCertificate(
      {required this.id,
      required this.certificateNumber,
      required this.status,
      required this.eventId,
      required this.templateId,
      required this.artifactUrl,
      required this.issuedAt,
      this.eventName,
      this.certificateType,
      this.title,
      this.issuerName,
      this.criteria});
  factory AppCertificate.fromJson(Map<String, dynamic> json) => AppCertificate(
      id: json['id'] as String,
      certificateNumber: json['certificate_number'] as String,
      status: json['status'] as String,
      eventId: json['event_id'] as String,
      templateId: json['template_id'] as String,
      artifactUrl: json['artifact_url'] as String?,
      issuedAt: DateTime.parse(json['created_at'] as String),
      eventName: json['event_name'] as String?,
      certificateType: json['certificate_type'] as String?,
      title: json['title'] as String?,
      issuerName: json['issuer_name'] as String?,
      criteria: (json['criteria'] as Map?)?.cast<String, dynamic>());
}

class AppBadgeAward {
  final String id;
  final String badgeId;
  final String eventId;
  final String status;
  final DateTime awardedAt;
  const AppBadgeAward(
      {required this.id,
      required this.badgeId,
      required this.eventId,
      required this.status,
      required this.awardedAt});
  factory AppBadgeAward.fromJson(Map<String, dynamic> json) => AppBadgeAward(
      id: json['id'] as String,
      badgeId: json['badge_id'] as String,
      eventId: json['event_id'] as String,
      status: json['status'] as String,
      awardedAt: DateTime.parse(json['created_at'] as String));
}
