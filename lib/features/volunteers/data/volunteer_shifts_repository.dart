import 'models/volunteer_shift.dart';
import 'volunteer_shifts_api.dart';
class VolunteerShiftsRepository {
  final VolunteerShiftsApi api; const VolunteerShiftsRepository(this.api);
  Future<List<VolunteerShift>> available() => api.available();
  Future<List<VolunteerShiftAssignment>> mine() => api.mine();
  Future<VolunteerShiftAssignment> request(String id) => api.request(id);
  Future<VolunteerShiftAssignment> detail(String id) => api.detail(id);
  Future<VolunteerShiftAssignment> cancel(String id) => api.cancel(id);
  Future<VolunteerAttendance> checkIn(String id) => api.checkIn(id);
  Future<VolunteerAttendance> checkOut(String id) => api.checkOut(id);
  Future<VolunteerAttendance?> attendance(String id) => api.attendance(id);
}
