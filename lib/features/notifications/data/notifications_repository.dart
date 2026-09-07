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

  Future<DeviceTokenRegistration> registerDevice(
      {required String token, required String platform}) async {
    try {
      return await _api.registerDevice(token: token, platform: platform);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> removeDevice(String deviceId) async {
    try {
      await _api.removeDevice(deviceId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<NotificationPreferences> getPreferences() async {
    try {
      return await _api.getPreferences();
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<NotificationPreferences> updatePreferences(
      Map<String, bool> values) async {
    try {
      return await _api.updatePreferences(values);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
