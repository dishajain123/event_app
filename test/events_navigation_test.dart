import 'package:dio/dio.dart';
import 'package:event_app/app/router/app_router.dart';
import 'package:event_app/app/router/route_paths.dart';
import 'package:event_app/core/storage/secure_token_storage.dart';
import 'package:event_app/features/auth/application/app_mode_controller.dart';
import 'package:event_app/features/auth/application/auth_state_provider.dart';
import 'package:event_app/features/auth/application/session_roles.dart';
import 'package:event_app/features/auth/data/auth_api.dart';
import 'package:event_app/features/auth/data/auth_repository.dart';
import 'package:event_app/features/auth/data/models/app_user.dart';
import 'package:event_app/features/auth/presentation/screens/mobile_number_screen.dart';
import 'package:event_app/features/event_categories/application/event_categories_providers.dart';
import 'package:event_app/features/events/application/events_providers.dart';
import 'package:event_app/features/events/presentation/screens/events_screen.dart';
import 'package:event_app/features/notifications/data/notifications_api.dart';
import 'package:event_app/features/notifications/data/notifications_repository.dart';
import 'package:event_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestAuth extends AuthStateNotifier {
  _TestAuth(AuthState initial, AppModeController mode, Dio dio)
      : super(AuthRepository(AuthApi(dio), SecureTokenStorage()), mode,
            NotificationsRepository(NotificationsApi(dio))) {
    state = initial;
  }

  @override
  Future<void> bootstrap() async {}
}

void main() {
  for (final signedIn in [false, true]) {
    testWidgets('Events tab needs no profile (signed in: $signedIn)',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final dio = Dio();
      final container = ProviderContainer(overrides: [
        authStateProvider.overrideWith((ref) => _TestAuth(
              signedIn
                  ? AuthAuthenticated(
                      user: const AppUser(
                        id: 'user-without-profile',
                        mobileNumber: '9999999999',
                        name: null,
                        email: null,
                        emailVerifiedAt: null,
                        isActive: true,
                      ),
                      roles: SessionRoles.empty(),
                    )
                  : const AuthUnauthenticated(),
              ref.read(appModeProvider.notifier),
              dio,
            )),
        mainCategoriesProvider.overrideWith((ref) async => []),
        eventsListProvider(noEventsFilter).overrideWith((ref) async => []),
      ]);
      final router = container.read(goRouterProvider);
      try {
        router.go(RoutePaths.home);
        await tester.pumpWidget(UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Events'));
        await tester.pumpAndSettle();

        expect(router.routeInformationProvider.value.uri.path, RoutePaths.events);
        expect(find.byType(EventsScreen), findsOneWidget);
        expect(find.byType(MobileNumberScreen), findsNothing);
        expect(find.byType(EditProfileScreen), findsNothing);
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
        container.dispose();
        dio.close();
      }
    });
  }
}
