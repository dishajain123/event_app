import '../../../core/network/app_exception.dart';
import '../../../core/network/dio_exception_mapper.dart';
import '../../../core/storage/secure_token_storage.dart';
import 'auth_api.dart';
import 'models/app_user.dart';
import 'models/role_assignment.dart';
import 'models/token_pair.dart';

/// The layer Riverpod providers actually depend on (Section 3.5) — turns
/// [AuthApi]'s raw calls into results the app's state layer wants, maps
/// every failure into [AppException], and is the only place that
/// coordinates "a successful verify means tokens get persisted."
class AuthRepository {
  final AuthApi _api;
  final SecureTokenStorage _tokenStorage;

  const AuthRepository(this._api, this._tokenStorage);

  Future<int> requestOtp(String mobileNumber) async {
    try {
      final result = await _api.requestOtp(mobileNumber);
      return result.resendAvailableInSeconds;
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<int> signupEmail({required String email, required String password}) async {
    try {
      final result = await _api.signupEmail(email: email, password: password);
      return result.resendAvailableInSeconds;
    } catch (e) {
      throw mapDioException(e);
    }
  }

  /// Verifies the OTP, persists the resulting token pair, and returns the
  /// access token — the caller (AuthStateNotifier) is responsible for the
  /// subsequent role-assignments bootstrap, not this method, so this stays
  /// a single-purpose call matching a single backend endpoint.
  Future<String> verifyOtp(
      {required String mobileNumber, required String otp}) async {
    try {
      final TokenPair tokens =
          await _api.verifyOtp(mobileNumber: mobileNumber, otp: otp);
      await _tokenStorage.saveTokens(
          accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
      return tokens.accessToken;
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<String> verifyEmailCode({required String email, required String code}) async {
    try {
      final tokens = await _api.verifyEmailCode(email: email, code: code);
      await _tokenStorage.saveTokens(
          accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
      return tokens.accessToken;
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<String> loginEmail({required String email, required String password}) async {
    try {
      final tokens = await _api.loginEmail(email: email, password: password);
      await _tokenStorage.saveTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
      return tokens.accessToken;
    } catch (e) { throw mapDioException(e); }
  }

  Future<int> resendEmailVerification(String email) async {
    try { return (await _api.resendEmailVerification(email)).resendAvailableInSeconds; }
    catch (e) { throw mapDioException(e); }
  }

  Future<void> resetPassword({required String email, required String code, required String password}) async {
    try { await _api.resetPassword(email: email, code: code, password: password); }
    catch (e) { throw mapDioException(e); }
  }

  Future<int> requestPasswordReset(String email) async {
    try { return (await _api.requestPasswordReset(email)).resendAvailableInSeconds; }
    catch (e) { throw mapDioException(e); }
  }

  Future<AppUser> getMe() async {
    try {
      return await _api.getMe();
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<RoleAssignment>> getMyRoleAssignments() async {
    try {
      return await _api.getMyRoleAssignments();
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AppUser> updateProfile({String? name, String? email}) async {
    try {
      return await _api.updateProfile(name: name, email: email);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<bool> hasStoredSession() => _tokenStorage.hasStoredSession();

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    final accessToken = await _tokenStorage.getAccessToken();
    try {
      await _api.logout(refreshToken: refreshToken, accessToken: accessToken);
    } catch (_) {
      // Best-effort — /auth/logout is a no-op placeholder on the backend
      // today (Section 2.4/3.4). The local session is what actually
      // matters and must be cleared regardless of whether this call
      // succeeds, so a failure here is never allowed to block logout.
    } finally {
      await _tokenStorage.clear();
    }
  }
}
