import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/teams_providers.dart';

/// Providers watched and every `respondToInvitation`/navigation call are
/// unchanged from before — only the presentation (plain [Card]/[ListTile]
/// rows, hardcoded [TextStyle]s) is refreshed to match the rest of the app.
class MyTeamsScreen extends ConsumerWidget {
  const MyTeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(myTeamsProvider);
    final invitations = ref.watch(myTeamInvitationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Teams')),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myTeamsProvider);
            ref.invalidate(myTeamInvitationsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const Text('Invitations', style: AppTypography.title),
              const SizedBox(height: AppSpacing.md),
              invitations.when(
                loading: () => const AppSkeleton.cardList(count: 1),
                error: (error, stack) => AppErrorState(
                    error: error is AppException
                        ? error
                        : UnknownException(error.toString()),
                    onRetry: () => ref.invalidate(myTeamInvitationsProvider)),
                data: (items) {
                  if (items.isEmpty) {
                    return const Text('No pending invitations.',
                        style: AppTypography.bodyMuted);
                  }
                  return Column(
                    children: [
                      for (final invitation in items)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                          color: AppColors.warningSoft,
                                          shape: BoxShape.circle),
                                      child: const Icon(Icons.mail_outline_rounded,
                                          size: 18, color: AppColors.warning),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        invitation.inviteeMobile,
                                        style: AppTypography.bodyStrong,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppButton(
                                        label: 'Decline',
                                        variant: AppButtonVariant.ghost,
                                        onPressed: () async {
                                          await ref
                                              .read(teamsRepositoryProvider)
                                              .respondToInvitation(
                                                  teamId: invitation.teamId,
                                                  invitationId: invitation.id,
                                                  accept: false);
                                          ref.invalidate(
                                              myTeamInvitationsProvider);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: AppButton(
                                        label: 'Accept',
                                        onPressed: () async {
                                          await ref
                                              .read(teamsRepositoryProvider)
                                              .respondToInvitation(
                                                  teamId: invitation.teamId,
                                                  invitationId: invitation.id,
                                                  accept: true);
                                          ref.invalidate(
                                              myTeamInvitationsProvider);
                                          ref.invalidate(myTeamsProvider);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text('Teams', style: AppTypography.title),
              const SizedBox(height: AppSpacing.md),
              teams.when(
                loading: () => const AppSkeleton.cardList(count: 2),
                error: (error, stack) => AppErrorState(
                    error: error is AppException
                        ? error
                        : UnknownException(error.toString()),
                    onRetry: () => ref.invalidate(myTeamsProvider)),
                data: (items) {
                  if (items.isEmpty) {
                    return const Text('You are not part of a team yet.',
                        style: AppTypography.bodyMuted);
                  }
                  return Column(
                    children: [
                      for (final team in items)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppCard(
                            onTap: () => context.push(
                              RoutePaths.teamRosterPath(team.id),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                      color: AppColors.accentSoft,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.groups_rounded,
                                      color: AppColors.accentStrong, size: 20),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(team.name,
                                          style: AppTypography.bodyStrong),
                                      const SizedBox(height: 2),
                                      Text(
                                          '${team.status.label}  ·  ${team.teamCode}',
                                          style: AppTypography.caption),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded,
                                    color: AppColors.inkSubtle),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}