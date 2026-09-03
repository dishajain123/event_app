import '../../../core/network/dio_exception_mapper.dart';
import 'guardians_api.dart';
import 'models/child_profile.dart';

class GuardiansRepository {
  final GuardiansApi _api;
  const GuardiansRepository(this._api);

  Future<ChildProfile> createChild({
    required String fullName,
    required String dateOfBirthIso,
    String relationshipLabel = 'guardian',
  }) async {
    try {
      return await _api.createChild(
        fullName: fullName,
        dateOfBirthIso: dateOfBirthIso,
        relationshipLabel: relationshipLabel,
      );
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<ChildProfile>> listChildren() async {
    try {
      return await _api.listChildren();
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
