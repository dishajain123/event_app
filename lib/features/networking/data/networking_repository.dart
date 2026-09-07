import '../../../../core/network/dio_exception_mapper.dart';
import 'models/networking.dart';
import 'networking_api.dart';

class NetworkingRepository {
  final NetworkingApi api;
  const NetworkingRepository(this.api);
  Future<NetworkingProfile> profile(String id) async {
    try {
      return await api.profile(id);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<NetworkingProfile> update(String id, Map<String, dynamic> data) async {
    try {
      return await api.update(id, data);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<NetworkingParticipantPage> discover(String id,
      {int page = 1, String? search}) async {
    try {
      return await api.discover(id, page: page, search: search);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> dismiss(String eventId, String participantId) async {
    try {
      await api.dismiss(eventId, participantId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<NetworkingActivityPage> activities(String eventId) async {
    try {
      return await api.activities(eventId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> connect(String eventId, String participantId) async {
    try {
      await api.connect(eventId, participantId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> report(
      String eventId, String participantId, String reason) async {
    try {
      await api.report(eventId, participantId, reason);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<NetworkingConnection>> connections(String id) async {
    try {
      return await api.connections(id);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> connectionStatus(String id, String status) async {
    try {
      await api.connectionStatus(id, status);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> unblock(String eventId, String participantId) async {
    try {
      await api.unblock(eventId, participantId);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
