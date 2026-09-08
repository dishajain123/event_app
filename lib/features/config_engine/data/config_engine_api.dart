import 'package:dio/dio.dart';
import 'models/configurable_field.dart';
import 'models/event_configuration.dart';

/// Mirrors `app/modules/config_engine/router.py`'s read + validate
/// endpoints exactly. Mobile never writes configuration (Section 9.11 —
/// upsert is console/Event-Manager only).
class ConfigEngineApi {
  final Dio _dio;
  const ConfigEngineApi(this._dio);

  Future<EventConfiguration?> getConfiguration(String eventId) async {
    final response = await _dio.get<Map<String, dynamic>?>(
      '/events/$eventId/configuration',
    );
    if (response.data == null) return null;
    return EventConfiguration.fromJson(response.data!);
  }

  Future<EventFieldSchema?> getFieldSchema(
      String eventId, String participationType) async {
    final response = await _dio.get<Map<String, dynamic>?>(
      '/events/$eventId/field-schema/$participationType',
    );
    if (response.data == null) return null;
    return EventFieldSchema.fromJson(response.data!);
  }

  /// Mirrors `ValidateRegistrationIn` exactly — the dry-run every
  /// registration submission runs first (Section 3's governing principle:
  /// eligibility is decided by the backend, never re-derived here).
  Future<ValidationResult> validateRegistration({
    required String eventId,
    required String participationType,
    String? dateOfBirthIso, // YYYY-MM-DD
    int? teamMemberCount,
    required List<String> documentsProvided,
    required Map<String, dynamic> answers,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/events/$eventId/configuration/validate',
      data: {
        'participation_type': participationType,
        if (dateOfBirthIso != null) 'date_of_birth': dateOfBirthIso,
        if (teamMemberCount != null) 'team_member_count': teamMemberCount,
        'documents_provided': documentsProvided,
        'answers': answers,
      },
    );
    return ValidationResult.fromJson(response.data!);
  }
}
