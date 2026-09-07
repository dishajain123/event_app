enum WaitlistStatus {
  waiting('waiting'),
  promoted('promoted'),
  expired('expired'),
  left('left'),
  closed('closed');

  final String wireValue;
  const WaitlistStatus(this.wireValue);

  static WaitlistStatus fromWire(String value) => values.firstWhere(
        (status) => status.wireValue == value,
        orElse: () => throw FormatException('Unknown waitlist status: $value'),
      );
}

class WaitlistEntry {
  final String id;
  final String eventId;
  final String participationType;
  final WaitlistStatus status;
  final DateTime joinedAt;
  final int? position;
  final DateTime? promotedAt;
  final DateTime? promotionExpiresAt;
  final DateTime? leftAt;
  final DateTime? expiredAt;

  const WaitlistEntry({
    required this.id,
    required this.eventId,
    required this.participationType,
    required this.status,
    required this.joinedAt,
    required this.position,
    required this.promotedAt,
    required this.promotionExpiresAt,
    required this.leftAt,
    required this.expiredAt,
  });

  factory WaitlistEntry.fromJson(Map<String, dynamic> json) => WaitlistEntry(
        id: json['id'] as String,
        eventId: json['event_id'] as String,
        participationType: json['participation_type'] as String,
        status: WaitlistStatus.fromWire(json['status'] as String),
        joinedAt: DateTime.parse(json['joined_at'] as String),
        position: json['position'] as int?,
        promotedAt: _date(json['promoted_at']),
        promotionExpiresAt: _date(json['promotion_expires_at']),
        leftAt: _date(json['left_at']),
        expiredAt: _date(json['expired_at']),
      );

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.parse(value as String);
}
