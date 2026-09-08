import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/volunteer_providers.dart';
import '../../data/models/volunteer_application.dart';

/// Provider watched is unchanged from before — this was previously a
/// bare-spinner screen, now on the same standard as the rest of the app.
class MyVolunteerApplicationsScreen extends ConsumerWidget {
  const MyVolunteerApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(myVolunteerApplicationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Volunteer Applications')),
      body: AppBackground(
        child: applications.when(
          loading: () => const AppSkeleton.cardList(),
          error: (error, _) => AppErrorState(
            error: error is AppException
                ? error
                : UnknownException(error.toString()),
            onRetry: () => ref.invalidate(myVolunteerApplicationsProvider),
          ),
          data: (items) => items.isEmpty
              ? const AppEmptyState(
                  icon: Icons.volunteer_activism_outlined,
                  title: 'No applications yet',
                  description:
                      'You have not submitted a volunteer application yet.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return AppCard(
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
                                Text(item.fullName,
                                    style: AppTypography.bodyStrong),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.applicationType == VolunteerApplicationType.eventManager ? 'Event Manager' : 'Volunteer'} · ${item.preferredResponsibility ?? 'Application'}',
                                  style: AppTypography.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(label: item.status.wireValue),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}