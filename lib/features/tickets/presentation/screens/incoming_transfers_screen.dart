import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../application/tickets_providers.dart';

class IncomingTransfersScreen extends ConsumerWidget {
  const IncomingTransfersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfers = ref.watch(incomingTicketTransfersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket transfers')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(incomingTicketTransfersProvider),
        child: transfers.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text('Unable to load transfers: $error'),
            ),
          ]),
          data: (items) => items.isEmpty
              ? ListView(children: const [
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: Text('No incoming ticket transfers.')),
                  ),
                ])
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final transfer = items[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ticket ${transfer.ticketId.substring(0, 8)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Event ${transfer.eventId.substring(0, 8)}'),
                            Text('From ${transfer.fromUserId.substring(0, 8)}'),
                            Text('Requested ${transfer.createdAt.toLocal()}'),
                            const SizedBox(height: AppSpacing.sm),
                            Row(children: [
                              FilledButton(
                                onPressed: transfer.status != 'pending'
                                    ? null
                                    : () async {
                                        await ref
                                            .read(ticketsRepositoryProvider)
                                            .respondToTransfer(transfer.id,
                                                accept: true);
                                        ref.invalidate(
                                            incomingTicketTransfersProvider);
                                        ref.invalidate(myTicketsProvider);
                                      },
                                child: const Text('Accept'),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              OutlinedButton(
                                onPressed: transfer.status != 'pending'
                                    ? null
                                    : () async {
                                        await ref
                                            .read(ticketsRepositoryProvider)
                                            .respondToTransfer(transfer.id,
                                                accept: false);
                                        ref.invalidate(
                                            incomingTicketTransfersProvider);
                                      },
                                child: const Text('Reject'),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
