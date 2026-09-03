import 'package:dio/dio.dart';
import 'models/app_notification.dart';

/// Mirrors `app/modules/notifications/router.py`'s participant-facing
/// endpoints, including POST /{id}/read — added and verified live this
/// session specifically because the service's mark_read() already
/// existed correctly implemented but had no router endpoint at all.
class NotificationsApi {
  final Dio _dio;
  const NotificationsApi(this._dio);

  Future<List<AppNotification>> listMine() async {
    final response = await _dio.get<List<dynamic>>('/notifications/mine');
    return response.data!.map((item) => AppNotification.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<AppNotification> markRead(String notificationId) async {
    final response = await _dio.post<Map<String, dynamic>>('/notifications/$notificationId/read');
    return AppNotification.fromJson(response.data!);
  }
}
