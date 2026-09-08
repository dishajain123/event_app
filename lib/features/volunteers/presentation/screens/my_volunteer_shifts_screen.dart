import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/volunteer_shifts_providers.dart';
import '../../data/models/volunteer_shift.dart';

class MyVolunteerShiftsScreen extends ConsumerWidget {
  const MyVolunteerShiftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = ref.watch(myVolunteerShiftsProvider);
    final available = ref.watch(availableVolunteerShiftsProvider);
    final repository = ref.read(volunteerShiftsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Volunteer shifts')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myVolunteerShiftsProvider);
          ref.invalidate(availableVolunteerShiftsProvider);
          await ref.read(myVolunteerShiftsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('My assignments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            mine.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Unable to load assignments: $error'),
              data: (items) {
                if (items.isEmpty) {
                  return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No shift assignments yet.'));
                }
                return Column(
                  children: items
                      .map((item) => Card(
                            child: ListTile(
                              title: Consumer(builder: (context, ref, child) {
                                final detail = ref.watch(
                                    volunteerAssignmentDetailProvider(item.id));
                                return detail.when(
                                    data: (value) => Text(value.shift?.title ??
                                        'Shift assignment'),
                                    loading: () =>
                                        const Text('Loading shift...'),
                                    error: (_, __) =>
                                        const Text('Shift assignment'));
                              }),
                              subtitle:
                                  Consumer(builder: (context, ref, child) {
                                final attendance = ref.watch(
                                    volunteerAttendanceProvider(item.id));
                                return attendance.when(
                                  loading: () => Text(
                                      '${item.status.name} · Loading attendance...'),
                                  error: (_, __) => Text(
                                      '${item.status.name} · Attendance unavailable'),
                                  data: (value) => Text(
                                      '${item.status.name} · ${value?.status.name ?? 'not checked in'}${value?.workedSeconds == null ? '' : ' · ${value!.workedSeconds! ~/ 60} min'}'),
                                );
                              }),
                              trailing: item.status ==
                                      VolunteerAssignmentStatus.approved
                                  ? TextButton(
                                      onPressed: () async {
                                        await repository.checkIn(item.id);
                                        ref.invalidate(
                                            myVolunteerShiftsProvider);
                                      },
                                      child: const Text('Check in'))
                                  : item.status ==
                                          VolunteerAssignmentStatus.active
                                      ? TextButton(
                                          onPressed: () async {
                                            await repository.checkOut(item.id);
                                            ref.invalidate(
                                                myVolunteerShiftsProvider);
                                          },
                                          child: const Text('Check out'))
                                      : null,
                            ),
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Available shifts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            available.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) =>
                  Text('Unable to load available shifts: $error'),
              data: (items) {
                if (items.isEmpty) {
                  return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No open shifts available.'));
                }
                return Column(
                  children: items
                      .map((shift) => Card(
                            child: ListTile(
                              title: Text(shift.title),
                              subtitle: Text(
                                  '${shift.location ?? 'Location to be announced'}\n${shift.startsAt.toLocal()} · ${shift.availableCount} places left'),
                              isThreeLine: true,
                              trailing: TextButton(
                                  onPressed: () async {
                                    await repository.request(shift.id);
                                    ref.invalidate(myVolunteerShiftsProvider);
                                  },
                                  child: const Text('Request')),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
