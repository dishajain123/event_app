import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/teams_providers.dart';

class MyTeamsScreen extends ConsumerWidget {
  const MyTeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(myTeamsProvider);
    final invitations = ref.watch(myTeamInvitationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My teams')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myTeamsProvider);
          ref.invalidate(myTeamInvitationsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Invitations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            invitations.when(
              loading: () => const AppSkeleton.cardList(count: 1),
              error: (error, stack) => AppErrorState(
                  error: error is AppException
                      ? error
                      : UnknownException(error.toString()),
                  onRetry: () => ref.invalidate(myTeamInvitationsProvider)),
              data: (items) {
                if (items.isEmpty) return const Text('No pending invitations.');
                return Column(
                  children: [
                    for (final invitation in items)
                      Card(
                        child: ListTile(
                          title:
                              Text('Invitation to team ${invitation.teamId}'),
                          subtitle: Text(invitation.inviteeMobile),
                          trailing: Wrap(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await ref
                                      .read(teamsRepositoryProvider)
                                      .respondToInvitation(
                                          teamId: invitation.teamId,
                                          invitationId: invitation.id,
                                          accept: false);
                                  ref.invalidate(myTeamInvitationsProvider);
                                },
                                child: const Text('Reject'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await ref
                                      .read(teamsRepositoryProvider)
                                      .respondToInvitation(
                                          teamId: invitation.teamId,
                                          invitationId: invitation.id,
                                          accept: true);
                                  ref.invalidate(myTeamInvitationsProvider);
                                  ref.invalidate(myTeamsProvider);
                                },
                                child: const Text('Accept'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Teams',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            teams.when(
              loading: () => const AppSkeleton.cardList(count: 2),
              error: (error, stack) => AppErrorState(
                  error: error is AppException
                      ? error
                      : UnknownException(error.toString()),
                  onRetry: () => ref.invalidate(myTeamsProvider)),
              data: (items) {
                if (items.isEmpty) {
                  return const Text('You are not part of a team yet.');
                }
                return Column(
                  children: [
                    for (final team in items)
                      Card(
                        child: ListTile(
                          title: Text(team.name),
                          subtitle:
                              Text('${team.status.label}  •  ${team.teamCode}'),
                          onTap: () => context.push(
                            RoutePaths.teamRosterPath(team.id),
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
    );
  }
}
