import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../application/volunteer_shifts_providers.dart';
import '../../data/models/volunteer_shift.dart';

/// All three providers watched ([myVolunteerShiftsProvider],
/// [availableVolunteerShiftsProvider], and — nested per-row —
/// [volunteerAssignmentDetailProvider] / [volunteerAttendanceProvider])
/// and the `checkIn`/`checkOut`/`request` repository calls are unchanged
/// from before, including the nested-[Consumer] structure that keeps each
/// row's shift-detail and attendance lookups independent. Only the
/// presentation was refreshed.
class MyVolunteerShiftsScreen extends ConsumerWidget {
  const MyVolunteerShiftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = ref.watch(myVolunteerShiftsProvider);
    final available = ref.watch(availableVolunteerShiftsProvider);
    final repository = ref.read(volunteerShiftsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Volunteer Shifts')),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myVolunteerShiftsProvider);
            ref.invalidate(availableVolunteerShiftsProvider);
            await ref.read(myVolunteerShiftsProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const Text('My assignments', style: AppTypography.title),
              const SizedBox(height: AppSpacing.md),
              mine.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text('Unable to load assignments: $error',
                    style: AppTypography.bodyMuted),
                data: (items) {
                  if (items.isEmpty) {
                    return const Text('No shift assignments yet.',
                        style: AppTypography.bodyMuted);
                  }
                  return Column(
                    children: [
                      for (final item in items)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                      color: AppColors.accentSoft,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.event_available_rounded,
                                      color: AppColors.accentStrong, size: 18),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Consumer(
                                          builder: (context, ref, child) {
                                        final detail = ref.watch(
                                            volunteerAssignmentDetailProvider(
                                                item.id));
                                        return Text(
                                          detail.when(
                                            data: (value) =>
                                                value.shift?.title ??
                                                'Shift assignment',
                                            loading: () => 'Loading shift…',
                                            error: (_, __) =>
                                                'Shift assignment',
                                          ),
                                          style: AppTypography.bodyStrong,
                                        );
                                      }),
                                      const SizedBox(height: 2),
                                      Consumer(
                                          builder: (context, ref, child) {
                                        final attendance = ref.watch(
                                            volunteerAttendanceProvider(
                                                item.id));
                                        return Text(
                                          attendance.when(
                                            loading: () =>
                                                '${item.status.name} · Loading attendance…',
                                            error: (_, __) =>
                                                '${item.status.name} · Attendance unavailable',
                                            data: (value) =>
                                                '${item.status.name} · ${value?.status.name ?? 'not checked in'}${value?.workedSeconds == null ? '' : ' · ${value!.workedSeconds! ~/ 60} min'}',
                                          ),
                                          style: AppTypography.caption,
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                if (item.status ==
                                    VolunteerAssignmentStatus.approved)
                                  AppButton(
                                    label: 'Check in',
                                    variant: AppButtonVariant.secondary,
                                    onPressed: () async {
                                      await repository.checkIn(item.id);
                                      ref.invalidate(
                                          myVolunteerShiftsProvider);
                                    },
                                  )
                                else if (item.status ==
                                    VolunteerAssignmentStatus.active)
                                  AppButton(
                                    label: 'Check out',
                                    variant: AppButtonVariant.secondary,
                                    onPressed: () async {
                                      await repository.checkOut(item.id);
                                      ref.invalidate(
                                          myVolunteerShiftsProvider);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text('Available shifts', style: AppTypography.title),
              const SizedBox(height: AppSpacing.md),
              available.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text(
                    'Unable to load available shifts: $error',
                    style: AppTypography.bodyMuted),
                data: (items) {
                  if (items.isEmpty) {
                    return const Text('No open shifts available.',
                        style: AppTypography.bodyMuted);
                  }
                  return Column(
                    children: [
                      for (final shift in items)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                      color: AppColors.accentSoft,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.schedule_rounded,
                                      color: AppColors.accentStrong, size: 18),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(shift.title,
                                          style: AppTypography.bodyStrong),
                                      const SizedBox(height: 2),
                                      Text(
                                          shift.location ??
                                              'Location to be announced',
                                          style: AppTypography.caption),
                                      const SizedBox(height: 2),
                                      Text(
                                          '${shift.startsAt.toLocal()} · ${shift.availableCount} places left',
                                          style: AppTypography.captionSubtle),
                                    ],
                                  ),
                                ),
                                AppButton(
                                  label: 'Request',
                                  onPressed: () async {
                                    await repository.request(shift.id);
                                    ref.invalidate(myVolunteerShiftsProvider);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}