import '../data/models/role_assignment.dart';
import '../data/models/role_name.dart';

/// Derived once from the raw [RoleAssignment] list (Section 3.4) and used
/// everywhere a screen or the router needs to answer a role-based question
/// — nothing else in the app re-derives this from the raw list itself.
///
/// This is also, deliberately, THE thing that decides whether the Public
/// Mode ⇄ Staff Mode switch is even shown at all: [hasStaffModeAccess]
/// being false means the switch is absent, not disabled — a plain
/// participant account never sees it. Being true never locks the account
/// INTO Staff Mode either; it only ever adds the switch as an option
/// alongside the ordinary Public Mode experience the account already has
/// by default, and switching back is always available (Section 6.3).
class SessionRoles {
  /// Global (unscoped) roles — event_id was null. In practice, for this
  /// app, these are irrelevant to any screen (Section 6.4: all five global
  /// roles are console-only) but are still tracked faithfully rather than
  /// silently dropped, in case that ever changes.
  final List<RoleName> globalRoles;

  /// event_id -> the set of scoped roles held for that specific event.
  /// One person can hold different scoped roles for different events.
  final Map<String, Set<RoleName>> scopedRolesByEvent;

  const SessionRoles({required this.globalRoles, required this.scopedRolesByEvent});

  factory SessionRoles.fromAssignments(List<RoleAssignment> assignments) {
    final global = <RoleName>[];
    final scoped = <String, Set<RoleName>>{};

    for (final a in assignments) {
      if (!a.isActive) continue;
      if (a.eventId == null) {
        global.add(a.roleName);
      } else {
        scoped.putIfAbsent(a.eventId!, () => {}).add(a.roleName);
      }
    }

    return SessionRoles(globalRoles: global, scopedRolesByEvent: scoped);
  }

  factory SessionRoles.empty() => const SessionRoles(globalRoles: [], scopedRolesByEvent: {});

  /// Every event_id this account holds ANY of the four Staff-Mode-capable
  /// roles for (Section 2.3) — event_manager, event_coordinator,
  /// staff_lead, or staff_member. This is what the mode switch's
  /// visibility is gated on.
  List<String> get staffModeEventIds {
    return scopedRolesByEvent.entries
        .where((entry) => entry.value.any(staffModeCapableRoles.contains))
        .map((entry) => entry.key)
        .toList();
  }

  /// True if there is any reason at all to show the Public Mode ⇄ Staff
  /// Mode switch. False for a plain participant account — the switch is
  /// then entirely absent from the UI, not just disabled (Section 3.3, 6.5).
  bool get hasStaffModeAccess => staffModeEventIds.isNotEmpty;

  /// True specifically for event_manager — the one role with both a
  /// console login and mobile Staff Mode (Section 6.2).
  bool isEventManagerFor(String eventId) {
    return scopedRolesByEvent[eventId]?.contains(RoleName.eventManager) ?? false;
  }

  bool hasScopedRole(String eventId, RoleName role) {
    return scopedRolesByEvent[eventId]?.contains(role) ?? false;
  }

  bool hasAnyStaffRoleFor(String eventId) {
    final roles = scopedRolesByEvent[eventId];
    if (roles == null) return false;
    return roles.any(staffModeCapableRoles.contains);
  }
}
