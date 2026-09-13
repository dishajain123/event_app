import 'package:dio/dio.dart';
import 'package:event_app/core/storage/secure_token_storage.dart';
import 'package:event_app/features/auth/application/app_mode_controller.dart';
import 'package:event_app/features/auth/application/auth_state_provider.dart';
import 'package:event_app/features/auth/application/session_roles.dart';
import 'package:event_app/features/auth/data/auth_api.dart';
import 'package:event_app/features/auth/data/auth_repository.dart';
import 'package:event_app/features/auth/data/models/app_user.dart';
import 'package:event_app/features/auth/data/models/role_name.dart';
import 'package:event_app/features/notifications/data/notifications_api.dart';
import 'package:event_app/features/notifications/data/notifications_repository.dart';
import 'package:event_app/features/staff_mode/assignments/presentation/screens/my_staff_events_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:event_app/core/providers/core_providers.dart';

class _TestAuth extends AuthStateNotifier {
  _TestAuth(AuthState initial, AppModeController mode, Dio dio)
      : super(AuthRepository(AuthApi(dio), SecureTokenStorage()), mode,
            NotificationsRepository(NotificationsApi(dio))) {
    state = initial;
  }

  @override
  Future<void> bootstrap() async {}

  @override
  Future<void> refreshRoles() async {}
}

void main() {
  testWidgets(
      'My Events shows real event name/date and splits upcoming vs past',
      (tester) async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.resolve(Response(requestOptions: options, data: [
        {
          'id': 'a-upcoming',
          'event_id': 'evt-1',
          'venue_id': null,
          'user_id': 'me',
          'invitee_mobile': '+919700000003',
          'full_name': 'Neel Verma',
          'role_name': 'staff_member',
          'role_label': 'Gate Marshal',
          'status': 'active',
          'invited_by': 'ops',
          'accepted_by': 'me',
          'revoked_by': null,
          'accepted_at': null,
          'revoked_at': null,
          'superseded_by_id': null,
          'linked_role_assignment_id': null,
          'created_at': '2026-01-01T00:00:00Z',
          'updated_at': '2026-01-01T00:00:00Z',
          'event_name': 'GO-360° LIVE',
          'event_start_date':
              DateTime.now().add(const Duration(days: 10)).toIso8601String(),
          'event_end_date':
              DateTime.now().add(const Duration(days: 11)).toIso8601String(),
          'venue_name': 'Main Grounds',
        },
        {
          'id': 'a-past',
          'event_id': 'evt-2',
          'venue_id': null,
          'user_id': 'me',
          'invitee_mobile': '+919700000003',
          'full_name': 'Neel Verma',
          'role_name': 'staff_member',
          'role_label': 'Registration Desk',
          'status': 'active',
          'invited_by': 'ops',
          'accepted_by': 'me',
          'revoked_by': null,
          'accepted_at': null,
          'revoked_at': null,
          'superseded_by_id': null,
          'linked_role_assignment_id': null,
          'created_at': '2025-01-01T00:00:00Z',
          'updated_at': '2025-01-01T00:00:00Z',
          'event_name': 'Old Fest 2025',
          'event_start_date':
              DateTime.now().subtract(const Duration(days: 40)).toIso8601String(),
          'event_end_date':
              DateTime.now().subtract(const Duration(days: 39)).toIso8601String(),
          'venue_name': null,
        },
      ]));
    }));

    final container = ProviderContainer(overrides: [
      apiClientProvider.overrideWithValue(dio),
      authStateProvider.overrideWith((ref) => _TestAuth(
            const AuthAuthenticated(
              user: AppUser(
                  id: 'me',
                  mobileNumber: '+919700000003',
                  name: 'Neel Verma',
                  email: null,
                  emailVerifiedAt: null,
                  isActive: true),
              roles: SessionRoles(globalRoles: [], scopedRolesByEvent: {
                'evt-1': {RoleName.staffMember},
                'evt-2': {RoleName.staffMember},
              }),
            ),
            ref.read(appModeProvider.notifier),
            dio,
          )),
    ]);
    addTearDown(container.dispose);
    addTearDown(dio.close);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: MyStaffEventsScreen()),
    ));
    await tester.pumpAndSettle();

    // Regression: previously only role_label was shown — no event
    // identity or date/venue at all.
    expect(find.text('GO-360° LIVE'), findsOneWidget);
    expect(find.text('Old Fest 2025'), findsOneWidget);
    expect(find.text('Main Grounds'), findsOneWidget);

    // Regression: an "active" assignment for an event that already ended
    // must land under "Past events", not stay under "Upcoming" forever.
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Past events'), findsOneWidget);

    final upcomingY = tester.getTopLeft(find.text('Upcoming')).dy;
    final pastY = tester.getTopLeft(find.text('Past events')).dy;
    final liveEventY = tester.getTopLeft(find.text('GO-360° LIVE')).dy;
    final oldFestY = tester.getTopLeft(find.text('Old Fest 2025')).dy;
    expect(liveEventY, greaterThan(upcomingY));
    expect(liveEventY, lessThan(pastY));
    expect(oldFestY, greaterThan(pastY));
  });
}
