import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/router/route_paths.dart';
import '../../../../../core/network/app_exception.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/badges/status_badge.dart';
import '../../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../../shared/widgets/states/app_error_state.dart';
import '../../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/funnels_providers.dart';
import '../../data/models/funnel_entry.dart';

class CompetitionStagesScreen extends ConsumerWidget {
  final String eventId;
  const CompetitionStagesScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stagesAsync = ref.watch(competitionStagesProvider(eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Competition')),
      body: stagesAsync.when(
        loading: () => const AppSkeleton.cardList(),
        error: (error, stackTrace) => AppErrorState(
          error: error is AppException ? error : UnknownException(error.toString()),
          onRetry: () => ref.invalidate(competitionStagesProvider(eventId)),
        ),
        data: (stages) {
          if (stages.isEmpty) {
            return const AppEmptyState(
              icon: Icons.emoji_events_outlined,
              title: 'No competition stages',
              description: "This event doesn't have a competition set up.",
            );
          }
          final sorted = [...stages]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final stage = sorted[index];
              final isVotable = stage.stageType == StageType.publicVote;
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: isVotable ? () => context.push(RoutePaths.votingPath(stage.id)) : null,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(color: AppColors.accentSoft, shape: BoxShape.circle),
                        child: Center(
                          child: Text('${stage.orderIndex}', style: AppTypography.bodyStrong),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(stage.name, style: AppTypography.bodyStrong),
                            Text(stage.stageType.label, style: AppTypography.caption),
                          ],
                        ),
                      ),
                      if (isVotable) const StatusBadge(label: 'Vote now', tone: StatusTone.success),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
