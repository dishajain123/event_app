import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/chips/app_chip.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../application/sponsorship_providers.dart';

/// Providers watched and both navigation targets are unchanged from
/// before — only the presentation was refreshed.
class SponsorshipOpportunitiesScreen extends ConsumerWidget {
  const SponsorshipOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(sponsorshipCategoriesProvider);
    final packages = ref.watch(sponsorshipPackagesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Become a Sponsor')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFD97706), Color(0xFFB45309)],
                ),
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD97706).withValues(alpha: 0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.handshake_rounded,
                      color: Colors.white, size: 32),
                  const SizedBox(height: AppSpacing.md),
                  Text('Support meaningful events',
                      style: AppTypography.headline
                          .copyWith(color: Colors.white)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Connect your brand with communities, participants, and memorable experiences.',
                    style: AppTypography.body
                        .copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text('Sponsorship categories', style: AppTypography.title),
            const SizedBox(height: AppSpacing.sm),
            categories.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Categories are temporarily unavailable.',
                  style: AppTypography.bodyMuted),
              data: (items) => Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final item in items) AppChip(label: item.name),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text('Available packages', style: AppTypography.title),
            const SizedBox(height: AppSpacing.sm),
            packages.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Packages are temporarily unavailable.',
                  style: AppTypography.bodyMuted),
              data: (items) => Column(
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppCard(
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                  color: AppColors.warningSoft,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.star_rounded,
                                  color: AppColors.warning, size: 18),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name,
                                      style: AppTypography.bodyStrong),
                                  const SizedBox(height: 2),
                                  Text(
                                      item.description ??
                                          item.benefits.join(' · '),
                                      style: AppTypography.caption,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Submit Sponsorship Inquiry',
              fullWidth: true,
              size: AppButtonSize.large,
              onPressed: () => context.push(RoutePaths.sponsorshipInquiry),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'View my sponsorship inquiries',
              variant: AppButtonVariant.ghost,
              fullWidth: true,
              onPressed: () =>
                  context.push(RoutePaths.mySponsorshipInquiries),
            ),
          ],
        ),
      ),
    );
  }
}