import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/notifications_providers.dart';
import '../../data/models/app_notification.dart';

/// The provider watched and the mark-read → deep-link navigation flow are
/// unchanged from before — only the tile's presentation was refreshed.
class NotificationsInboxScreen extends ConsumerWidget {
  const NotificationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(myNotificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(myNotificationsProvider),
          child: notificationsAsync.when(
            loading: () => const AppSkeleton.cardList(),
            error: (error, stackTrace) => ListView(
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                AppErrorState(
                  error: error is AppException
                      ? error
                      : UnknownException(error.toString()),
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
                      description:
                          'Updates about your registrations and events will show up here.',
                    ),
                  ],
                );
              }
              final sorted = [...notifications]
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) =>
                    _NotificationTile(notification: sorted[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final AppNotification notification;
  const _NotificationTile({required this.notification});

  IconData get _icon => switch (notification.notificationType) {
        'payment' => Icons.payments_outlined,
        'registration' => Icons.assignment_turned_in_outlined,
        'ticket' => Icons.confirmation_number_outlined,
        _ => Icons.campaign_outlined,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = notification.isUnread;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: unread
            ? () async {
                final repository = ref.read(notificationsRepositoryProvider);
                try {
                  await repository.markRead(notification.id);
                  ref.invalidate(myNotificationsProvider);
                  final deepLink =
                      notification.targetMetadata?['deep_link'] as String?;
                  if (deepLink != null && deepLink.startsWith('/')) {
                    if (context.mounted) context.push(deepLink);
                  }
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: unread
                ? Border.all(color: AppColors.accent.withValues(alpha: 0.18))
                : null,
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: unread ? AppColors.accentSoft : AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon,
                    size: 18,
                    color:
                        unread ? AppColors.accentStrong : AppColors.inkSubtle),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: unread
                          ? AppTypography.bodyStrong
                          : AppTypography.body,
                    ),
                    const SizedBox(height: 4),
                    Text(notification.body, style: AppTypography.bodyMuted),
                    const SizedBox(height: 6),
                    Text(_relativeTime(notification.createdAt),
                        style: AppTypography.captionSubtle),
                  ],
                ),
              ),
              if (unread)
                Container(
                  margin: const EdgeInsets.only(top: 4, left: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle),
                ),
            ],
          ),
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
