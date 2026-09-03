import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../data/models/staff_assignment.dart';
import '../data/staff_assignments_api.dart';
import '../data/staff_assignments_repository.dart';

final staffAssignmentsRepositoryProvider = Provider<StaffAssignmentsRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return StaffAssignmentsRepository(StaffAssignmentsApi(dio));
});

final myStaffAssignmentsProvider = FutureProvider<List<StaffAssignment>>((ref) async {
  final repository = ref.watch(staffAssignmentsRepositoryProvider);
  return repository.listMine();
});

typedef HistoryQuery = ({String eventId, String assignmentId});

final staffAssignmentHistoryProvider = FutureProvider.family<List<StaffAssignmentHistoryEntry>, HistoryQuery>(
  (ref, query) async {
    final repository = ref.watch(staffAssignmentsRepositoryProvider);
    return repository.getHistory(eventId: query.eventId, assignmentId: query.assignmentId);
  },
);
