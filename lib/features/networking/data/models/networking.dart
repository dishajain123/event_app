class NetworkingProfile {
  final String id, eventId, userId;
  final String? displayName, organization, designation, bio;
  final List<String> interests, skills, explanation;
  final int? score;
  final String visibility;
  const NetworkingProfile(
      {required this.id,
      required this.eventId,
      required this.userId,
      required this.displayName,
      required this.organization,
      required this.designation,
      required this.bio,
      required this.interests,
      required this.skills,
      required this.visibility,
      required this.score,
      required this.explanation});
  factory NetworkingProfile.fromJson(Map<String, dynamic> j) =>
      NetworkingProfile(
          id: j['id'] as String,
          eventId: j['event_id'] as String,
          userId: j['user_id'] as String,
          displayName: j['display_name'] as String?,
          organization: j['organization'] as String?,
          designation: j['designation'] as String?,
          bio: j['bio'] as String?,
          interests: ((j['interests'] as List<dynamic>?) ?? []).cast<String>(),
          skills: ((j['skills'] as List<dynamic>?) ?? []).cast<String>(),
          visibility: j['visibility'] as String,
          score: j['score'] as int?,
          explanation:
              ((j['explanation'] as List<dynamic>?) ?? []).cast<String>());
}

class NetworkingParticipantPage {
  final List<NetworkingProfile> items;
  final int total;
  final int page;
  final int pageSize;
  const NetworkingParticipantPage(
      {required this.items,
      required this.total,
      required this.page,
      required this.pageSize});
  factory NetworkingParticipantPage.fromJson(Map<String, dynamic> json) =>
      NetworkingParticipantPage(
        items: ((json['items'] as List<dynamic>?) ?? [])
            .map((e) => NetworkingProfile.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (json['total'] as num?)?.toInt() ?? 0,
        page: (json['page'] as num?)?.toInt() ?? 1,
        pageSize: (json['page_size'] as num?)?.toInt() ?? 25,
      );
}

class NetworkingActivity {
  final String id, eventId, activityType, title, status;
  final DateTime? startsAt, endsAt;
  const NetworkingActivity(
      {required this.id,
      required this.eventId,
      required this.activityType,
      required this.title,
      required this.status,
      this.startsAt,
      this.endsAt});
  factory NetworkingActivity.fromJson(Map<String, dynamic> json) =>
      NetworkingActivity(
        id: json['id'] as String,
        eventId: json['event_id'] as String,
        activityType: json['activity_type'] as String,
        title: json['title'] as String,
        status: json['status'] as String,
        startsAt: json['starts_at'] == null
            ? null
            : DateTime.parse(json['starts_at'] as String),
        endsAt: json['ends_at'] == null
            ? null
            : DateTime.parse(json['ends_at'] as String),
      );
}

class NetworkingActivityPage {
  final List<NetworkingActivity> items;
  final int total;
  const NetworkingActivityPage({required this.items, required this.total});
  factory NetworkingActivityPage.fromJson(Map<String, dynamic> json) =>
      NetworkingActivityPage(
        items: ((json['items'] as List<dynamic>?) ?? [])
            .map((e) => NetworkingActivity.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (json['total'] as num?)?.toInt() ?? 0,
      );
}

class NetworkingConnection {
  final String id,
      eventId,
      participantLowId,
      participantHighId,
      requestedBy,
      status,
      intent;
  const NetworkingConnection(
      {required this.id,
      required this.eventId,
      required this.participantLowId,
      required this.participantHighId,
      required this.requestedBy,
      required this.status,
      required this.intent});
  factory NetworkingConnection.fromJson(Map<String, dynamic> j) =>
      NetworkingConnection(
          id: j['id'] as String,
          eventId: j['event_id'] as String,
          participantLowId: j['participant_low_id'] as String,
          participantHighId: j['participant_high_id'] as String,
          requestedBy: j['requested_by'] as String,
          status: j['status'] as String,
          intent: j['intent'] as String);
}
