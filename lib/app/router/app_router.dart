import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/app_mode_controller.dart';
import '../../features/auth/application/auth_state_provider.dart';
import '../../features/auth/application/session_roles.dart';
import '../../features/auth/presentation/screens/mobile_number_screen.dart';
import '../../features/auth/presentation/screens/otp_verify_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../shells/public_mode_shell.dart';
import '../shells/staff_mode_shell.dart';
import 'route_paths.dart';
import 'router_refresh_notifier.dart';

// Phase 1 placeholder screens — real screens land in Phases 2–7 per the
// approved plan. Each is intentionally minimal: it exists so every route
// in RoutePaths resolves to something real and navigable today, proving
// the shell/switch/redirect machinery works end-to-end before any real
// feature is built on top of it.
import '../../features/events/presentation/screens/home_screen.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';
import '../../features/events/presentation/screens/search_screen.dart';
import '../../features/registrations/presentation/screens/my_registrations_screen.dart';
import '../../features/registrations/presentation/screens/registration_detail_screen.dart';
import '../../features/registrations/presentation/screens/participation_type_selector_screen.dart';
import '../../features/registrations/presentation/screens/registration_form_screen.dart';
import '../../features/teams/presentation/screens/create_team_screen.dart';
import '../../features/teams/presentation/screens/team_roster_screen.dart';
import '../../features/guardians/presentation/screens/my_children_screen.dart';
import '../../features/guardians/presentation/screens/add_child_screen.dart';
import '../../features/payments/presentation/screens/payment_checkout_screen.dart';
import '../../features/notifications/presentation/screens/notifications_inbox_screen.dart';
import '../../features/assistance/presentation/screens/my_assistance_requests_screen.dart';
import '../../features/assistance/presentation/screens/request_assistance_screen.dart';
import '../../features/referrals/presentation/screens/my_referral_screen.dart';
import '../../features/media/presentation/screens/media_gallery_screen.dart';
import '../../features/staff_mode/funnels/presentation/screens/competition_stages_screen.dart';
import '../../features/staff_mode/funnels/presentation/screens/voting_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/identity_documents_screen.dart';
import '../../features/profile/presentation/screens/app_settings_screen.dart';
import '../../features/tickets/presentation/screens/my_tickets_screen.dart';
import '../../features/tickets/presentation/screens/ticket_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/staff_mode/check_in/presentation/screens/qr_scanner_screen.dart';
import '../../features/staff_mode/registration_review/presentation/screens/registration_review_screen.dart';
import '../../features/staff_mode/assignments/presentation/screens/my_staff_events_screen.dart';
import '../../features/staff_mode/assignments/presentation/screens/staff_profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = RouterRefreshNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.mobileNumber,
        builder: (context, state) => const MobileNumberScreen(),
      ),
      GoRoute(
        path: RoutePaths.otpVerify,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OtpVerifyScreen(
            mobileNumber: extra?['mobileNumber'] as String? ?? '',
            initialResendSeconds: extra?['resendSeconds'] as int? ?? 30,
          );
        },
      ),

      // Public Mode shell (Section 3.3) — reachable by every authenticated
      // account, always, regardless of role.
      ShellRoute(
        builder: (context, state, child) => PublicModeShell(child: child),
        routes: [
          GoRoute(path: RoutePaths.home, builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: RoutePaths.myRegistrations,
            builder: (context, state) => const MyRegistrationsScreen(),
          ),
          GoRoute(path: RoutePaths.myTickets, builder: (context, state) => const MyTicketsScreen()),
          GoRoute(path: RoutePaths.profile, builder: (context, state) => const ProfileScreen()),
        ],
      ),

      // Event Detail and Search are full-screen pushes OVER the Public
      // Mode shell (Section 8, Phase 2) — deliberately top-level routes on
      // the root navigator rather than nested inside the ShellRoute above,
      // so they cover the bottom nav rather than appearing as a tab.
      GoRoute(
        path: RoutePaths.eventDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return EventDetailScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: RoutePaths.search,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SearchScreen(
            initialMainCategoryId: extra?['mainCategoryId'] as String?,
            initialMainCategoryName: extra?['mainCategoryName'] as String?,
          );
        },
      ),

      // Phase 3 — Registration Engine. All full-screen pushes over
      // whichever shell is active, on the root navigator.
      GoRoute(
        path: RoutePaths.participationTypeSelector,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            ParticipationTypeSelectorScreen(eventId: state.pathParameters['eventId']!),
      ),
      GoRoute(
        path: RoutePaths.registrationForm,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => RegistrationFormScreen(
          eventId: state.pathParameters['eventId']!,
          participationType: state.pathParameters['participationType']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.registrationDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            RegistrationDetailScreen(registrationId: state.pathParameters['registrationId']!),
      ),
      GoRoute(
        path: RoutePaths.createTeam,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CreateTeamScreen(eventId: state.pathParameters['eventId']!),
      ),
      GoRoute(
        path: RoutePaths.teamRoster,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => TeamRosterScreen(teamId: state.pathParameters['teamId']!),
      ),
      GoRoute(
        path: RoutePaths.myChildren,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MyChildrenScreen(),
      ),
      GoRoute(
        path: RoutePaths.addChild,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddChildScreen(),
      ),

      // Phase 4 — Payments & Tickets.
      GoRoute(
        path: RoutePaths.paymentCheckout,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            PaymentCheckoutScreen(registrationId: state.pathParameters['registrationId']!),
      ),
      GoRoute(
        path: RoutePaths.ticketDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => TicketDetailScreen(ticketId: state.pathParameters['ticketId']!),
      ),

      // Phase 6 — Staff Mode Extended, Growth & Engagement.
      GoRoute(
        path: RoutePaths.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsInboxScreen(),
      ),
      GoRoute(
        path: RoutePaths.assistanceRequests,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MyAssistanceRequestsScreen(),
      ),
      GoRoute(
        path: RoutePaths.requestAssistance,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => RequestAssistanceScreen(
          eventId: state.pathParameters['eventId']!,
          registrationId: state.pathParameters['registrationId']!,
        ),
      ),
      GoRoute(
        path: RoutePaths.referral,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => MyReferralScreen(eventId: state.pathParameters['eventId']!),
      ),
      GoRoute(
        path: RoutePaths.mediaGallery,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => MediaGalleryScreen(eventId: state.pathParameters['eventId']!),
      ),
      GoRoute(
        path: RoutePaths.competitionStages,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CompetitionStagesScreen(eventId: state.pathParameters['eventId']!),
      ),
      GoRoute(
        path: RoutePaths.voting,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => VotingScreen(stageId: state.pathParameters['stageId']!),
      ),

      // Phase 7 — Profile, Settings & Polish.
      GoRoute(
        path: RoutePaths.editProfile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.identityDocuments,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const IdentityDocumentsScreen(),
      ),
      GoRoute(
        path: RoutePaths.appSettings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AppSettingsScreen(),
      ),

      // Staff Mode shell (Section 3.3, 6.5) — only ever reachable for an
      // account holding at least one of the four Staff-Mode-capable roles;
      // the redirect below is what actually enforces that, not the routes
      // themselves.
      ShellRoute(
        builder: (context, state, child) => StaffModeShell(child: child),
        routes: [
          GoRoute(path: RoutePaths.staffScan, builder: (context, state) => const QrScannerScreen()),
          GoRoute(path: RoutePaths.staffTasks, builder: (context, state) => const RegistrationReviewScreen()),
          GoRoute(
            path: RoutePaths.staffMyEvents,
            builder: (context, state) => const MyStaffEventsScreen(),
          ),
          GoRoute(path: RoutePaths.staffProfile, builder: (context, state) => const StaffProfileScreen()),
        ],
      ),
    ],
  );
});

