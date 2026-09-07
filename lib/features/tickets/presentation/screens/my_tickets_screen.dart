import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/tickets_providers.dart';
import '../../data/models/ticket.dart';

const _ticketStatusTones = {
  TicketStatus.issued: StatusTone.success,
  TicketStatus.checkedIn: StatusTone.accent,
  TicketStatus.cancelled: StatusTone.neutral,
};

class MyTicketsScreen extends ConsumerWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(myTicketsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myTicketsProvider),
        child: ticketsAsync.when(
          loading: () => const AppSkeleton.cardList(),
          error: (error, stackTrace) => ListView(
            children: [
              const SizedBox(height: AppSpacing.xxxl),
              AppErrorState(
                error: error is AppException
                    ? error
                    : UnknownException(error.toString()),
                onRetry: () => ref.invalidate(myTicketsProvider),
              ),
            ],
          ),
          data: (tickets) {
            if (tickets.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: AppSpacing.xxxl),
                  AppEmptyState(
                    icon: Icons.confirmation_number_outlined,
                    title: 'No tickets yet',
                    description:
                        'Once a registration is confirmed, your ticket appears here.',
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: tickets.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () =>
                      context.push(RoutePaths.ticketDetailPath(ticket.id)),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                              color: AppColors.accentSoft,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.confirmation_number_rounded,
                              color: AppColors.accentStrong),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ticket.ticketCode,
                                  style: AppTypography.bodyStrong),
                              if (ticket.checkedInAt != null)
                                Text('Checked in', style: AppTypography.caption)
                              else
                                const Text('Tap to view your barcode',
                                    style: AppTypography.caption),
                            ],
                          ),
                        ),
                        StatusBadge(
                          label: ticket.status.label,
                          tone: _ticketStatusTones[ticket.status] ??
                              StatusTone.neutral,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
