import 'package:dio/dio.dart';
import 'models/funnel_entry.dart';

/// Mirrors `app/modules/funnels/router.py`. Stage listing and voting are
/// open to any authenticated user; listing entries for management
/// (listEntriesForReview) and advancing them are Event-Manager-only
/// (confirmed directly against the live router's permission checks) —
/// listPublicVoteEntries is the new, narrower, public-facing endpoint
/// added and verified live this session specifically because GET
/// /entries gave a plain participant no way to discover what to vote for.
class FunnelsApi {
  final Dio _dio;
  const FunnelsApi(this._dio);

  Future<List<CompetitionStage>> listStages(String eventId) async {
    final response = await _dio.get<List<dynamic>>('/events/$eventId/stages');
    return response.data!.map((item) => CompetitionStage.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<FunnelEntry>> listPublicVoteEntries(String stageId) async {
    final response = await _dio.get<List<dynamic>>(
      '/entries/public',
      queryParameters: {'stage_id': stageId},
    );
    return response.data!.map((item) => FunnelEntry.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<FunnelEntry>> listEntriesForReview(String stageId) async {
    final response = await _dio.get<List<dynamic>>('/entries', queryParameters: {'stage_id': stageId});
    return response.data!.map((item) => FunnelEntry.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<FunnelEntry> vote(String entryId) async {
    final response = await _dio.post<Map<String, dynamic>>('/entries/$entryId/vote');
    return FunnelEntry.fromJson(response.data!);
  }

  Future<FunnelEntry> advance(String entryId, {required String decision, double? score, String? notes}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/entries/$entryId/advance',
      data: {
        'decision': decision,
        if (score != null) 'score': score,
        if (notes != null) 'notes': notes,
      },
    );
    return FunnelEntry.fromJson(response.data!);
  }
}
