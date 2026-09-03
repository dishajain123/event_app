import 'package:dio/dio.dart';
import 'models/staff_assignment.dart';

/// Mirrors `app/modules/staff/router.py` exactly — including
/// GET /staff/assignments/mine, added and verified live this session
/// specifically because an invitee previously had no way to discover a
/// staff invitation exists at all (no notification is sent on creation).
class StaffAssignmentsApi {
  final Dio _dio;
  const StaffAssignmentsApi(this._dio);

  Future<List<StaffAssignment>> listMine() async {
    final response = await _dio.get<List<dynamic>>('/staff/assignments/mine');
    return response.data!.map((item) => StaffAssignment.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<StaffAssignment> accept(String assignmentId) async {
    final response = await _dio.post<Map<String, dynamic>>('/staff/assignments/$assignmentId/accept');
    return StaffAssignment.fromJson(response.data!);
  }

  Future<List<StaffAssignmentHistoryEntry>> getHistory({
    required String eventId,
    required String assignmentId,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/events/$eventId/staff/assignments/$assignmentId/history',
    );
    return response.data!
        .map((item) => StaffAssignmentHistoryEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
