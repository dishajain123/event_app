import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../../events/application/events_providers.dart';

/// Provider watched and the navigation targets are unchanged from before.
class VolunteerOpportunitiesScreen extends ConsumerWidget {
  const VolunteerOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsListProvider(noEventsFilter));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Volunteer'),
        actions: [
          TextButton(
            onPressed: () => context.push(RoutePaths.myVolunteerApplications),
            child: const Text('My applications'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: AppBackground(
        child: events.when(
          loading: () => const AppSkeleton.cardList(),
          error: (error, _) => AppErrorState(
            error: error is AppException
                ? error
                : UnknownException(error.toString()),
            onRetry: () => ref.invalidate(eventsListProvider(noEventsFilter)),
          ),
          data: (items) {
            final open = items
                .where((event) => event.configuration?.volunteerOpen ?? false)
                .toList();
            if (open.isEmpty) {
              return const AppEmptyState(
                icon: Icons.volunteer_activism_outlined,
                title: 'No opportunities open',
                description:
                    'No volunteer opportunities are open right now — check back soon.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: open.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, index) {
                final event = open[index];
                return AppCard(
                  onTap: () =>
                      context.push(RoutePaths.volunteerApplyPath(event.id)),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                            color: AppColors.successSoft,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.volunteer_activism_rounded,
                            color: AppColors.success, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.name, style: AppTypography.bodyStrong),
                            const SizedBox(height: 2),
                            Text(event.displayCategory ?? 'Event',
                                style: AppTypography.caption),
                            const SizedBox(height: 2),
                            Text('${event.startDate.toLocal()}'.split(' ')[0],
                                style: AppTypography.captionSubtle),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.inkSubtle),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}