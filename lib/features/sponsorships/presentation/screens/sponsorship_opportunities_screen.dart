import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/sponsorship_providers.dart';

class SponsorshipOpportunitiesScreen extends ConsumerWidget {
  const SponsorshipOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(sponsorshipCategoriesProvider);
    final packages = ref.watch(sponsorshipPackagesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Become a Sponsor')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const Text('Support meaningful events', style: AppTypography.display),
          const SizedBox(height: AppSpacing.sm),
          const Text(
              'Connect your brand with communities, participants, and memorable experiences.'),
          const SizedBox(height: AppSpacing.xl),
          const Text('Sponsorship categories', style: AppTypography.title),
          const SizedBox(height: AppSpacing.sm),
          categories.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) =>
                const Text('Categories are temporarily unavailable.'),
            data: (items) => Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final item in items) Chip(label: Text(item.name))
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text('Available packages', style: AppTypography.title),
          const SizedBox(height: AppSpacing.sm),
          packages.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) =>
                const Text('Packages are temporarily unavailable.'),
            data: (items) => Column(
              children: [
                for (final item in items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.name, style: AppTypography.bodyStrong),
                    subtitle:
                        Text(item.description ?? item.benefits.join(' · ')),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: () => context.push(RoutePaths.sponsorshipInquiry),
            child: const Text('Submit Sponsorship Inquiry'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => context.push(RoutePaths.mySponsorshipInquiries),
            child: const Text('View my sponsorship inquiries'),
          ),
        ],
      ),
    );
  }
}
