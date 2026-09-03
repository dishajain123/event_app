import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/app_exception.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/badges/status_badge.dart';
import '../../../../../shared/widgets/buttons/app_button.dart';
import '../../../../../shared/widgets/sheets/confirm_action_sheet.dart';
import '../../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../../shared/widgets/states/app_error_state.dart';
import '../../../../../shared/widgets/states/app_skeleton.dart';
import '../../../../registrations/application/registrations_providers.dart';
import '../../../../registrations/data/models/registration.dart';
import '../../../../registrations/data/models/registration_status.dart';
import '../../../assignments/application/staff_assignments_providers.dart';
import '../../../assignments/data/models/staff_assignment.dart';
import '../../../../auth/data/models/role_name.dart';

/// Registrations a review action is actually meaningful for — mirrors
/// the console's own DECIDABLE_REGISTRATION_STATUSES exactly, so the
/// queue only ever shows something an Event Manager can act on.
const _decidableStatuses = {RegistrationStatus.submitted, RegistrationStatus.pendingVerification};

final _reviewableEventIdProvider = StateProvider<String?>((ref) => null);

final _eventRegistrationsForReviewProvider = FutureProvider.family<List<AppRegistration>, String>((ref, eventId) async {
  final repository = ref.watch(registrationsRepositoryProvider);
  final all = await repository.listRegistrationsForEvent(eventId);
  return all.where((r) => _decidableStatuses.contains(r.status)).toList();
});

class RegistrationReviewScreen extends ConsumerWidget {
  const RegistrationReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(myStaffAssignmentsProvider);
    final selectedEventId = ref.watch(_reviewableEventIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: SafeArea(
        child: assignmentsAsync.when(
          loading: () => const AppSkeleton.cardList(),
          error: (error, stackTrace) => AppErrorState(
            error: error is AppException ? error : UnknownException(error.toString()),
            onRetry: () => ref.invalidate(myStaffAssignmentsProvider),
          ),
          data: (assignments) {
            // Registration review is Event-Manager-only (confirmed
            // directly against list_entries/registrations' real
            // permission checks) — not open to the broader Staff Mode
            // roles the way check-in is.
            final managedEventIds = assignments
                .where((a) => a.status == StaffAssignmentStatus.active && a.roleName == RoleName.eventManager)
                .map((a) => a.eventId)
                .toSet()
                .toList();

            if (managedEventIds.isEmpty) {
              return const AppEmptyState(
                icon: Icons.fact_check_outlined,
                title: 'No events to review',
                description: 'Registration review is available once you hold an Event Manager assignment.',
              );
            }

            final effectiveEventId = selectedEventId ?? managedEventIds.first;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: DropdownButtonFormField<String>(
                    value: effectiveEventId,
                    items: [
                      for (final id in managedEventIds) DropdownMenuItem(value: id, child: Text(id)),
                    ],
                    onChanged: (value) => ref.read(_reviewableEventIdProvider.notifier).state = value,
                    decoration: const InputDecoration(labelText: 'Event'),
                  ),
                ),
                Expanded(child: _TaskList(eventId: effectiveEventId)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TaskList extends ConsumerWidget {
  final String eventId;
  const _TaskList({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrationsAsync = ref.watch(_eventRegistrationsForReviewProvider(eventId));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_eventRegistrationsForReviewProvider(eventId)),
      child: registrationsAsync.when(
        loading: () => const AppSkeleton.cardList(),
        error: (error, stackTrace) => ListView(
          children: [
            AppErrorState(
              error: error is AppException ? error : UnknownException(error.toString()),
              onRetry: () => ref.invalidate(_eventRegistrationsForReviewProvider(eventId)),
            ),
          ],
        ),
        data: (registrations) {
          if (registrations.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: AppSpacing.xxxl),
                AppEmptyState(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'All caught up',
                  description: 'No registrations are waiting for a decision right now.',
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: registrations.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) => _TaskCard(eventId: eventId, registration: registrations[index]),
          );
        },
      ),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final String eventId;
  final AppRegistration registration;
  const _TaskCard({required this.eventId, required this.registration});

  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    await showConfirmActionSheet(
      context,
      title: 'Approve this registration?',
      confirmLabel: 'Approve',
      onConfirm: (reason) async {
        final repository = ref.read(registrationsRepositoryProvider);
        await repository.approveRegistration(registration.id);
        ref.invalidate(_eventRegistrationsForReviewProvider(eventId));
      },
    );
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    await showConfirmActionSheet(
      context,
      title: 'Reject this registration?',
      description: 'A reason is required and will be visible to the registrant.',
      requireReason: true,
      reasonLabel: 'Reason for rejection',
      confirmLabel: 'Reject',
      danger: true,
      onConfirm: (reason) async {
        final repository = ref.read(registrationsRepositoryProvider);
        await repository.rejectRegistration(registration.id, reason ?? '');
        ref.invalidate(_eventRegistrationsForReviewProvider(eventId));
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  registration.participants.isNotEmpty
                      ? registration.participants.first.fullName
                      : registration.participationType,
                  style: AppTypography.bodyStrong,
                ),
              ),
              StatusBadge(label: registration.status.label, tone: StatusTone.warning),
            ],
          ),
          const SizedBox(height: 4),
          Text(registration.participationType, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Reject',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => _reject(context, ref),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(label: 'Approve', onPressed: () => _approve(context, ref)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
