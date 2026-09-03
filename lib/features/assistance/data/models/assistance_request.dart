import '../../../../core/utils/flexible_decimal.dart';

/// Mirrors `app/modules/assistance/models.py`'s `AssistanceRequestStatus`
/// StrEnum exactly.
enum AssistanceRequestStatus {
  pending('pending'),
  assigned('assigned'),
  approved('approved'),
  rejected('rejected');

  final String wireValue;
  const AssistanceRequestStatus(this.wireValue);

  static AssistanceRequestStatus fromWire(String value) {
    return AssistanceRequestStatus.values.firstWhere(
      (s) => s.wireValue == value,
      orElse: () => throw FormatException('Unknown assistance request status from backend: $value'),
    );
  }

  String get label => switch (this) {
        AssistanceRequestStatus.pending => 'Pending review',
        AssistanceRequestStatus.assigned => 'Under review',
        AssistanceRequestStatus.approved => 'Approved',
        AssistanceRequestStatus.rejected => 'Rejected',
      };
}

/// Mirrors `app/modules/assistance/schemas.py`'s `AssistanceRequestOut`
/// exactly.
class AssistanceRequest {
  final String id;
  final String eventId;
  final String registrationId;
  final String requesterUserId;
  final String? reviewerUserId;
  final AssistanceRequestStatus status;
  final String reason;
  final double? requestedFeeWaiverAmount;
  final String? decisionReason;
  final DateTime? decidedAt;
  final String? appliedDiscountCode;
  final DateTime createdAt;

  const AssistanceRequest({
    required this.id,
    required this.eventId,
    required this.registrationId,
    required this.requesterUserId,
    required this.reviewerUserId,
    required this.status,
    required this.reason,
    required this.requestedFeeWaiverAmount,
    required this.decisionReason,
    required this.decidedAt,
    required this.appliedDiscountCode,
    required this.createdAt,
  });

  factory AssistanceRequest.fromJson(Map<String, dynamic> json) {
    return AssistanceRequest(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      registrationId: json['registration_id'] as String,
      requesterUserId: json['requester_user_id'] as String,
      reviewerUserId: json['reviewer_user_id'] as String?,
      status: AssistanceRequestStatus.fromWire(json['status'] as String),
      reason: json['reason'] as String,
      requestedFeeWaiverAmount: parseFlexibleDecimal(json['requested_fee_waiver_amount']),
      decisionReason: json['decision_reason'] as String?,
      decidedAt: json['decided_at'] != null ? DateTime.parse(json['decided_at'] as String) : null,
      appliedDiscountCode: json['applied_discount_code'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
