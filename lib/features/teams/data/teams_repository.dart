import '../../../core/network/dio_exception_mapper.dart';
import 'models/team.dart';
import 'teams_api.dart';

class TeamsRepository {
  final TeamsApi _api;
  const TeamsRepository(this._api);

  Future<AppTeam> createTeam({required String eventId, required String name, String? captainDateOfBirthIso}) async {
    try {
      return await _api.createTeam(eventId: eventId, name: name, captainDateOfBirthIso: captainDateOfBirthIso);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AppTeam> getTeam(String teamId) async {
    try {
      return await _api.getTeam(teamId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<TeamMember>> listMembers(String teamId) async {
    try {
      return await _api.listMembers(teamId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<TeamInvitation> inviteMember(String teamId, String inviteeMobile) async {
    try {
      return await _api.inviteMember(teamId, inviteeMobile);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<TeamInvitation> respondToInvitation({
    required String teamId,
    required String invitationId,
    required bool accept,
  }) async {
    try {
      return await _api.respondToInvitation(teamId: teamId, invitationId: invitationId, accept: accept);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AppTeam> submitTeam(String teamId) async {
    try {
      return await _api.submitTeam(teamId);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
