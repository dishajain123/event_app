import 'role_name.dart';

/// Mirrors `app/modules/rbac/schemas.py`'s `MyRoleAssignmentOut` exactly.
/// This is the single source of truth this entire app derives every
/// role-based decision from (Section 3.4, 6.5) — fetched once at login
/// (and again on cold start) from GET /users/me/role-assignments.
class RoleAssignment {
  final RoleName roleName;

  /// Null for a global role (super_admin, operations_admin, finance_*);
  /// set for a scoped role (event_manager, event_coordinator, staff_lead,
  /// staff_member) — the event this assignment applies to.
  final String? eventId;

  final String status;

  const RoleAssignment({
    required this.roleName,
    required this.eventId,
    required this.status,
  });

  factory RoleAssignment.fromJson(Map<String, dynamic> json) {
    return RoleAssignment(
      roleName: RoleName.fromWire(json['role_name'] as String),
      eventId: json['event_id'] as String?,
      status: json['status'] as String,
    );
  }

  bool get isActive => status == 'active';
}
