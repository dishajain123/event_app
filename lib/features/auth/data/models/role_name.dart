/// Mirrors `app/modules/rbac/models.py`'s `RoleName` StrEnum exactly — same
/// nine values, same string representation. Every value is transcribed
/// from the actual backend source, not invented (Section 22 of the brief).
enum RoleName {
  superAdmin('super_admin'),
  operationsAdmin('operations_admin'),
  financeAdmin('finance_admin'),
  financeOperator('finance_operator'),
  financeAuditor('finance_auditor'),
  eventManager('event_manager'),
  eventCoordinator('event_coordinator'),
  staffLead('staff_lead'),
  staffMember('staff_member');

  final String wireValue;
  const RoleName(this.wireValue);

  static RoleName fromWire(String value) {
    return RoleName.values.firstWhere(
      (r) => r.wireValue == value,
      orElse: () => throw FormatException('Unknown role_name from backend: $value'),
    );
  }
}

/// The four roles that ever grant Staff Mode capability on mobile (Section
/// 2.3/6). super_admin/operations_admin/finance_* are console-only and
/// deliberately excluded from mobile (Section 6.4) — a session holding
/// only those roles is functionally identical to holding no role at all,
/// as far as this app is concerned.
const staffModeCapableRoles = {
  RoleName.eventManager,
  RoleName.eventCoordinator,
  RoleName.staffLead,
  RoleName.staffMember,
};
