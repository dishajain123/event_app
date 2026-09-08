import 'package:dio/dio.dart';
import 'models/app_user.dart';
import 'models/role_assignment.dart';
import 'models/token_pair.dart';

/// One method per endpoint, typed request/response, nothing decided here —
/// mirrors `app/modules/identity/router.py` and `app/modules/rbac/router.py`
/// exactly. Never called directly from a screen; only AuthRepository calls
/// this (Section 3.5).
class AuthApi {
  final Dio _dio;
  const AuthApi(this._dio);

  Future<OtpRequestResult> requestOtp(String mobileNumber) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/otp/request',
      data: {'mobile_number': mobileNumber},
    );
    return OtpRequestResult.fromJson(response.data!);
  }

  Future<TokenPair> verifyOtp(
      {required String mobileNumber, required String otp}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/otp/verify',
      data: {'mobile_number': mobileNumber, 'otp': otp},
    );
    return TokenPair.fromJson(response.data!);
  }

  Future<void> logout() async {
    await _dio.post<void>('/auth/logout');
  }

  Future<AppUser> getMe() async {
    final response = await _dio.get<Map<String, dynamic>>('/users/me');
    return AppUser.fromJson(response.data!);
  }

  Future<List<RoleAssignment>> getMyRoleAssignments() async {
    final response =
        await _dio.get<List<dynamic>>('/users/me/role-assignments');
    return response.data!
        .map((item) => RoleAssignment.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Mirrors the new PATCH /users/me (Phase 7's fix — there was
  /// previously no way at all to change your own name or email).
  Future<AppUser> updateProfile({String? name, String? email}) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/users/me',
      data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
      },
    );
    return AppUser.fromJson(response.data!);
  }
}
