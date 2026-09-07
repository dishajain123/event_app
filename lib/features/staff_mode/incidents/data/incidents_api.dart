import 'package:dio/dio.dart';
import 'models/incident.dart';

class IncidentsApi {
  final Dio _dio;
  const IncidentsApi(this._dio);

  Future<IncidentPage> list({String? eventId}) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/incidents', queryParameters: {
      if (eventId != null) 'event_id': eventId,
      'page': 1,
      'page_size': 100,
    });
    return IncidentPage.fromJson(response.data!);
  }

  Future<Incident> create(
      {required String eventId,
      required String category,
      required String severity,
      required String title,
      required String description}) async {
    final response = await _dio.post<Map<String, dynamic>>('/incidents', data: {
      'event_id': eventId,
      'category': category,
      'severity': severity,
      'title': title,
      'description': description,
    });
    return Incident.fromJson(response.data!);
  }
}
