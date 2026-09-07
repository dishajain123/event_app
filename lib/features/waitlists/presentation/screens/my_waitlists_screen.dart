import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../application/waitlists_providers.dart';
import '../../data/models/waitlist_entry.dart';

class MyWaitlistsScreen extends ConsumerWidget {
  const MyWaitlistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myWaitlistsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My waitlists')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (entries) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(myWaitlistsProvider),
          child: entries.isEmpty
              ? ListView(children: const [
                  Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Text('You have no waitlist entries.'))
                ])
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) =>
                      _EntryTile(entry: entries[index]),
                ),
        ),
      ),
    );
  }
}

class _EntryTile extends ConsumerWidget {
  final WaitlistEntry entry;
  const _EntryTile({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = entry.status == WaitlistStatus.waiting ||
        entry.status == WaitlistStatus.promoted;
    return Card(
      child: ListTile(
        title: Text('Event ${entry.eventId}'),
        subtitle: Text(
            '${entry.participationType} · ${entry.status.wireValue}${entry.position == null ? '' : ' · position ${entry.position}'}'),
        trailing: active
            ? TextButton(
                onPressed: () async {
                  await ref.read(waitlistsRepositoryProvider).leave(entry.id);
                  ref.invalidate(myWaitlistsProvider);
                },
                child: const Text('Leave'))
            : null,
      ),
    );
  }
}
