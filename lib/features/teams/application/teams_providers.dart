import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/models/team.dart';
import '../data/teams_api.dart';
import '../data/teams_repository.dart';

final teamsRepositoryProvider = Provider<TeamsRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return TeamsRepository(TeamsApi(dio));
});

final teamDetailProvider = FutureProvider.family<AppTeam, String>((ref, teamId) async {
  final repository = ref.watch(teamsRepositoryProvider);
  return repository.getTeam(teamId);
});

final teamMembersProvider = FutureProvider.family<List<TeamMember>, String>((ref, teamId) async {
  final repository = ref.watch(teamsRepositoryProvider);
  return repository.listMembers(teamId);
});

final myTeamsProvider = FutureProvider<List<AppTeam>>((ref) async {
  return ref.watch(teamsRepositoryProvider).listMyTeams();
});

final myTeamInvitationsProvider =
    FutureProvider<List<TeamInvitation>>((ref) async {
  return ref.watch(teamsRepositoryProvider).listMyInvitations();
});
