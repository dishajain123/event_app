import 'package:dio/dio.dart';
import 'models/volunteer_shift.dart';

class VolunteerShiftsApi {
  final Dio _dio;
  const VolunteerShiftsApi(this._dio);
  Future<List<VolunteerShift>> available() async {
    final r = await _dio.get<Map<String, dynamic>>(
        '/volunteer-shifts/available',
        queryParameters: {'page': 1, 'page_size': 100});
    return ((r.data?['items'] as List<dynamic>?) ?? [])
        .map((x) => VolunteerShift.fromJson(x))
        .toList();
  }

  Future<List<VolunteerShiftAssignment>> mine() async {
    final r = await _dio.get<Map<String, dynamic>>(
        '/volunteer-shifts/assignments/mine',
        queryParameters: {'page': 1, 'page_size': 100});
    return ((r.data?['items'] as List<dynamic>?) ?? [])
        .map((x) => VolunteerShiftAssignment.fromJson(x))
        .toList();
  }

  Future<VolunteerShiftAssignment> request(String shiftId) async {
    final r = await _dio
        .post<Map<String, dynamic>>('/volunteer-shifts/$shiftId/request');
    return VolunteerShiftAssignment.fromJson(r.data!);
  }

  Future<VolunteerShiftAssignment> detail(String assignmentId) async {
    final r = await _dio.get<Map<String, dynamic>>(
        '/volunteer-shifts/assignments/$assignmentId');
    return VolunteerShiftAssignment.fromJson(r.data!);
  }

  Future<VolunteerShiftAssignment> cancel(String assignmentId) async {
    final r = await _dio.patch<Map<String, dynamic>>(
        '/volunteer-shifts/assignments/$assignmentId/status',
        data: {'status': 'cancelled'});
    return VolunteerShiftAssignment.fromJson(r.data!);
  }

  Future<VolunteerAttendance> checkIn(String assignmentId) async {
    final r = await _dio.post<Map<String, dynamic>>(
        '/volunteer-shifts/assignments/$assignmentId/check-in');
    return VolunteerAttendance.fromJson(r.data!);
  }

  Future<VolunteerAttendance> checkOut(String assignmentId) async {
    final r = await _dio.post<Map<String, dynamic>>(
        '/volunteer-shifts/assignments/$assignmentId/check-out');
    return VolunteerAttendance.fromJson(r.data!);
  }

  Future<VolunteerAttendance?> attendance(String assignmentId) async {
    final r = await _dio.get<Map<String, dynamic>>(
        '/volunteer-shifts/assignments/$assignmentId/attendance');
    return r.data == null ? null : VolunteerAttendance.fromJson(r.data!);
  }
}
