import 'package:dio/dio.dart';
import 'models/networking.dart';

class NetworkingApi {
  final Dio dio;
  const NetworkingApi(this.dio);
  Future<NetworkingProfile> profile(String eventId) async =>
      NetworkingProfile.fromJson((await dio
              .get<Map<String, dynamic>>('/networking/events/$eventId/profile'))
          .data!);
  Future<NetworkingProfile> update(
          String eventId, Map<String, dynamic> data) async =>
      NetworkingProfile.fromJson((await dio.put<Map<String, dynamic>>(
              '/networking/events/$eventId/profile',
              data: data))
          .data!);
  Future<NetworkingParticipantPage> discover(String eventId,
      {int page = 1, String? search}) async {
    final data = (await dio.get<Map<String, dynamic>>(
            '/networking/events/$eventId/participants',
            queryParameters: {
          'page': page,
          'page_size': 25,
          'recommended': true,
          if (search != null && search.isNotEmpty) 'search': search
        }))
        .data!;
    return NetworkingParticipantPage.fromJson(data);
  }

  Future<void> dismiss(String eventId, String participantId) => dio
      .post('/networking/events/$eventId/participants/$participantId/dismiss');

  Future<NetworkingActivityPage> activities(String eventId) async {
    final data = (await dio.get<Map<String, dynamic>>(
            '/networking/events/$eventId/activities',
            queryParameters: {'page': 1, 'page_size': 25}))
        .data!;
    return NetworkingActivityPage.fromJson(data);
  }

  Future<void> connect(String eventId, String participantId) =>
      dio.post('/networking/events/$eventId/connections',
          data: {'participant_id': participantId, 'intent': 'connect'});
  Future<void> report(String eventId, String participantId, String reason) =>
      dio.post('/networking/events/$eventId/reports',
          data: {'reported_user_id': participantId, 'reason': reason});
  Future<List<NetworkingConnection>> connections(String eventId) async {
    final data = (await dio.get<Map<String, dynamic>>(
            '/networking/events/$eventId/connections',
            queryParameters: {'page': 1, 'page_size': 25}))
        .data!;
    return ((data['items'] as List<dynamic>?) ?? [])
        .map((e) => NetworkingConnection.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> connectionStatus(String id, String status) =>
      dio.post('/networking/connections/$id/status', data: {'status': status});

  Future<void> unblock(String eventId, String participantId) => dio.post(
        '/networking/events/$eventId/participants/$participantId/unblock',
      );
}
