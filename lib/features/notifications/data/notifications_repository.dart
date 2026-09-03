import '../../../core/network/dio_exception_mapper.dart';
import 'models/app_notification.dart';
import 'notifications_api.dart';

class NotificationsRepository {
  final NotificationsApi _api;
  const NotificationsRepository(this._api);

  Future<List<AppNotification>> listMine() async {
    try {
      return await _api.listMine();
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AppNotification> markRead(String notificationId) async {
    try {
      return await _api.markRead(notificationId);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
