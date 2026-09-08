import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/volunteer_shifts_api.dart';
import '../data/volunteer_shifts_repository.dart';
import '../data/models/volunteer_shift.dart';

final volunteerShiftsRepositoryProvider = Provider((ref) =>
    VolunteerShiftsRepository(
        VolunteerShiftsApi(ref.watch(apiClientProvider))));
final availableVolunteerShiftsProvider = FutureProvider<List<VolunteerShift>>(
    (ref) => ref.watch(volunteerShiftsRepositoryProvider).available());
final myVolunteerShiftsProvider =
    FutureProvider<List<VolunteerShiftAssignment>>(
        (ref) => ref.watch(volunteerShiftsRepositoryProvider).mine());
final volunteerAttendanceProvider =
    FutureProvider.family<VolunteerAttendance?, String>((ref, id) =>
        ref.watch(volunteerShiftsRepositoryProvider).attendance(id));
final volunteerAssignmentDetailProvider =
    FutureProvider.family<VolunteerShiftAssignment, String>(
        (ref, id) => ref.watch(volunteerShiftsRepositoryProvider).detail(id));
