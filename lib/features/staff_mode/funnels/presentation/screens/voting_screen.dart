import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/app_exception.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/buttons/app_button.dart';
import '../../../../../shared/widgets/sheets/confirm_action_sheet.dart';
import '../../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../../shared/widgets/states/app_error_state.dart';
import '../../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/funnels_providers.dart';
import '../../data/models/funnel_entry.dart';

class VotingScreen extends ConsumerWidget {
  final String stageId;
  const VotingScreen({super.key, required this.stageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(publicVoteEntriesProvider(stageId));

    return Scaffold(
      appBar: AppBar(title: const Text('Vote')),
      body: entriesAsync.when(
        loading: () => const AppSkeleton.cardList(),
        error: (error, stackTrace) => AppErrorState(
          error: error is AppException ? error : UnknownException(error.toString()),
          onRetry: () => ref.invalidate(publicVoteEntriesProvider(stageId)),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return const AppEmptyState(
              icon: Icons.how_to_vote_outlined,
              title: 'No entries yet',
              description: 'Check back once entries have been submitted for this stage.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) => _EntryCard(stageId: stageId, entry: entries[index]),
          );
        },
      ),
    );
  }
}

class _EntryCard extends ConsumerWidget {
  final String stageId;
  final FunnelEntry entry;
  const _EntryCard({required this.stageId, required this.entry});

  Future<void> _vote(BuildContext context, WidgetRef ref) async {
    await showConfirmActionSheet(
      context,
      title: 'Cast your vote?',
      description: 'You can only vote once per entry.',
      confirmLabel: 'Vote',
      onConfirm: (reason) async {
        final repository = ref.read(funnelsRepositoryProvider);
        await repository.vote(entry.id);
        ref.invalidate(publicVoteEntriesProvider(stageId));
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.accentSoft, shape: BoxShape.circle),
            child: const Icon(Icons.person_rounded, color: AppColors.accentStrong),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Entry #${entry.id.substring(0, 8)}', style: AppTypography.bodyStrong),
                Text('${entry.voteCount} votes', style: AppTypography.caption),
              ],
            ),
          ),
          AppButton(label: 'Vote', variant: AppButtonVariant.secondary, onPressed: () => _vote(context, ref)),
        ],
      ),
    );
  }
}
