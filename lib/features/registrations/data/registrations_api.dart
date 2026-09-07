import 'package:dio/dio.dart';
import 'models/registration.dart';

/// Mirrors `app/modules/registrations/router.py`'s endpoints — both the
/// participant-facing ones (create/mine/get) and the Event-Manager-only
/// review actions (listRegistrationsForEvent/approve/reject), the latter
/// added for Phase 6's registration review queue. Kept in this single
/// API class since they're all genuinely the same REST resource
/// ("registrations"); the STAFF_MODE feature's repository/screens are
/// what actually restrict the review actions to Event Manager UI.
class RegistrationsApi {
  final Dio _dio;
  const RegistrationsApi(this._dio);

  /// Mirrors `RegistrationCreateIn` exactly. `event_id` is a query
  /// parameter on this endpoint (confirmed against the live router),
  /// not part of the JSON body.
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
    final response = await _dio.post<Map<String, dynamic>>(
      '/registrations',
      queryParameters: {'event_id': eventId},
      data: {
        'participation_type': participationType,
        if (childId != null) 'child_id': childId,
        if (teamId != null) 'team_id': teamId,
        if (dateOfBirthIso != null) 'date_of_birth': dateOfBirthIso,
        'documents_provided': documentsProvided,
        'answers': answers,
        'participants': participants.map((p) => p.toJson()).toList(),
        if (teamMemberCount != null) 'team_member_count': teamMemberCount,
      },
    );
    return AppRegistration.fromJson(response.data!);
  }

  Future<List<AppRegistration>> listMyRegistrations() async {
    final response = await _dio.get<List<dynamic>>('/registrations/mine');
    return response.data!.map((item) => AppRegistration.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<AppRegistration> getRegistration(String registrationId) async {
    final response = await _dio.get<Map<String, dynamic>>('/registrations/$registrationId');
    return AppRegistration.fromJson(response.data!);
  }

  /// Event-Manager-only actions (Section 8, Phase 6's registration
  /// review queue) — mirrors POST /registrations/{id}/approve and
  /// /reject exactly.
  Future<List<AppRegistration>> listRegistrationsForEvent(String eventId) async {
    final response = await _dio.get<List<dynamic>>('/registrations', queryParameters: {'event_id': eventId});
    return response.data!.map((item) => AppRegistration.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<AppRegistration> approveRegistration(String registrationId) async {
    final response = await _dio.post<Map<String, dynamic>>('/registrations/$registrationId/approve');
    return AppRegistration.fromJson(response.data!);
  }

  Future<AppRegistration> rejectRegistration(String registrationId, String reason) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/registrations/$registrationId/reject',
      data: {'reason': reason},
    );
    return AppRegistration.fromJson(response.data!);
  }

  Future<AppRegistration> cancelRegistration(String registrationId, {String? reason}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/registrations/$registrationId/cancel',
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    );
    return AppRegistration.fromJson(response.data!);
  }
}
