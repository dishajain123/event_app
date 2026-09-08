import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/network/app_exception.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/badges/status_badge.dart';
import '../../../../../shared/widgets/buttons/app_button.dart';
import '../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../../shared/widgets/sheets/confirm_action_sheet.dart';
import '../../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../../shared/widgets/states/app_error_state.dart';
import '../../../../../shared/widgets/states/app_skeleton.dart';
import '../../../../auth/application/auth_state_provider.dart';
import '../../application/staff_assignments_providers.dart';
import '../../data/models/staff_assignment.dart';

const _statusTones = {
  StaffAssignmentStatus.invited: StatusTone.warning,
  StaffAssignmentStatus.active: StatusTone.success,
  StaffAssignmentStatus.revoked: StatusTone.neutral,
};

/// Provider watched, the `ref.listen` role-refresh side effect, and
/// [_AssignmentCard._accept]'s `accept()` + `refreshRoles()` calls are all
/// unchanged from before. Only the presentation was refreshed.
class MyStaffEventsScreen extends ConsumerWidget {
  const MyStaffEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(myStaffAssignmentsProvider);
    ref.listen(myStaffAssignmentsProvider, (_, next) {
      if (next.hasValue &&
          next.value!
              .any((item) => item.status == StaffAssignmentStatus.active)) {
        // A manager may activate a volunteer while this session is open.
        // Refresh the authoritative RBAC assignments so the Staff Mode
        // switch appears without forcing a logout/login cycle.
        ref.read(authStateProvider.notifier).refreshRoles();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('My Events')),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(myStaffAssignmentsProvider),
          child: assignmentsAsync.when(
            loading: () => const AppSkeleton.cardList(),
            error: (error, stackTrace) => ListView(
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                AppErrorState(
                  error: error is AppException
                      ? error
                      : UnknownException(error.toString()),
                  onRetry: () => ref.invalidate(myStaffAssignmentsProvider),
                ),
              ],
            ),
            data: (assignments) {
              if (assignments.isEmpty) {
                return ListView(
                  children: const [
                    SizedBox(height: AppSpacing.xxxl),
                    AppEmptyState(
                      icon: Icons.event_note_outlined,
                      title: 'No staff assignments yet',
                      description:
                          "When an Event Manager invites you as staff, it'll show up here.",
                    ),
                  ],
                );
              }

              final pending = assignments
                  .where((a) => a.status == StaffAssignmentStatus.invited)
                  .toList();
              final active = assignments
                  .where((a) => a.status == StaffAssignmentStatus.active)
                  .toList();

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  if (pending.isNotEmpty) ...[
                    const Text('Pending invitations', style: AppTypography.title),
                    const SizedBox(height: AppSpacing.md),
                    for (final assignment in pending) ...[
                      _AssignmentCard(assignment: assignment),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  if (active.isNotEmpty) ...[
                    const Text('Active', style: AppTypography.title),
                    const SizedBox(height: AppSpacing.md),
                    for (final assignment in active) ...[
                      _AssignmentCard(assignment: assignment),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AssignmentCard extends ConsumerWidget {
  final StaffAssignment assignment;
  const _AssignmentCard({required this.assignment});

  Future<void> _accept(BuildContext context, WidgetRef ref) async {
    await showConfirmActionSheet(
      context,
      title: 'Accept this invitation?',
      description:
          'You\'ll gain "${assignment.roleLabel}" access for this event immediately.',
      confirmLabel: 'Accept',
      onConfirm: (reason) async {
        final repository = ref.read(staffAssignmentsRepositoryProvider);
        await repository.accept(assignment.id);
        ref.invalidate(myStaffAssignmentsProvider);
        // A newly-accepted role can change what the mode switch and
        // Staff Mode shell should show — refresh the cached
        // role-assignments immediately rather than waiting for the next
        // natural refetch.
        await ref.read(authStateProvider.notifier).refreshRoles();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = assignment.status == StaffAssignmentStatus.invited;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                    color: AppColors.staffModeAccentSoft,
                    shape: BoxShape.circle),
                child: const Icon(Icons.shield_outlined,
                    color: AppColors.staffModeAccent, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                  child: Text(assignment.roleLabel,
                      style: AppTypography.bodyStrong)),
              StatusBadge(
                label: assignment.status.label,
                tone: _statusTones[assignment.status] ?? StatusTone.neutral,
              ),
            ],
          ),
          if (assignment.roleName != null) ...[
            const SizedBox(height: 4),
            Text(assignment.roleName!.wireValue, style: AppTypography.caption),
          ],
          if (isPending) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
                label: 'Accept',
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => _accept(context, ref)),
          ],
        ],
      ),
    );
  }
}