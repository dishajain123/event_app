import 'route_paths.dart';

/// Discovery is public; enrollment and personal account routes require login.
bool isGuestAccessibleRoute(String location) {
  if (location == RoutePaths.home ||
      location == RoutePaths.events ||
      location == RoutePaths.search ||
      location == RoutePaths.sponsorship ||
      location == RoutePaths.volunteers) {
    return true;
  }

  final segments = Uri.parse(location).pathSegments;
  if (segments.firstOrNull == 'categories' &&
      (segments.length == 2 ||
          (segments.length == 3 && segments.last == 'events'))) {
    return true;
  }
  if (segments.length == 2 && segments.first == 'events') return true;
  return segments.length == 3 &&
      segments.first == 'events' &&
      const {'gallery', 'competition', 'interactions'}.contains(segments.last);
}
