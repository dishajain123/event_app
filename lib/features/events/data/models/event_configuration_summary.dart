import '../../../../core/utils/flexible_decimal.dart';

/// Mirrors `app/modules/config_engine/schemas.py`'s `EventConfigurationOut`
/// — modeled here only as far as Phase 2 needs (Section 8: gating the
/// event-detail screen's "Register" CTA on real participation types and
/// fee data). The full `rules`/`details`/field-schema handling this class
/// deliberately leaves as raw maps is built out properly in Phase 3's
/// `config_engine` feature — this class is NOT where that logic belongs;
/// it only exists because `EventOut.configuration` is embedded inline and
/// something has to parse it today without overstepping into Phase 3's
/// scope.
class EventConfigurationSummary {
  final List<String> participationTypes;
  final double? feeAmount;
  final String currency;
  final int? capacity;
  final bool volunteerOpen;
  final DateTime? registrationEndAt;
  final int registeredCount;
  final int? availableCapacity;
  final String registrationStatus;
  final bool approvalRequired;

  const EventConfigurationSummary({
    required this.participationTypes,
    required this.feeAmount,
    required this.currency,
    required this.capacity,
    required this.volunteerOpen,
    required this.registrationEndAt,
    required this.registeredCount,
    required this.availableCapacity,
    required this.registrationStatus,
    required this.approvalRequired,
  });

  factory EventConfigurationSummary.fromJson(Map<String, dynamic> json) {
    final rawTypes = json['participation_types'] as List<dynamic>? ?? [];
    return EventConfigurationSummary(
      participationTypes: rawTypes.map((t) => t as String).toList(),
      feeAmount: parseFlexibleDecimal(json['fee_amount']),
      currency: json['currency'] as String? ?? 'INR',
      capacity: json['capacity'] as int?,
      volunteerOpen: json['volunteer_open'] as bool? ?? true,
      registrationEndAt: json['registration_end_at'] != null
          ? DateTime.parse(json['registration_end_at'] as String)
          : null,
      registeredCount: json['registered_count'] as int? ?? 0,
      availableCapacity: json['available_capacity'] as int?,
      registrationStatus: json['registration_status'] as String? ?? 'closed',
      approvalRequired: json['approval_required'] as bool? ?? false,
    );
  }

  bool get isFree => feeAmount == null || feeAmount == 0;
}
