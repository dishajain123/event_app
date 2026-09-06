class FeedbackCategoryOption {
  final String code;
  final String label;

  const FeedbackCategoryOption({required this.code, required this.label});

  factory FeedbackCategoryOption.fromJson(Map<String, dynamic> json) {
    return FeedbackCategoryOption(
        code: json['code'] as String, label: json['label'] as String);
  }
}

class EventFeedback {
  final String id;
  final String eventId;
  final String? eventName;
  final String userId;
  final String? userName;
  final String category;
  final String categoryLabel;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventFeedback({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.userId,
    required this.userName,
    required this.category,
    required this.categoryLabel,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventFeedback.fromJson(Map<String, dynamic> json) {
    return EventFeedback(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      eventName: json['event_name'] as String?,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String?,
      category: json['category'] as String,
      categoryLabel:
          json['category_label'] as String? ?? json['category'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
