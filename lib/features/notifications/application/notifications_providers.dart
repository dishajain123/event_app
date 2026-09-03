import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/models/app_notification.dart';
import '../data/notifications_api.dart';
import '../data/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return NotificationsRepository(NotificationsApi(dio));
});

final myNotificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final repository = ref.watch(notificationsRepositoryProvider);
  return repository.listMine();
});

/// The unread count — used for the Profile tab's badge (Section 8, Phase
/// 6). Derived from the same cached list rather than a second call.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(myNotificationsProvider);
  return notificationsAsync.maybeWhen(
    data: (notifications) => notifications.where((n) => n.isUnread).length,
    orElse: () => 0,
  );
});
