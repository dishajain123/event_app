import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/notifications_providers.dart';
import '../../data/models/app_notification.dart';

class NotificationsInboxScreen extends ConsumerWidget {
  const NotificationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(myNotificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myNotificationsProvider),
        child: notificationsAsync.when(
          loading: () => const AppSkeleton.cardList(),
          error: (error, stackTrace) => ListView(
            children: [
              const SizedBox(height: AppSpacing.xxxl),
              AppErrorState(
                error: error is AppException ? error : UnknownException(error.toString()),
                onRetry: () => ref.invalidate(myNotificationsProvider),
              ),
            ],
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: AppSpacing.xxxl),
                  AppEmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: 'No notifications yet',
                    description: "Updates about your registrations and events will show up here.",
                  ),
                ],
              );
            }
            final sorted = [...notifications]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) => _NotificationTile(notification: sorted[index]),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final AppNotification notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: notification.isUnread
          ? () async {
              final repository = ref.read(notificationsRepositoryProvider);
              try {
                await repository.markRead(notification.id);
                ref.invalidate(myNotificationsProvider);
              } on AppException {
                // A failed mark-read isn't worth interrupting the user
                // over — the notification simply stays marked unread and
                // they can try again; nothing is lost.
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: notification.isUnread ? Colors.white.withOpacity(0.85) : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.isUnread)
              Container(
                margin: const EdgeInsets.only(top: 6, right: AppSpacing.sm),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
              )
            else
              const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: notification.isUnread ? AppTypography.bodyStrong : AppTypography.body,
                  ),
                  const SizedBox(height: 4),
                  Text(notification.body, style: AppTypography.bodyMuted),
                  const SizedBox(height: 6),
                  Text(_relativeTime(notification.createdAt), style: AppTypography.captionSubtle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
