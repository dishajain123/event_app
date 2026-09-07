enum VolunteerShiftStatus { draft, open, full, inProgress, completed, cancelled }
enum VolunteerAssignmentStatus { requested, approved, active, completed, rejected, cancelled }
enum VolunteerAttendanceStatus { notCheckedIn, checkedIn, checkedOut, noShow, cancelled }

String _value(Object value) => value.toString().split('.').last.replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');
VolunteerShiftStatus shiftStatus(String value) => VolunteerShiftStatus.values.firstWhere((v) => _value(v) == value, orElse: () => VolunteerShiftStatus.draft);
VolunteerAssignmentStatus assignmentStatus(String value) => VolunteerAssignmentStatus.values.firstWhere((v) => _value(v) == value, orElse: () => VolunteerAssignmentStatus.requested);
VolunteerAttendanceStatus attendanceStatus(String value) => VolunteerAttendanceStatus.values.firstWhere((v) => _value(v) == value, orElse: () => VolunteerAttendanceStatus.notCheckedIn);

class VolunteerShift {
  final String id, eventId, title; final String? location, requiredRole; final DateTime startsAt, endsAt; final int requiredCount, assignedCount, availableCount; final VolunteerShiftStatus status;
  const VolunteerShift({required this.id, required this.eventId, required this.title, required this.location, required this.requiredRole, required this.startsAt, required this.endsAt, required this.requiredCount, required this.assignedCount, required this.availableCount, required this.status});
  factory VolunteerShift.fromJson(Map<String, dynamic> j) => VolunteerShift(id: j['id'], eventId: j['event_id'], title: j['title'], location: j['location'], requiredRole: j['required_role'], startsAt: DateTime.parse(j['starts_at']), endsAt: DateTime.parse(j['ends_at']), requiredCount: j['required_count'], assignedCount: j['assigned_count'] ?? 0, availableCount: j['available_count'] ?? 0, status: shiftStatus(j['status']));
}

class VolunteerShiftAssignment {
  final String id, eventId, shiftId, userId; final VolunteerAssignmentStatus status; final DateTime? checkInAt, checkOutAt; final VolunteerShift? shift;
  const VolunteerShiftAssignment({required this.id, required this.eventId, required this.shiftId, required this.userId, required this.status, required this.checkInAt, required this.checkOutAt, this.shift});
  factory VolunteerShiftAssignment.fromJson(Map<String, dynamic> j) => VolunteerShiftAssignment(id: j['id'], eventId: j['event_id'], shiftId: j['shift_id'], userId: j['user_id'], status: assignmentStatus(j['status']), checkInAt: j['check_in_at'] == null ? null : DateTime.parse(j['check_in_at']), checkOutAt: j['check_out_at'] == null ? null : DateTime.parse(j['check_out_at']), shift: j['shift'] == null ? null : VolunteerShift.fromJson(j['shift'] as Map<String, dynamic>));
}

class VolunteerAttendance {
  final VolunteerAttendanceStatus status; final DateTime? firstCheckInAt, finalCheckOutAt; final int? workedSeconds;
  const VolunteerAttendance({required this.status, required this.firstCheckInAt, required this.finalCheckOutAt, required this.workedSeconds});
  factory VolunteerAttendance.fromJson(Map<String, dynamic> j) => VolunteerAttendance(status: attendanceStatus(j['status']), firstCheckInAt: j['first_check_in_at'] == null ? null : DateTime.parse(j['first_check_in_at']), finalCheckOutAt: j['final_check_out_at'] == null ? null : DateTime.parse(j['final_check_out_at']), workedSeconds: j['worked_seconds']);
}
