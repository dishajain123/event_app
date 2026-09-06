import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../application/volunteer_providers.dart';
import '../../data/models/volunteer_application.dart';

class MyVolunteerApplicationsScreen extends ConsumerWidget {
  const MyVolunteerApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(myVolunteerApplicationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Volunteer Applications')),
      body: applications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (items) => items.isEmpty
            ? const Center(
                child:
                    Text('You have not submitted a volunteer application yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.fullName),
                    subtitle: Text(
                        '${item.applicationType == VolunteerApplicationType.eventManager ? 'Event Manager' : 'Volunteer'} · ${item.preferredResponsibility ?? 'Application'}'),
                    trailing: Chip(label: Text(item.status.wireValue)),
                  );
                },
              ),
      ),
    );
  }
}
