/// Mirrors `app/modules/tickets/models.py`'s `TicketStatus` StrEnum
/// exactly.
enum TicketStatus {
  issued('issued'),
  checkedIn('checked_in'),
  cancelled('cancelled');

  final String wireValue;
  const TicketStatus(this.wireValue);

  static TicketStatus fromWire(String value) {
    return TicketStatus.values.firstWhere(
      (s) => s.wireValue == value,
      orElse: () => throw FormatException('Unknown ticket status from backend: $value'),
    );
  }

  String get label => switch (this) {
        TicketStatus.issued => 'Ready to scan',
        TicketStatus.checkedIn => 'Checked in',
        TicketStatus.cancelled => 'Cancelled',
      };
}

/// Mirrors `app/modules/tickets/schemas.py`'s `TicketOut` exactly.
/// `paymentId` is nullable — a free event's ticket legitimately has none
/// (the free-event ticket-issuance fix from earlier in this project is
/// exactly why this field can be null and still represent a fully valid,
/// confirmed ticket).
class AppTicket {
  final String id;
  final String eventId;
  final String registrationId;
  final String? paymentId;
  final String userId;
  final String ticketCode;
  final String qrPayload;
  final TicketStatus status;
  final DateTime? issuedAt;
  final DateTime? checkedInAt;

  const AppTicket({
    required this.id,
    required this.eventId,
    required this.registrationId,
    required this.paymentId,
    required this.userId,
    required this.ticketCode,
    required this.qrPayload,
    required this.status,
    required this.issuedAt,
    required this.checkedInAt,
  });

  factory AppTicket.fromJson(Map<String, dynamic> json) {
    return AppTicket(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      registrationId: json['registration_id'] as String,
      paymentId: json['payment_id'] as String?,
      userId: json['user_id'] as String,
      ticketCode: json['ticket_code'] as String,
      qrPayload: json['qr_payload'] as String,
      status: TicketStatus.fromWire(json['status'] as String),
      issuedAt: json['issued_at'] != null ? DateTime.parse(json['issued_at'] as String) : null,
      checkedInAt: json['checked_in_at'] != null ? DateTime.parse(json['checked_in_at'] as String) : null,
    );
  }
}
