import 'package:dio/dio.dart';
import 'models/waitlist_entry.dart';

class WaitlistsApi {
  final Dio _dio;
  const WaitlistsApi(this._dio);

  Future<WaitlistEntry> join(
      {required String eventId,
      required String participationType,
      String? childId,
      String? teamId}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/waitlists',
      queryParameters: {'event_id': eventId},
      data: {
        'participation_type': participationType,
        if (childId != null) 'child_id': childId,
        if (teamId != null) 'team_id': teamId,
      },
    );
    return WaitlistEntry.fromJson(response.data!);
  }

  Future<List<WaitlistEntry>> listMine() async {
    final response = await _dio.get<Map<String, dynamic>>('/waitlists/mine',
        queryParameters: {'page': 1, 'page_size': 100});
    final items = response.data?['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => WaitlistEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<WaitlistEntry> leave(String entryId) async {
    final response =
        await _dio.delete<Map<String, dynamic>>('/waitlists/$entryId');
    return WaitlistEntry.fromJson(response.data!);
  }
}
