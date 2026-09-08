import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The two shells the app can be in (Section 3.3). Nothing about this enum
/// implies exclusivity of access — see [AppModeController]'s doc comment.
enum AppMode { public, staff }

const _appModePrefsKey = 'event_app.selected_app_mode';

/// The actual switch mechanism. A handful of things are true about it by
/// design, restated here because they were the specific point raised
/// before this phase was built:
///
/// 1. Any account holding at least one Staff-Mode-capable role (Section
///    2.3) sees a switch at all — the switch is a UI element, not a
///    permission grant; the backend enforces every real action regardless.
/// 2. A plain participant account (no scoped role) never sees a switch —
///    there's nothing to switch to, so nothing is offered.
/// 3. Switching is never one-way. An Event Manager, Event Coordinator,
///    Staff Lead, or Staff Member can freely use the app as an ordinary
///    participant — browse events, register for something themselves, buy
///    a ticket — and switch back to Staff Mode whenever they choose.
///    Nothing in this controller ever locks a scoped-role account into
///    Staff Mode permanently.
/// 4. The selection persists across an app restart (SharedPreferences —
///    this is a UI preference, never a credential, so it deliberately
///    does NOT live in secure storage) but is always changeable again from
///    the switch itself.
class AppModeController extends StateNotifier<AppMode> {
  AppModeController() : super(AppMode.public) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_appModePrefsKey);
    if (stored == 'staff') {
      state = AppMode.staff;
    }
  }

  Future<void> switchTo(AppMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _appModePrefsKey, mode == AppMode.staff ? 'staff' : 'public');
  }

  Future<void> switchToPublicMode() => switchTo(AppMode.public);
  Future<void> switchToStaffMode() => switchTo(AppMode.staff);

  /// Called on logout — the next account to log in on this device should
  /// never inherit the previous account's mode selection.
  Future<void> reset() async {
    state = AppMode.public;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_appModePrefsKey);
  }
}

final appModeProvider =
    StateNotifierProvider<AppModeController, AppMode>((ref) {
  return AppModeController();
});
