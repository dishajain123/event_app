import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/misc/app_avatar.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/sheets/confirm_action_sheet.dart';
import '../../../auth/application/app_mode_controller.dart';
import '../../../auth/application/auth_state_provider.dart';

/// The auth state watched, [_handleLogout]'s confirm-sheet call, and the
/// Staff Mode switch's `switchToStaffMode()` → `context.go(staffScan)`
/// sequence are all unchanged from before. Every route pushed from a menu
/// tile is the same route as before, including "Volunteer shifts", which
/// now goes through the same [_ProfileMenuTile] as every other row instead
/// of a one-off [ListTile].
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (authState is! AuthAuthenticated) {
      // Router redirect handles this in practice — this is just a safe
      // fallback so the screen never renders against null user data.
      return const Scaffold(body: SizedBox.shrink());
    }

    final user = authState.user;
    final roles = authState.roles;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _ProfileHeader(
                  name: user.name,
                  mobileNumber: user.mobileNumber ?? user.email ?? 'Account',
                  onTap: () => context.push(RoutePaths.editProfile)),
              const SizedBox(height: AppSpacing.xl),

              // The Staff Mode switch — only ever shown for an account that
              // actually holds a Staff-Mode-capable role for at least one
              // event. A plain participant account never sees this section
              // at all, not even disabled.
              if (roles.hasStaffModeAccess) ...[
                const _SectionLabel('Staff access'),
                _StaffModeSwitchTile(eventCount: roles.staffModeEventIds.length),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Pending staff invitations must be reachable before the user
              // has an active staff role. The backend still decides whether
              // an invitation belongs to this user and whether it can be
              // accepted.
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: AppCard(
                  onTap: () => context.push(RoutePaths.staffAccess),
                  child: Row(
                    children: [
                      const Icon(Icons.badge_outlined, color: AppColors.ink),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          roles.hasStaffModeAccess
                              ? 'Staff access and invitations'
                              : 'Staff invitations',
                          style: AppTypography.body,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.inkSubtle),
                    ],
                  ),
                ),
              ),

              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    _ProfileMenuTile(
                      icon: Icons.child_care_rounded,
                      label: 'My Children',
                      onTap: () => context.push(RoutePaths.myChildren),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.groups_rounded,
                      label: 'My Teams',
                      onTap: () => context.push(RoutePaths.myTeams),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.notifications_none_rounded,
                      label: 'Notifications',
                      onTap: () => context.push(RoutePaths.notifications),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Ticket transfers',
                      onTap: () => context.push(RoutePaths.ticketTransfers),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.queue_outlined,
                      label: 'My Waitlists',
                      onTap: () => context.push(RoutePaths.myWaitlists),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.work_history_outlined,
                      label: 'Volunteer shifts',
                      onTap: () => context.push(RoutePaths.myVolunteerShifts),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.rate_review_outlined,
                      label: 'My Feedback',
                      onTap: () => context.push(RoutePaths.myFeedback),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.workspace_premium_outlined,
                      label: 'Certificates & badges',
                      onTap: () => context.push(RoutePaths.certificates),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.volunteer_activism_outlined,
                      label: 'Assistance Requests',
                      onTap: () => context.push(RoutePaths.assistanceRequests),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.badge_outlined,
                      label: 'Identity documents',
                      onTap: () => context.push(RoutePaths.identityDocuments),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      onTap: () => context.push(RoutePaths.appSettings),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _ProfileMenuTile(
                  icon: Icons.logout_rounded,
                  label: 'Log out',
                  danger: true,
                  onTap: () => _handleLogout(context, ref),
                  isLast: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    await showConfirmActionSheet(
      context,
      title: 'Log out?',
      description: "You'll need to verify your mobile number again next time.",
      confirmLabel: 'Log out',
      danger: true,
      onConfirm: (reason) => ref.read(authStateProvider.notifier).logout(),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String? name;
  final String mobileNumber;
  final VoidCallback onTap;
  const _ProfileHeader(
      {required this.name, required this.mobileNumber, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          AppAvatar(
            name: name?.isNotEmpty == true ? name! : mobileNumber,
            size: 56,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name?.isNotEmpty == true ? name! : 'Add your name',
                    style: AppTypography.title),
                const SizedBox(height: 2),
                Text(mobileNumber, style: AppTypography.bodyMuted),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.inkSubtle),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text.toUpperCase(),
          style: AppTypography.overline),
    );
  }
}

/// The actual switch action, from the Public Mode side. Deliberately does
/// two things together, in order: set the mode, THEN navigate — so the
/// router's redirect guard never sees a mismatched state where the
/// location is a Staff Mode route but the mode still reads Public.
class _StaffModeSwitchTile extends ConsumerWidget {
  final int eventCount;
  const _StaffModeSwitchTile({required this.eventCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () async {
          await ref.read(appModeProvider.notifier).switchToStaffMode();
          if (context.mounted) context.go(RoutePaths.staffScan);
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.staffModeAccentSoft,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
                color: AppColors.staffModeAccent.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: AppColors.staffModeAccent, shape: BoxShape.circle),
                child: const Icon(Icons.shield_outlined,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Switch to Staff Mode',
                        style: AppTypography.bodyStrong),
                    const SizedBox(height: 2),
                    Text(
                      eventCount == 1
                          ? 'You have staff access for 1 event'
                          : 'You have staff access for $eventCount events',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.inkSubtle),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;
  final bool isLast;

  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.ink;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                  Icon(icon,
                      size: 22,
                      color: onTap == null ? AppColors.inkSubtle : color),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.body.copyWith(
                          color: onTap == null ? AppColors.inkSubtle : color),
                    ),
                  ),
                  if (onTap != null)
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.inkSubtle),
                ],
              ),
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}