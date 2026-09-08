import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/providers/core_providers.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';
import '../data/models/app_user.dart';
import 'app_mode_controller.dart';
import 'session_roles.dart';
import '../../notifications/application/push_token_source.dart';
import '../../notifications/data/notifications_api.dart';
import '../../notifications/data/notifications_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class AuthState {
  const AuthState();
}

/// Initial state, and the state during the one silent-refresh attempt on
/// cold start (Section 8, Phase 1's Splash screen).
class AuthInitializing extends AuthState {
  const AuthInitializing();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  final SessionRoles roles;
  const AuthAuthenticated({required this.user, required this.roles});

  AuthAuthenticated copyWith({AppUser? user, SessionRoles? roles}) {
    return AuthAuthenticated(
        user: user ?? this.user, roles: roles ?? this.roles);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  final tokenStorage = ref.watch(secureTokenStorageProvider);
  return AuthRepository(AuthApi(dio), tokenStorage);
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final AppModeController _appModeController;
  final NotificationsRepository _notificationsRepository;
  final PushTokenSource _pushTokenSource = const PushTokenSource();
  bool _pushInitialized = false;

  AuthStateNotifier(
      this._repository, this._appModeController, this._notificationsRepository)
      : super(const AuthInitializing());

  /// Called once, from the Splash screen, before the router decides which
  /// shell to land the user in (Section 8, Phase 1).
  Future<void> bootstrap() async {
    final hasSession = await _repository.hasStoredSession();
    if (!hasSession) {
      state = const AuthUnauthenticated();
      return;
    }

    try {
      await _loadUserAndRoles();
    } on AppException {
      // Refresh already failed inside the interceptor by the time an
      // AppException reaches here (see AuthInterceptor) — the stored
      // session is no longer valid.
      state = const AuthUnauthenticated();
    }
  }

  Future<int> requestOtp(String mobileNumber) {
    return _repository.requestOtp(mobileNumber);
  }

  Future<void> verifyOtpAndLogIn(
      {required String mobileNumber, required String otp}) async {
    await _repository.verifyOtp(mobileNumber: mobileNumber, otp: otp);
    await _loadUserAndRoles();
  }

  Future<int> signupEmail({required String email, required String password}) {
    return _repository.signupEmail(email: email, password: password);
  }

  Future<void> verifyEmailCodeAndLogIn(
      {required String email, required String code}) async {
    await _repository.verifyEmailCode(email: email, code: code);
    await _loadUserAndRoles();
  }

  Future<void> loginEmail({required String email, required String password}) async {
    await _repository.loginEmail(email: email, password: password);
    await _loadUserAndRoles();
  }

  Future<int> resendEmailVerification(String email) {
    return _repository.resendEmailVerification(email);
  }

  Future<void> resetPassword({required String email, required String code, required String password}) {
    return _repository.resetPassword(email: email, code: code, password: password);
  }

  Future<int> requestPasswordReset(String email) {
    return _repository.requestPasswordReset(email);
  }

  Future<void> _loadUserAndRoles() async {
    final user = await _repository.getMe();
    final assignments = await _repository.getMyRoleAssignments();
    state = AuthAuthenticated(
        user: user, roles: SessionRoles.fromAssignments(assignments));
    await _registerPushDeviceIfAvailable();
  }

  Future<void> _registerPushDeviceIfAvailable() async {
    if (_pushInitialized) return;
    _pushInitialized = true;
    await _pushTokenSource.initializeMessageHandlers(
      onOpened: (data) {
        final deepLink = data['deep_link'];
        if (deepLink is String && deepLink.startsWith('/')) {
          PushTokenSource.pendingDeepLink.value = deepLink;
        }
      },
    );
    final token = await _pushTokenSource.getToken();
    if (token == null) return;
    try {
      final device = await _notificationsRepository.registerDevice(
        token: token,
        platform: const PushTokenSource().platform,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('event_app.notification_device_id', device.id);
      _pushTokenSource.tokenChanges.listen((nextToken) async {
        try {
          final refreshed = await _notificationsRepository.registerDevice(
            token: nextToken,
            platform: _pushTokenSource.platform,
          );
          await prefs.setString(
              'event_app.notification_device_id', refreshed.id);
        } catch (_) {
          // Token refresh retries on the next authenticated startup.
        }
      });
    } catch (_) {
      // Authentication must not fail because push registration is unavailable.
    }
  }

  /// Re-fetches just the role-assignments — called after an action that
  /// could change them (e.g. accepting a staff invitation in Phase 5),
  /// without re-fetching the user profile unnecessarily.
  Future<void> refreshRoles() async {
    final current = state;
    if (current is! AuthAuthenticated) return;
    final assignments = await _repository.getMyRoleAssignments();
    state = current.copyWith(roles: SessionRoles.fromAssignments(assignments));
  }

  /// Updates the cached user in place after a successful profile edit
  /// (Phase 7) — the repository call already persisted the change
  /// server-side; this just keeps every screen reading from
  /// authStateProvider in sync without a full re-fetch.
  Future<void> updateProfile({String? name, String? email}) async {
    final current = state;
    if (current is! AuthAuthenticated) return;
    final updatedUser =
        await _repository.updateProfile(name: name, email: email);
    state = current.copyWith(user: updatedUser);
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('event_app.notification_device_id');
      if (deviceId != null) {
        await _notificationsRepository.removeDevice(deviceId);
      }
      await prefs.remove('event_app.notification_device_id');
    } catch (_) {
      // Device cleanup is best effort; backend tokens expire or are invalidated
      // automatically after provider failures.
    }
    await _repository.logout();
    await _appModeController.reset();
    state = const AuthUnauthenticated();
  }

  /// Called by the network layer's [SessionExpiredNotifier] when a refresh
  /// attempt fails outside of any explicit user action (Section 3.4/3.7's
  /// Unauthorized state) — forces the same clean transition logout() gives,
  /// without re-calling the (already-failed) refresh/logout endpoints.
  Future<void> forceLogoutFromExpiredSession() async {
    await _appModeController.reset();
    state = const AuthUnauthenticated();
  }
}

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final appModeController = ref.watch(appModeProvider.notifier);
  final notifier = AuthStateNotifier(
    repository,
    appModeController,
    NotificationsRepository(NotificationsApi(ref.watch(apiClientProvider))),
  );

  ref.watch(sessionExpiredNotifierProvider).setListener(() {
    notifier.forceLogoutFromExpiredSession();
  });

  return notifier;
});
