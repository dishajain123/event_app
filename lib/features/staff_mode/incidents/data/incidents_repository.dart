import '../../../../../core/network/dio_exception_mapper.dart';
import 'incidents_api.dart';
import 'models/incident.dart';

class IncidentsRepository {
  final IncidentsApi _api;
  const IncidentsRepository(this._api);

  Future<IncidentPage> list({String? eventId}) async {
    try {
      return await _api.list(eventId: eventId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<Incident> create(
      {required String eventId,
      required String category,
      required String severity,
      required String title,
      required String description}) async {
    try {
      return await _api.create(
          eventId: eventId,
          category: category,
          severity: severity,
          title: title,
          description: description);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
