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
import '../../data/models/competition.dart';

class CompetitionStagesScreen extends ConsumerWidget {
  final String eventId;
  const CompetitionStagesScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competitionsAsync = ref.watch(eventCompetitionsProvider(eventId));
    final stagesAsync = ref.watch(competitionStagesProvider(eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Competition')),
      body: competitionsAsync.when(
        loading: () => const AppSkeleton.cardList(),
        error: (error, stackTrace) => AppErrorState(
          error: error is AppException
              ? error
              : UnknownException(error.toString()),
          onRetry: () => ref.invalidate(eventCompetitionsProvider(eventId)),
        ),
        data: (competitions) => competitions.isNotEmpty
            ? ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: competitions.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) =>
                    _CompetitionCard(competition: competitions[index]),
              )
            : _LegacyStages(stagesAsync: stagesAsync, eventId: eventId),
      ),
    );
  }
}

class _CompetitionCard extends ConsumerWidget {
  final CompetitionSummary competition;
  const _CompetitionCard({required this.competition});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standings = ref.watch(competitionStandingsProvider(competition.id));
    final matches = ref.watch(competitionMatchesProvider(competition.id));
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.emoji_events_outlined, color: AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
              child: Text(competition.name, style: AppTypography.bodyStrong)),
          StatusBadge(
              label: competition.status.replaceAll('_', ' '),
              tone: StatusTone.info),
        ]),
        if (competition.description?.isNotEmpty == true) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(competition.description!, style: AppTypography.caption),
        ],
        const SizedBox(height: AppSpacing.md),
        Text('Mode: ${competition.participationMode}',
            style: AppTypography.caption),
        matches.when(
          loading: () => const Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: LinearProgressIndicator()),
          error: (_, __) => const Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: Text('Fixtures unavailable')),
          data: (rows) => rows.isEmpty
              ? const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.md),
                  child: Text('No fixtures scheduled yet.'))
              : Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fixtures', style: AppTypography.bodyStrong),
                      ...rows.take(5).map((row) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                                'Round ${row.roundNumber}, match ${row.matchNumber} · ${row.status} · ${row.scoreA ?? '-'}:${row.scoreB ?? '-'}'),
                          )),
                    ],
                  ),
                ),
        ),
        standings.when(
          loading: () => const Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: LinearProgressIndicator()),
          error: (_, __) => const Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: Text('Standings unavailable')),
          data: (rows) => rows.isEmpty
              ? const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.md),
                  child:
                      Text('Standings will appear after results are recorded.'))
              : Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Column(
                      children: rows
                          .take(5)
                          .map((row) => _StandingRow(row: row))
                          .toList()),
                ),
        ),
      ]),
    );
  }
}

class _StandingRow extends StatelessWidget {
  final CompetitionStanding row;
  const _StandingRow({required this.row});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          SizedBox(width: 28, child: Text('${row.position}')),
          Expanded(child: Text(row.entryId, overflow: TextOverflow.ellipsis)),
          Text('${row.points} pts'),
        ]),
      );
}

class _LegacyStages extends ConsumerWidget {
  final AsyncValue<List<CompetitionStage>> stagesAsync;
  final String eventId;
  const _LegacyStages({required this.stagesAsync, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) => stagesAsync.when(
        loading: () => const AppSkeleton.cardList(),
        error: (error, stackTrace) => AppErrorState(
          error: error is AppException
              ? error
              : UnknownException(error.toString()),
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
          final sorted = [...stages]
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final stage = sorted[index];
              final isVotable = stage.stageType == StageType.publicVote;
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: isVotable
                    ? () => context.push(RoutePaths.votingPath(stage.id))
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                            color: AppColors.accentSoft,
                            shape: BoxShape.circle),
                        child: Center(
                          child: Text('${stage.orderIndex}',
                              style: AppTypography.bodyStrong),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(stage.name, style: AppTypography.bodyStrong),
                            Text(stage.stageType.label,
                                style: AppTypography.caption),
                          ],
                        ),
                      ),
                      if (isVotable)
                        const StatusBadge(
                            label: 'Vote now', tone: StatusTone.success),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
}
