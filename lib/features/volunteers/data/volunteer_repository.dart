import 'models/volunteer_application.dart';
import 'volunteer_api.dart';

class VolunteerRepository {
  final VolunteerApi _api;
  const VolunteerRepository(this._api);

  Future<VolunteerApplication> create(Map<String, dynamic> values) =>
      _api.create(
        eventId: values['eventId'] as String,
        applicationType: values['applicationType'] as VolunteerApplicationType,
        fullName: values['fullName'] as String,
        phone: values['phone'] as String,
        email: values['email'] as String?,
        skillsExperience: values['skillsExperience'] as String?,
        availability: values['availability'] as String?,
        preferredResponsibility: values['preferredResponsibility'] as String?,
        message: values['message'] as String?,
      );

  Future<List<VolunteerApplication>> listMine() => _api.listMine();
}
