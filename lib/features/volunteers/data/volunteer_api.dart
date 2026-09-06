import 'package:dio/dio.dart';
import 'models/volunteer_application.dart';

class VolunteerApi {
  final Dio _dio;
  const VolunteerApi(this._dio);

  Future<VolunteerApplication> create({
    required String eventId,
    required VolunteerApplicationType applicationType,
    required String fullName,
    required String phone,
    String? email,
    String? skillsExperience,
    String? availability,
    String? preferredResponsibility,
    String? message,
  }) async {
    final response = await _dio
        .post<Map<String, dynamic>>('/volunteers/applications', data: {
      'event_id': eventId,
      'application_type': applicationType.wireValue,
      'full_name': fullName,
      'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      if (skillsExperience != null && skillsExperience.isNotEmpty)
        'skills_experience': skillsExperience,
      if (availability != null && availability.isNotEmpty)
        'availability': availability,
      if (preferredResponsibility != null && preferredResponsibility.isNotEmpty)
        'preferred_responsibility': preferredResponsibility,
      if (message != null && message.isNotEmpty) 'message': message,
    });
    return VolunteerApplication.fromJson(response.data!);
  }

  Future<List<VolunteerApplication>> listMine() async {
    final response =
        await _dio.get<List<dynamic>>('/volunteers/applications/mine');
    return response.data!
        .map((item) =>
            VolunteerApplication.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
