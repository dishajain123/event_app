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
    return response.data!
        .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AppNotification> markRead(String notificationId) async {
    final response = await _dio
        .post<Map<String, dynamic>>('/notifications/$notificationId/read');
    return AppNotification.fromJson(response.data!);
  }

  Future<DeviceTokenRegistration> registerDevice(
      {required String token, required String platform}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/notifications/devices',
      data: {'token': token, 'platform': platform},
    );
    return DeviceTokenRegistration.fromJson(response.data!);
  }

  Future<void> removeDevice(String deviceId) async {
    await _dio.delete<void>('/notifications/devices/$deviceId');
  }

  Future<NotificationPreferences> getPreferences() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/notifications/preferences');
    return NotificationPreferences.fromJson(response.data!);
  }

  Future<NotificationPreferences> updatePreferences(
      Map<String, bool> values) async {
    final response = await _dio.patch<Map<String, dynamic>>(
        '/notifications/preferences',
        data: values);
    return NotificationPreferences.fromJson(response.data!);
  }
}

class DeviceTokenRegistration {
  final String id;
  final String platform;
  const DeviceTokenRegistration({required this.id, required this.platform});

  factory DeviceTokenRegistration.fromJson(Map<String, dynamic> json) =>
      DeviceTokenRegistration(
        id: json['id'] as String,
        platform: json['platform'] as String,
      );
}

class NotificationPreferences {
  final bool eventReminders;
  final bool registrationUpdates;
  final bool cancellationRefundUpdates;
  final bool eventChanges;
  final bool operationalNotifications;
  final bool marketingNotifications;

  const NotificationPreferences({
    required this.eventReminders,
    required this.registrationUpdates,
    required this.cancellationRefundUpdates,
    required this.eventChanges,
    required this.operationalNotifications,
    required this.marketingNotifications,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      NotificationPreferences(
        eventReminders: json['event_reminders'] as bool,
        registrationUpdates: json['registration_updates'] as bool,
        cancellationRefundUpdates: json['cancellation_refund_updates'] as bool,
        eventChanges: json['event_changes'] as bool,
        operationalNotifications: json['operational_notifications'] as bool,
        marketingNotifications: json['marketing_notifications'] as bool,
      );
}
