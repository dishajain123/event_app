import 'package:dio/dio.dart';
import 'models/app_event.dart';
import 'models/venue_schedule_sponsor.dart';

/// Mirrors `app/modules/events/router.py`'s read endpoints — mobile only
/// ever reads events; every write endpoint (create/update/publish/status/
/// venues/schedule/sponsors POST) is a console-only Operations Admin/
/// Event Manager action (Section 9.11).
class EventsApi {
  final Dio _dio;
  const EventsApi(this._dio);

  /// The backend scopes this automatically by caller identity — a mobile
  /// (non-console-admin) caller only ever receives published-or-later
  /// events, never drafts (Section 9.3's docstring, verified against the
  /// live router). No client-side status filtering is needed or done here.
  Future<List<AppEvent>> listEvents({String? mainCategoryId, String? subCategoryId}) async {
    final response = await _dio.get<List<dynamic>>(
      '/events',
      queryParameters: {
        if (mainCategoryId != null) 'main_category_id': mainCategoryId,
        if (subCategoryId != null) 'sub_category_id': subCategoryId,
      },
    );
    return response.data!.map((item) => AppEvent.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<AppEvent> getEvent(String eventId) async {
    final response = await _dio.get<Map<String, dynamic>>('/events/$eventId');
    return AppEvent.fromJson(response.data!);
  }

  Future<List<Venue>> listVenues(String eventId) async {
    final response = await _dio.get<List<dynamic>>('/events/$eventId/venues');
    return response.data!.map((item) => Venue.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<ScheduleItem>> getSchedule(String eventId) async {
    final response = await _dio.get<List<dynamic>>('/events/$eventId/schedule');
    return response.data!.map((item) => ScheduleItem.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Sponsor>> listSponsors(String eventId) async {
    final response = await _dio.get<List<dynamic>>('/events/$eventId/sponsors');
    return response.data!.map((item) => Sponsor.fromJson(item as Map<String, dynamic>)).toList();
  }
}
