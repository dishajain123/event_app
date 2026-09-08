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
import '../../application/sponsorship_providers.dart';

/// Provider watched is unchanged from before — this was previously a
/// bare-spinner / `Text(error.toString())` screen, now on the same
/// loading/error/empty/card standard as the rest of the app.
class MySponsorshipInquiriesScreen extends ConsumerWidget {
  const MySponsorshipInquiriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inquiries = ref.watch(mySponsorshipInquiriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Sponsorship Inquiries')),
      body: AppBackground(
        child: inquiries.when(
          loading: () => const AppSkeleton.cardList(),
          error: (error, _) => AppErrorState(
            error: error is AppException
                ? error
                : UnknownException(error.toString()),
            onRetry: () => ref.invalidate(mySponsorshipInquiriesProvider),
          ),
          data: (items) => items.isEmpty
              ? const AppEmptyState(
                  icon: Icons.handshake_outlined,
                  title: 'No inquiries yet',
                  description:
                      'You have not submitted a sponsorship inquiry yet.',
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
                                color: AppColors.warningSoft,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.handshake_outlined,
                                color: AppColors.warning, size: 20),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.companyName,
                                    style: AppTypography.bodyStrong),
                                const SizedBox(height: 2),
                                Text(
                                    '${item.contactPerson} · ${item.eventIds.length} event(s)',
                                    style: AppTypography.caption),
                              ],
                            ),
                          ),
                          StatusBadge(label: item.status),
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