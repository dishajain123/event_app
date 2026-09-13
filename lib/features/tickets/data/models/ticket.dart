/// Mirrors `app/modules/tickets/models.py`'s `TicketStatus` StrEnum
/// exactly.
enum TicketStatus {
  active('active'),
  issued('issued'),
  used('used'),
  checkedIn('checked_in'),
  cancelled('cancelled'),
  expired('expired'),
  revoked('revoked');

  final String wireValue;
  const TicketStatus(this.wireValue);

  static TicketStatus fromWire(String value) {
    return TicketStatus.values.firstWhere(
      (s) => s.wireValue == value,
      orElse: () =>
          throw FormatException('Unknown ticket status from backend: $value'),
    );
  }

  String get label => switch (this) {
        TicketStatus.issued => 'Ready to scan',
        TicketStatus.active => 'Ready to scan',
        TicketStatus.used => 'Used',
        TicketStatus.checkedIn => 'Checked in',
        TicketStatus.cancelled => 'Cancelled',
        TicketStatus.expired => 'Expired',
        TicketStatus.revoked => 'Revoked',
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
  final String barcodePayload;
  final String barcodeSignature;
  final String accessType;
  final int entryCount;
  final TicketStatus status;
  final DateTime? issuedAt;
  final DateTime? checkedInAt;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final List<String> validDates;

  const AppTicket({
    required this.id,
    required this.eventId,
    required this.registrationId,
    required this.paymentId,
    required this.userId,
    required this.ticketCode,
    required this.barcodePayload,
    required this.barcodeSignature,
    required this.accessType,
    required this.entryCount,
    required this.status,
    required this.issuedAt,
    required this.checkedInAt,
    required this.validFrom,
    required this.validUntil,
    required this.validDates,
  });

  factory AppTicket.fromJson(Map<String, dynamic> json) {
    return AppTicket(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      registrationId: json['registration_id'] as String,
      paymentId: json['payment_id'] as String?,
      userId: json['user_id'] as String,
      ticketCode: json['ticket_code'] as String,
      barcodePayload: json['barcode_payload'] as String,
      barcodeSignature: json['barcode_signature'] as String,
      accessType: json['access_type'] as String? ?? 'general',
      entryCount: json['entry_count'] as int? ?? 0,
      status: TicketStatus.fromWire(json['status'] as String),
      issuedAt: json['issued_at'] != null
          ? DateTime.parse(json['issued_at'] as String)
          : null,
      checkedInAt: json['checked_in_at'] != null
          ? DateTime.parse(json['checked_in_at'] as String)
          : null,
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'] as String)
          : null,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : null,
      validDates:
          (json['valid_dates'] as List<dynamic>? ?? const []).cast<String>(),
    );
  }
}

class TicketTransfer {
  final String id;
  final String ticketId;
  final String eventId;
  final String fromUserId;
  final String toUserId;
  final String status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const TicketTransfer({
    required this.id,
    required this.ticketId,
    required this.eventId,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory TicketTransfer.fromJson(Map<String, dynamic> json) => TicketTransfer(
        id: json['id'] as String,
        ticketId: json['ticket_id'] as String,
        eventId: json['event_id'] as String,
        fromUserId: json['from_user_id'] as String,
        toUserId: json['to_user_id'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        respondedAt: json['responded_at'] == null
            ? null
            : DateTime.parse(json['responded_at'] as String),
      );
}

class TicketValidation {
  final bool valid;
  final String reason;
  final AppTicket? ticket;
  final String message;
  const TicketValidation(
      {required this.valid,
      required this.reason,
      required this.ticket,
      required this.message});
  factory TicketValidation.fromJson(Map<String, dynamic> json) =>
      TicketValidation(
          valid: json['valid'] as bool,
          reason: json['reason'] as String,
          ticket: json['ticket'] == null
              ? null
              : AppTicket.fromJson(json['ticket'] as Map<String, dynamic>),
          message: json['message'] as String);
}

/// Mirrors `app/modules/tickets/schemas.py`'s `LastScannedParticipantOut`.
class LastScannedParticipant {
  final String ticketId;
  final String ticketCode;
  final String? participantName;
  final DateTime? checkedInAt;

  const LastScannedParticipant({
    required this.ticketId,
    required this.ticketCode,
    required this.participantName,
    required this.checkedInAt,
  });

  factory LastScannedParticipant.fromJson(Map<String, dynamic> json) =>
      LastScannedParticipant(
        ticketId: json['ticket_id'] as String,
        ticketCode: json['ticket_code'] as String,
        participantName: json['participant_name'] as String?,
        checkedInAt: json['checked_in_at'] != null
            ? DateTime.parse(json['checked_in_at'] as String)
            : null,
      );
}

/// Mirrors `app/modules/tickets/schemas.py`'s `MyScanStatsOut` — powers the
/// scan-count badge and last-scanned card on the barcode scanner screen.
class MyScanStats {
  final String eventId;
  final int scannedCount;
  final LastScannedParticipant? lastScanned;

  const MyScanStats({
    required this.eventId,
    required this.scannedCount,
    required this.lastScanned,
  });

  factory MyScanStats.fromJson(Map<String, dynamic> json) => MyScanStats(
        eventId: json['event_id'] as String,
        scannedCount: json['scanned_count'] as int,
        lastScanned: json['last_scanned'] != null
            ? LastScannedParticipant.fromJson(
                json['last_scanned'] as Map<String, dynamic>)
            : null,
      );
}