String? _redirect(Ref ref, GoRouterState state) {
  final authState = ref.read(authStateProvider);
  final location = state.matchedLocation;

  final isAuthRoute = location == RoutePaths.mobileNumber ||
      location == RoutePaths.otpVerify ||
      location == RoutePaths.splash;

  // Bootstrap still in flight — stay put on splash; nothing else has
  // enough information yet to decide where to go.
  if (authState is AuthInitializing) {
    return location == RoutePaths.splash ? null : RoutePaths.splash;
  }

  if (authState is AuthUnauthenticated) {
    return isAuthRoute ? null : RoutePaths.mobileNumber;
  }

  // Authenticated from here on (AuthState is sealed: Initializing |
  // Unauthenticated | Authenticated — the two above are handled, so this
  // is the only remaining case).
  final authenticated = authState as AuthAuthenticated;

  if (isAuthRoute) {
    // Always land in Public Mode first, regardless of role — an account
    // with Staff Mode access is never dropped straight into Staff Mode
    // without an explicit switch (this was confirmed explicitly before
    // this phase was built; see AppModeController's doc comment).
    return RoutePaths.home;
  }

  final SessionRoles roles = authenticated.roles;
  final appMode = ref.read(appModeProvider);
  final isStaffRoute = location.startsWith('/staff');

  if (isStaffRoute) {
    // Defensive: a Staff Mode route is never reachable for an account
    // with no scoped role at all, no matter how this location was
    // reached (the switch itself is already hidden for such an account —
    // Section 3.3/6.5 — so this should be unreachable in normal use, but
    // the guard holds regardless).
    if (!roles.hasStaffModeAccess) return RoutePaths.home;

    // The mode was switched back to Public elsewhere (e.g. another part
    // of the UI) — don't strand the user on a Staff Mode screen.
    if (appMode != AppMode.staff) return RoutePaths.home;
  } else if (appMode == AppMode.staff && roles.hasStaffModeAccess) {
    // The user is in Staff Mode but landed on a Public Mode path (e.g. a
    // deep link) — send them to the Staff Mode landing instead of
    // showing a Public Mode screen while the switch itself still reads
    // "Staff Mode".
    return RoutePaths.staffScan;
  }

  return null;
}
