import '../../../core/network/dio_exception_mapper.dart';
import 'media_api.dart';
import 'models/event_media.dart';

class MediaRepository {
  final MediaApi _api;
  const MediaRepository(this._api);

  Future<List<EventMedia>> listEventMedia(String eventId) async {
    try {
      return await _api.listEventMedia(eventId);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
