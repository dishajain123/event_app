/// Mirrors `app/modules/registrations/models.py`'s `RegistrationStatus`
/// StrEnum exactly — twelve values, transcribed from the actual backend
/// source.
enum RegistrationStatus {
  started('started'),
  submitted('submitted'),
  pendingVerification('pending_verification'),
  pendingPayment('pending_payment'),
  refundPending('refund_pending'),
  refundFailed('refund_failed'),
  approved('approved'),
  confirmed('confirmed'),
  checkedIn('checked_in'),
  completed('completed'),
  rejected('rejected'),
  cancelled('cancelled');

  final String wireValue;
  const RegistrationStatus(this.wireValue);

  static RegistrationStatus fromWire(String value) {
    return RegistrationStatus.values.firstWhere(
      (s) => s.wireValue == value,
      orElse: () => throw FormatException('Unknown registration status from backend: $value'),
    );
  }

  /// Mirrors the console's REGISTRATION_STATUS_LABELS so the same status
  /// reads the same way on both surfaces.
  String get label => switch (this) {
        RegistrationStatus.started => 'Started',
        RegistrationStatus.submitted => 'Submitted',
        RegistrationStatus.pendingVerification => 'Pending Verification',
        RegistrationStatus.pendingPayment => 'Pending Payment',
        RegistrationStatus.refundPending => 'Refund Pending',
        RegistrationStatus.refundFailed => 'Refund Failed',
        RegistrationStatus.approved => 'Approved',
        RegistrationStatus.confirmed => 'Confirmed',
        RegistrationStatus.checkedIn => 'Checked In',
        RegistrationStatus.completed => 'Completed',
        RegistrationStatus.rejected => 'Rejected',
        RegistrationStatus.cancelled => 'Cancelled',
      };

  bool get isActive => this != RegistrationStatus.rejected && this != RegistrationStatus.cancelled;
}
