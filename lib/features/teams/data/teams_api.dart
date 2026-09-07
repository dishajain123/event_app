import 'package:dio/dio.dart';
import 'models/team.dart';

/// Mirrors `app/modules/teams/router.py` exactly, including
/// GET /teams/{team_id} and GET /teams/{team_id}/members — added and
/// verified live this session specifically so a team's own captain/member
/// has a way to check on their team at all (previously only the
/// create/submit response ever showed team state).
class TeamsApi {
  final Dio _dio;
  const TeamsApi(this._dio);

  Future<AppTeam> createTeam({
    required String eventId,
    required String name,
    String? captainDateOfBirthIso,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/teams',
      queryParameters: {'event_id': eventId},
      data: {
        'name': name,
        if (captainDateOfBirthIso != null)
          'captain_date_of_birth': captainDateOfBirthIso,
      },
    );
    return AppTeam.fromJson(response.data!);
  }

  Future<AppTeam> getTeam(String teamId) async {
    final response = await _dio.get<Map<String, dynamic>>('/teams/$teamId');
    return AppTeam.fromJson(response.data!);
  }

  Future<List<TeamMember>> listMembers(String teamId) async {
    final response = await _dio.get<List<dynamic>>('/teams/$teamId/members');
    return response.data!
        .map((item) => TeamMember.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TeamInvitation> inviteMember(
      String teamId, String inviteeMobile) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/teams/$teamId/invitations',
      data: {'invitee_mobile': inviteeMobile},
    );
    return TeamInvitation.fromJson(response.data!);
  }

  Future<TeamInvitation> respondToInvitation({
    required String teamId,
    required String invitationId,
    required bool accept,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/teams/$teamId/invitations/$invitationId/respond',
      data: {'accept': accept},
    );
    return TeamInvitation.fromJson(response.data!);
  }

  Future<AppTeam> submitTeam(String teamId) async {
    final response =
        await _dio.post<Map<String, dynamic>>('/teams/$teamId/submit');
    return AppTeam.fromJson(response.data!);
  }

  Future<void> requestToJoin(String teamId) async {
    await _dio.post('/teams/$teamId/join-requests');
  }

  Future<void> leaveTeam(String teamId) async {
    await _dio.post('/teams/$teamId/leave');
  }

  Future<List<AppTeam>> listMyTeams() async {
    final response = await _dio.get<List<dynamic>>('/teams/mine');
    return response.data!
        .map((item) => AppTeam.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<TeamInvitation>> listMyInvitations() async {
    final response = await _dio.get<List<dynamic>>('/teams/invitations/mine');
    return response.data!
        .map((item) => TeamInvitation.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
