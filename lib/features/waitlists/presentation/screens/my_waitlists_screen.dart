import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/waitlists_providers.dart';
import '../../data/models/waitlist_entry.dart';

const _waitlistTones = {
  WaitlistStatus.waiting: StatusTone.info,
  WaitlistStatus.promoted: StatusTone.success,
  WaitlistStatus.expired: StatusTone.warning,
  WaitlistStatus.left: StatusTone.neutral,
  WaitlistStatus.closed: StatusTone.neutral,
};

/// Provider watched and the `leave()` repository call are unchanged from
/// before — this was previously the app's most bare-bones screen (a raw
/// spinner and `Text(error.toString())`), now brought up to the same
/// loading/error/empty/card standard as every other list screen.
class MyWaitlistsScreen extends ConsumerWidget {
  const MyWaitlistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myWaitlistsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Waitlists')),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(myWaitlistsProvider),
          child: state.when(
            loading: () => const AppSkeleton.cardList(count: 3),
            error: (error, stackTrace) => ListView(
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                AppErrorState(
                  error: error is AppException
                      ? error
                      : UnknownException(error.toString()),
                  onRetry: () => ref.invalidate(myWaitlistsProvider),
                ),
              ],
            ),
            data: (entries) {
              if (entries.isEmpty) {
                return ListView(
                  children: const [
                    SizedBox(height: AppSpacing.xxxl),
                    AppEmptyState(
                      icon: Icons.queue_outlined,
                      title: 'No waitlist entries',
                      description:
                          'When an event is full, joining its waitlist will show up here.',
                    ),
                  ],
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: entries.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) =>
                    _EntryCard(entry: entries[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends ConsumerWidget {
  final WaitlistEntry entry;
  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = entry.status == WaitlistStatus.waiting ||
        entry.status == WaitlistStatus.promoted;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
                color: AppColors.accentSoft, shape: BoxShape.circle),
            child: const Icon(Icons.queue_outlined,
                color: AppColors.accentStrong, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(entry.participationType,
                          style: AppTypography.bodyStrong),
                    ),
                    StatusBadge(
                      label: entry.status.wireValue.replaceAll('_', ' '),
                      tone: _waitlistTones[entry.status] ?? StatusTone.neutral,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.position == null
                      ? 'Joined ${entry.joinedAt.day}/${entry.joinedAt.month}/${entry.joinedAt.year}'
                      : 'Position ${entry.position} in queue',
                  style: AppTypography.caption,
                ),
                if (active) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppButton(
                      label: 'Leave waitlist',
                      variant: AppButtonVariant.ghost,
                      onPressed: () async {
                        await ref
                            .read(waitlistsRepositoryProvider)
                            .leave(entry.id);
                        ref.invalidate(myWaitlistsProvider);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}