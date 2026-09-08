import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/events_api.dart';
import '../data/events_repository.dart';
import '../data/models/app_event.dart';
import '../data/models/venue_schedule_sponsor.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return EventsRepository(EventsApi(dio));
});

/// A Dart 3 record as the family key — structurally equatable by value
/// out of the box, so `EventsQuery(mainCategoryId: 'x')` called from two
/// different widgets hits the same cached provider entry without any
/// manual `==`/`hashCode` implementation.
typedef EventsQuery = ({String? mainCategoryId, String? subCategoryId});

const noEventsFilter = (mainCategoryId: null, subCategoryId: null);

final eventsListProvider =
    FutureProvider.family<List<AppEvent>, EventsQuery>((ref, query) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.listEvents(
      mainCategoryId: query.mainCategoryId, subCategoryId: query.subCategoryId);
});

final eventDetailProvider =
    FutureProvider.family<AppEvent, String>((ref, eventId) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.getEvent(eventId);
});

final eventVenuesProvider =
    FutureProvider.family<List<Venue>, String>((ref, eventId) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.listVenues(eventId);
});

final eventScheduleProvider =
    FutureProvider.family<List<ScheduleItem>, String>((ref, eventId) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.getSchedule(eventId);
});

final eventSponsorsProvider =
    FutureProvider.family<List<Sponsor>, String>((ref, eventId) async {
  final repository = ref.watch(eventsRepositoryProvider);
  return repository.listSponsors(eventId);
});
