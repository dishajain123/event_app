import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../events/application/events_providers.dart';

class VolunteerOpportunitiesScreen extends ConsumerWidget {
  const VolunteerOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsListProvider(noEventsFilter));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Volunteer'),
        actions: [
          TextButton(
            onPressed: () => context.push(RoutePaths.myVolunteerApplications),
            child: const Text('My applications'),
          ),
        ],
      ),
      body: events.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (items) {
          final open = items
              .where((event) => event.configuration?.volunteerOpen ?? false)
              .toList();
          if (open.isEmpty) {
            return const Center(
                child: Text('No volunteer opportunities are open right now.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: open.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, index) {
              final event = open[index];
              return Card(
                child: ListTile(
                  title: Text(event.name, style: AppTypography.bodyStrong),
                  subtitle: Text(
                      '${event.startDate.toLocal()}\n${event.displayCategory ?? 'Event'}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () =>
                      context.push(RoutePaths.volunteerApplyPath(event.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
