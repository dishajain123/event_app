import 'package:event_app/app/router/guest_routes.dart';
import 'package:event_app/app/router/route_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guests can browse all events, categories, search and event details',
      () {
    for (final path in [
      RoutePaths.home,
      RoutePaths.events,
      RoutePaths.search,
      RoutePaths.mainCategoryPath('category-1'),
      RoutePaths.categoryEventsPath('category-1'),
      RoutePaths.categoryEventsPath('category-1', subCategoryId: 'sub-1'),
      RoutePaths.eventDetailPath('event-1'),
      RoutePaths.mediaGalleryPath('event-1'),
    ]) {
      expect(isGuestAccessibleRoute(path), isTrue, reason: path);
    }
  });

  test('enrollment and personal routes require authentication', () {
    for (final path in [
      RoutePaths.participationTypeSelectorPath('event-1'),
      RoutePaths.registrationFormPath('event-1', 'individual'),
      RoutePaths.createTeamPath('event-1'),
      RoutePaths.waitlistJoinPath('event-1'),
      RoutePaths.volunteerApplyPath('event-1'),
      RoutePaths.myRegistrations,
      RoutePaths.myTickets,
      RoutePaths.profile,
      RoutePaths.eventFeedbackPath('event-1'),
      RoutePaths.eventNetworkingPath('event-1'),
      RoutePaths.staffScan,
      '/events/event-1/unknown-action',
    ]) {
      expect(isGuestAccessibleRoute(path), isFalse, reason: path);
    }
  });
}
