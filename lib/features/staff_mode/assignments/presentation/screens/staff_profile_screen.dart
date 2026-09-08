import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/router/route_paths.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/cards/app_card.dart';
import '../../../../../shared/widgets/misc/app_avatar.dart';
import '../../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../../shared/widgets/sheets/confirm_action_sheet.dart';
import '../../../../auth/application/app_mode_controller.dart';
import '../../../../auth/application/auth_state_provider.dart';

/// The Staff Mode side of the switch. Confirms explicitly: switching to
/// Staff Mode is never one-way — this screen's entire purpose is making
/// sure the way back to the ordinary participant experience is exactly as
/// easy to find as the way in was from ProfileScreen. The
/// `switchToPublicMode()` → `context.go` sequence and [_handleLogout]'s
/// confirm-sheet call are unchanged from before.
class StaffProfileScreen extends ConsumerWidget {
  const StaffProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Profile'),
        backgroundColor: AppColors.staffModeAccentSoft,
      ),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AppCard(
                child: Row(
                  children: [
                    AppAvatar(
                      name: user.name?.isNotEmpty == true
                          ? user.name!
                          : user.mobileNumber,
                      size: 56,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              user.name?.isNotEmpty == true
                                  ? user.name!
                                  : 'Staff account',
                              style: AppTypography.title),
                          const SizedBox(height: 2),
                          Text(user.mobileNumber, style: AppTypography.bodyMuted),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.staffModeAccentSoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.shield_rounded,
                                    size: 12, color: AppColors.staffModeAccent),
                                const SizedBox(width: 4),
                                Text('Staff Mode',
                                    style: AppTypography.caption.copyWith(
                                        color: AppColors.staffModeAccent,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                onTap: () async {
                  await ref.read(appModeProvider.notifier).switchToPublicMode();
                  if (context.mounted) context.go(RoutePaths.home);
                },
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.accent, AppColors.accentViolet],
                          ),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.explore_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Switch to Public Mode',
                              style: AppTypography.bodyStrong),
                          SizedBox(height: 2),
                          Text(
                              'Browse and register for events as a participant',
                              style: AppTypography.caption),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.inkSubtle),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppCard(
                onTap: () => _handleLogout(context, ref),
                child: const Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 22, color: AppColors.danger),
                    SizedBox(width: AppSpacing.md),
                    Text('Log out',
                        style: TextStyle(fontSize: 15, color: AppColors.danger)),
                  ],
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