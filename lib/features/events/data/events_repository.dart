import '../../../core/network/dio_exception_mapper.dart';
import 'events_api.dart';
import 'models/app_event.dart';
import 'models/venue_schedule_sponsor.dart';

class EventsRepository {
  final EventsApi _api;
  const EventsRepository(this._api);

  Future<List<AppEvent>> listEvents(
      {String? mainCategoryId, String? subCategoryId}) async {
    try {
      return await _api.listEvents(
          mainCategoryId: mainCategoryId, subCategoryId: subCategoryId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AppEvent> getEvent(String eventId) async {
    try {
      return await _api.getEvent(eventId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<Venue>> listVenues(String eventId) async {
    try {
      return await _api.listVenues(eventId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<ScheduleItem>> getSchedule(String eventId) async {
    try {
      return await _api.getSchedule(eventId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<Sponsor>> listSponsors(String eventId) async {
    try {
      return await _api.listSponsors(eventId);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
