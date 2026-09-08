import '../../../core/network/dio_exception_mapper.dart';
import 'config_engine_api.dart';
import 'models/configurable_field.dart';
import 'models/event_configuration.dart';

class ConfigEngineRepository {
  final ConfigEngineApi _api;
  const ConfigEngineRepository(this._api);

  Future<EventConfiguration?> getConfiguration(String eventId) async {
    try {
      return await _api.getConfiguration(eventId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<EventFieldSchema?> getFieldSchema(
      String eventId, String participationType) async {
    try {
      return await _api.getFieldSchema(eventId, participationType);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<ValidationResult> validateRegistration({
    required String eventId,
    required String participationType,
    String? dateOfBirthIso,
    int? teamMemberCount,
    required List<String> documentsProvided,
    required Map<String, dynamic> answers,
  }) async {
    try {
      return await _api.validateRegistration(
        eventId: eventId,
        participationType: participationType,
        dateOfBirthIso: dateOfBirthIso,
        teamMemberCount: teamMemberCount,
        documentsProvided: documentsProvided,
        answers: answers,
      );
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
