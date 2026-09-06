import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../application/sponsorship_providers.dart';

class MySponsorshipInquiriesScreen extends ConsumerWidget {
  const MySponsorshipInquiriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inquiries = ref.watch(mySponsorshipInquiriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Sponsorship Inquiries')),
      body: inquiries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (items) => items.isEmpty
            ? const Center(
                child:
                    Text('You have not submitted a sponsorship inquiry yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.companyName),
                    subtitle: Text(
                        '${item.contactPerson} · ${item.eventIds.length} event(s)'),
                    trailing: Chip(label: Text(item.status)),
                  );
                },
              ),
      ),
    );
  }
}
