import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/referrals_providers.dart';
import '../../data/models/referral.dart';

/// Deliberately uses the built-in clipboard rather than a native share
/// sheet (which would need the `share_plus` package — one more
/// third-party API this sandbox can't verify against real installed
/// source, on top of the mobile platform integrations.
/// connectivity_plus already carrying that caveat). Copy-to-clipboard is
/// a genuine, complete, dependency-free way to share a code today;
/// upgrading to a native share sheet is a reasonable later polish item,
/// not a functional gap.
const _statusTones = {
  ReferralRewardStatus.tracked: StatusTone.info,
  ReferralRewardStatus.qualified: StatusTone.warning,
  ReferralRewardStatus.issued: StatusTone.success,
  ReferralRewardStatus.flagged: StatusTone.danger,
};

class MyReferralScreen extends ConsumerWidget {
  final String eventId;
  const MyReferralScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralAsync = ref.watch(myReferralProvider(eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Refer & Earn')),
      body: SafeArea(
        child: referralAsync.when(
          loading: () => const AppSkeleton.detailPage(),
          error: (error, stackTrace) => AppErrorState(
            error: error is AppException
                ? error
                : UnknownException(error.toString()),
            onRetry: () => ref.invalidate(myReferralProvider(eventId)),
          ),
          data: (referral) => ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentStrong]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your referral code',
                      style: AppTypography.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      referral.profile.referralCode,
                      style: AppTypography.display
                          .copyWith(color: Colors.white, letterSpacing: 2),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Copy code',
                      variant: AppButtonVariant.secondary,
                      onPressed: () async {
                        await Clipboard.setData(
                            ClipboardData(text: referral.profile.referralCode));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Copied — share it with a friend.')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                '${referral.profile.totalRewardsIssued} reward${referral.profile.totalRewardsIssued == 1 ? '' : 's'} issued so far',
                style: AppTypography.bodyStrong,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (referral.rewards.isEmpty)
                const Text(
                    'No referrals tracked yet — share your code to get started.',
                    style: AppTypography.bodyMuted)
              else
                for (final reward in referral.rewards)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Reward: ${reward.rewardValue.toStringAsFixed(0)}',
                            style: AppTypography.body,
                          ),
                        ),
                        StatusBadge(
                          label: reward.status.label,
                          tone:
                              _statusTones[reward.status] ?? StatusTone.neutral,
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
