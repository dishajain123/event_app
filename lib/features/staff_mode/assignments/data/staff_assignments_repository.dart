import '../../../../core/network/dio_exception_mapper.dart';
import 'models/staff_assignment.dart';
import 'staff_assignments_api.dart';

class StaffAssignmentsRepository {
  final StaffAssignmentsApi _api;
  const StaffAssignmentsRepository(this._api);

  Future<List<StaffAssignment>> listMine() async {
    try {
      return await _api.listMine();
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<StaffAssignment> accept(String assignmentId) async {
    try {
      return await _api.accept(assignmentId);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<List<StaffAssignmentHistoryEntry>> getHistory({
    required String eventId,
    required String assignmentId,
  }) async {
    try {
      return await _api.getHistory(
          eventId: eventId, assignmentId: assignmentId);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
