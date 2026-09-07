import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../data/funnels_api.dart';
import '../data/funnels_repository.dart';
import '../data/models/funnel_entry.dart';
import '../data/models/competition.dart';

final funnelsRepositoryProvider = Provider<FunnelsRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return FunnelsRepository(FunnelsApi(dio));
});

final competitionStagesProvider =
    FutureProvider.family<List<CompetitionStage>, String>((ref, eventId) async {
  final repository = ref.watch(funnelsRepositoryProvider);
  return repository.listStages(eventId);
});

final eventCompetitionsProvider =
    FutureProvider.family<List<CompetitionSummary>, String>(
        (ref, eventId) async {
  final repository = ref.watch(funnelsRepositoryProvider);
  return repository.listCompetitions(eventId);
});

final competitionStandingsProvider =
    FutureProvider.family<List<CompetitionStanding>, String>(
        (ref, competitionId) async {
  final repository = ref.watch(funnelsRepositoryProvider);
  return repository.standings(competitionId);
});

final competitionMatchesProvider =
    FutureProvider.family<List<CompetitionMatchSummary>, String>(
        (ref, competitionId) async {
  final repository = ref.watch(funnelsRepositoryProvider);
  return repository.matches(competitionId);
});

final publicVoteEntriesProvider =
    FutureProvider.family<List<FunnelEntry>, String>((ref, stageId) async {
  final repository = ref.watch(funnelsRepositoryProvider);
  return repository.listPublicVoteEntries(stageId);
});
