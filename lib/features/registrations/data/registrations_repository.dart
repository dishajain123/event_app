import '../../../core/network/dio_exception_mapper.dart';
import 'models/registration.dart';
import 'registrations_api.dart';

class RegistrationsRepository {
  final RegistrationsApi _api;
  const RegistrationsRepository(this._api);

  Future<AppRegistration> createRegistration({
    required String eventId,
    required String participationType,
    String? childId,
    String? teamId,
    String? dateOfBirthIso,
    required List<String> documentsProvided,
    required Map<String, dynamic> answers,
    required List<RegistrationParticipantInput> participants,
    int? teamMemberCount,
  }) async {
    try {
      return await _api.createRegistration(
        eventId: eventId,
        participationType: participationType,
        childId: childId,
        teamId: teamId,
        dateOfBirthIso: dateOfBirthIso,
        documentsProvided: documentsProvided,
        answers: answers,
        participants: participants,
        teamMemberCount: teamMemberCount,
      );
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<AppRegistration>> listMyRegistrations() async {
    try {
      return await _api.listMyRegistrations();
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AppRegistration> getRegistration(String registrationId) async {
    try {
      return await _api.getRegistration(registrationId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<AppRegistration>> listRegistrationsForEvent(String eventId) async {
    try {
      return await _api.listRegistrationsForEvent(eventId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AppRegistration> approveRegistration(String registrationId) async {
    try {
      return await _api.approveRegistration(registrationId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AppRegistration> rejectRegistration(String registrationId, String reason) async {
    try {
      return await _api.rejectRegistration(registrationId, reason);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
