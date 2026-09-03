/// Mirrors `app/modules/notifications/models.py`'s `NotificationChannel`
/// StrEnum exactly.
enum NotificationChannel {
  sms('sms'),
  email('email'),
  push('push');

  final String wireValue;
  const NotificationChannel(this.wireValue);

  static NotificationChannel fromWire(String value) {
    return NotificationChannel.values.firstWhere(
      (c) => c.wireValue == value,
      orElse: () => throw FormatException('Unknown notification channel from backend: $value'),
    );
  }
}

/// Mirrors `NotificationDeliveryStatus` exactly.
enum NotificationDeliveryStatus {
  queued('queued'),
  sent('sent'),
  failed('failed');

  final String wireValue;
  const NotificationDeliveryStatus(this.wireValue);

  static NotificationDeliveryStatus fromWire(String value) {
    return NotificationDeliveryStatus.values.firstWhere(
      (s) => s.wireValue == value,
      orElse: () => throw FormatException('Unknown delivery status from backend: $value'),
    );
  }
}

/// Mirrors `app/modules/notifications/schemas.py`'s `NotificationOut`
/// exactly.
class AppNotification {
  final String id;
  final String eventId;
  final String recipientUserId;
  final String? templateId;
  final NotificationChannel channel;
  final String title;
  final String body;
  final NotificationDeliveryStatus deliveryStatus;
  final DateTime? sentAt;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.eventId,
    required this.recipientUserId,
    required this.templateId,
    required this.channel,
    required this.title,
    required this.body,
    required this.deliveryStatus,
    required this.sentAt,
    required this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      recipientUserId: json['recipient_user_id'] as String,
      templateId: json['template_id'] as String?,
      channel: NotificationChannel.fromWire(json['channel'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      deliveryStatus: NotificationDeliveryStatus.fromWire(json['delivery_status'] as String),
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at'] as String) : null,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isUnread => readAt == null;
}
