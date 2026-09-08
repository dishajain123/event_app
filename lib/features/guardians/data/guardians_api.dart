import 'package:dio/dio.dart';
import 'models/child_profile.dart';

/// Mirrors `app/modules/guardians/router.py` exactly.
class GuardiansApi {
  final Dio _dio;
  const GuardiansApi(this._dio);

  Future<ChildProfile> createChild({
    required String fullName,
    required String dateOfBirthIso,
    String relationshipLabel = 'guardian',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/guardians/children',
      data: {
        'full_name': fullName,
        'date_of_birth': dateOfBirthIso,
        'relationship_label': relationshipLabel,
      },
    );
    return ChildProfile.fromJson(response.data!);
  }

  Future<List<ChildProfile>> listChildren() async {
    final response = await _dio.get<List<dynamic>>('/guardians/children');
    return response.data!
        .map((item) => ChildProfile.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
