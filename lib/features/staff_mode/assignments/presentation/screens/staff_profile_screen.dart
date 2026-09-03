import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/router/route_paths.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/sheets/confirm_action_sheet.dart';
import '../../../../auth/application/app_mode_controller.dart';
import '../../../../auth/application/auth_state_provider.dart';

/// The Staff Mode side of the switch. Confirms explicitly what was raised
/// before this phase was built: switching to Staff Mode is never one-way —
/// this screen's entire purpose is making sure the way back to the
/// ordinary participant experience is exactly as easy to find as the way
/// in was from ProfileScreen.
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(color: AppColors.staffModeAccentSoft, shape: BoxShape.circle),
                  child: const Icon(Icons.shield_outlined, size: 28, color: AppColors.staffModeAccent),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name?.isNotEmpty == true ? user.name! : 'Staff account', style: AppTypography.title),
                    const SizedBox(height: 2),
                    Text(user.mobileNumber, style: AppTypography.bodyMuted),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                await ref.read(appModeProvider.notifier).switchToPublicMode();
                if (context.mounted) context.go(RoutePaths.home);
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                      child: const Icon(Icons.explore_outlined, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Switch to Public Mode', style: AppTypography.bodyStrong),
                          SizedBox(height: 2),
                          Text('Browse and register for events as a participant', style: AppTypography.caption),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.inkSubtle),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _handleLogout(context, ref),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 22, color: AppColors.danger),
                    SizedBox(width: AppSpacing.md),
                    Text('Log out', style: TextStyle(fontSize: 15, color: AppColors.danger)),
                  ],
                ),
              ),
            ),
          ],
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
