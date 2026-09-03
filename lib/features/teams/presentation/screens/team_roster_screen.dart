import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/sheets/confirm_action_sheet.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../application/teams_providers.dart';
import '../../data/models/team.dart';

const _teamStatusTones = {
  TeamStatus.draft: StatusTone.neutral,
  TeamStatus.inviting: StatusTone.warning,
  TeamStatus.submitted: StatusTone.accent,
  TeamStatus.approved: StatusTone.success,
  TeamStatus.rejected: StatusTone.danger,
};

class TeamRosterScreen extends ConsumerWidget {
  final String teamId;
  const TeamRosterScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = ref.watch(teamDetailProvider(teamId));
    final membersAsync = ref.watch(teamMembersProvider(teamId));

    return Scaffold(
      appBar: AppBar(title: const Text('Team')),
      body: SafeArea(
        child: teamAsync.when(
          loading: () => const AppSkeleton.detailPage(),
          error: (error, stackTrace) => AppErrorState(
            error: error is AppException ? error : UnknownException(error.toString()),
            onRetry: () => ref.invalidate(teamDetailProvider(teamId)),
          ),
          data: (team) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(teamDetailProvider(teamId));
              ref.invalidate(teamMembersProvider(teamId));
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Row(
                  children: [
                    Expanded(child: Text(team.name, style: AppTypography.headline)),
                    StatusBadge(label: team.status.label, tone: _teamStatusTones[team.status] ?? StatusTone.neutral),
                  ],
                ),
                if (team.rejectionReason != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(team.rejectionReason!, style: AppTypography.body.copyWith(color: AppColors.danger)),
                ],
                const SizedBox(height: AppSpacing.xl),
                Text('Members', style: AppTypography.title),
                const SizedBox(height: AppSpacing.md),
                membersAsync.when(
                  loading: () => const AppSkeleton.cardList(count: 2),
                  error: (error, stackTrace) => AppErrorState(
                    error: error is AppException ? error : UnknownException(error.toString()),
                    onRetry: () => ref.invalidate(teamMembersProvider(teamId)),
                  ),
                  data: (members) => Column(
                    children: [
                      for (final member in members)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              const Icon(Icons.person_rounded, size: 18, color: AppColors.inkSubtle),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(child: Text(member.fullName, style: AppTypography.body)),
                              if (member.isCaptain)
                                const StatusBadge(label: 'Captain', tone: StatusTone.accent),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (team.status == TeamStatus.draft || team.status == TeamStatus.inviting) ...[
                  AppButton(
                    label: 'Invite member',
                    variant: AppButtonVariant.secondary,
                    fullWidth: true,
                    onPressed: () => _showInviteSheet(context, ref),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Submit team',
                    fullWidth: true,
                    onPressed: () => _submitTeam(context, ref, team),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showInviteSheet(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.xl,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invite a member', style: AppTypography.headline),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: controller,
                label: 'Mobile number',
                keyboardType: TextInputType.phone,
                autofocus: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Send invite',
                fullWidth: true,
                onPressed: () async {
                  final normalized = tryNormalizeMobileNumber(controller.text);
                  if (normalized == null) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(content: Text('Enter a valid mobile number.')),
                    );
                    return;
                  }
                  try {
                    final repository = ref.read(teamsRepositoryProvider);
                    await repository.inviteMember(teamId, normalized);
                    ref.invalidate(teamMembersProvider(teamId));
                    if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                  } on AppException catch (e) {
                    if (sheetContext.mounted) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(SnackBar(content: Text(e.message)));
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitTeam(BuildContext context, WidgetRef ref, AppTeam team) async {
    await showConfirmActionSheet(
      context,
      title: 'Submit "${team.name}"?',
      description: 'Your roster will be locked for review once submitted.',
      confirmLabel: 'Submit team',
      onConfirm: (reason) async {
        final repository = ref.read(teamsRepositoryProvider);
        await repository.submitTeam(teamId);
        ref.invalidate(teamDetailProvider(teamId));
      },
    );
  }
}
