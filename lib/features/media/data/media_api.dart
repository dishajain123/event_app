import 'package:dio/dio.dart';
import 'models/event_media.dart';

/// Mirrors `app/modules/media/router.py`'s GET endpoint. Mobile never
/// uploads or publishes media (Section 9.11 — those are console-only
/// staff actions); this is deliberately read-only.
class MediaApi {
  final Dio _dio;
  const MediaApi(this._dio);

  Future<List<EventMedia>> listEventMedia(String eventId) async {
    final response = await _dio.get<List<dynamic>>('/events/$eventId/media');
    return response.data!
        .map((item) => EventMedia.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
