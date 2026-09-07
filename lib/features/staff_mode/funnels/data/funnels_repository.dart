import '../../../../core/network/dio_exception_mapper.dart';
import 'funnels_api.dart';
import 'models/funnel_entry.dart';
import 'models/competition.dart';

class FunnelsRepository {
  final FunnelsApi _api;
  const FunnelsRepository(this._api);

  Future<List<CompetitionSummary>> listCompetitions(String eventId) async {
    try {
      return await _api.listCompetitions(eventId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<CompetitionStanding>> standings(String competitionId) async {
    try {
      return await _api.standings(competitionId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<CompetitionMatchSummary>> matches(String competitionId) async {
    try {
      return await _api.matches(competitionId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<CompetitionStage>> listStages(String eventId) async {
    try {
      return await _api.listStages(eventId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<FunnelEntry>> listPublicVoteEntries(String stageId) async {
    try {
      return await _api.listPublicVoteEntries(stageId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<FunnelEntry>> listEntriesForReview(String stageId) async {
    try {
      return await _api.listEntriesForReview(stageId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<FunnelEntry> vote(String entryId) async {
    try {
      return await _api.vote(entryId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<FunnelEntry> advance(String entryId,
      {required String decision, double? score, String? notes}) async {
    try {
      return await _api.advance(entryId,
          decision: decision, score: score, notes: notes);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
