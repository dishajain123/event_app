import 'package:dio/dio.dart';
import 'package:event_app/core/storage/secure_token_storage.dart';
import 'package:event_app/features/auth/application/app_mode_controller.dart';
import 'package:event_app/features/auth/application/auth_state_provider.dart';
import 'package:event_app/features/auth/application/session_roles.dart';
import 'package:event_app/features/auth/data/auth_api.dart';
import 'package:event_app/features/auth/data/auth_repository.dart';
import 'package:event_app/features/auth/data/models/app_user.dart';
import 'package:event_app/features/auth/data/models/role_assignment.dart';
import 'package:event_app/features/notifications/data/notifications_api.dart';
import 'package:event_app/features/notifications/data/notifications_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestSession extends AuthStateNotifier {
  TestSession(Dio dio, AppModeController mode)
      : super(AuthRepository(AuthApi(dio), SecureTokenStorage()), mode,
            NotificationsRepository(NotificationsApi(dio))) {
    state = AuthAuthenticated(user: AppUser.fromJson({
      'id': 'manager', 'mobile_number': null, 'email': 'manager@example.com',
      'is_active': true,
    }), roles: SessionRoles.empty());
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('eligibility alone grants no staff access; revoked scoped roles are excluded', () {
    expect(SessionRoles.empty().hasStaffModeAccess, isFalse);
    final roles = SessionRoles.fromAssignments([
      RoleAssignment.fromJson({'role_name': 'event_manager', 'event_id': 'removed', 'status': 'revoked'}),
      RoleAssignment.fromJson({'role_name': 'event_manager', 'event_id': 'kept', 'status': 'active'}),
    ]);
    expect(roles.staffModeEventIds, ['kept']);
    expect(roles.isEventManagerFor('removed'), isFalse);
  });

  test('refresh removes reassigned events, preserves others and blocks deactivated session', () async {
    SharedPreferences.setMockInitialValues({});
    var eventIds = ['one', 'two'];
    var inactive = false;
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (inactive) {
        handler.reject(DioException(requestOptions: options, type: DioExceptionType.badResponse,
          response: Response(requestOptions: options, statusCode: 401)));
      } else {
        handler.resolve(Response(requestOptions: options, data: eventIds.map((id) => {
          'role_name': 'event_manager', 'event_id': id, 'status': 'active',
        }).toList()));
      }
    }));
    final mode = AppModeController();
    final session = TestSession(dio, mode);
    await session.refreshRoles();
    expect((session.state as AuthAuthenticated).user.mobileNumber, isNull);
    expect((session.state as AuthAuthenticated).roles.staffModeEventIds, ['one', 'two']);
    eventIds = ['two'];
    await session.refreshRoles();
    expect((session.state as AuthAuthenticated).roles.staffModeEventIds, ['two']);
    inactive = true;
    await session.refreshRoles();
    expect(session.state, isA<AuthUnauthenticated>());
    session.dispose();
    mode.dispose();
    dio.close();
  });
}
