import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/certificates_providers.dart';

/// Providers watched and the navigation to certificate detail are
/// unchanged from before — this was previously a bare-spinner /
/// `Text('Unable to load...: $error')` screen; it now matches the rest
/// of the app's loading/error/card conventions.
class CertificatesScreen extends ConsumerWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificates = ref.watch(myCertificatesProvider);
    final badges = ref.watch(myBadgesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: AppBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myCertificatesProvider);
            ref.invalidate(myBadgesProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const Text('Certificates', style: AppTypography.title),
              const SizedBox(height: AppSpacing.md),
              certificates.when(
                loading: () => const AppSkeleton.cardList(count: 2),
                error: (error, _) => AppErrorState(
                  error: error is AppException
                      ? error
                      : UnknownException(error.toString()),
                  onRetry: () => ref.invalidate(myCertificatesProvider),
                ),
                data: (items) => items.isEmpty
                    ? const Text('No certificates issued yet.',
                        style: AppTypography.bodyMuted)
                    : Column(
                        children: [
                          for (final item in items)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
                              child: AppCard(
                                onTap: () => context.push(
                                    RoutePaths.certificateDetail.replaceFirst(
                                        ':certificateId', item.id),
                                    extra: item),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFFF59E0B),
                                              Color(0xFFB45309)
                                            ],
                                          ),
                                          shape: BoxShape.circle),
                                      child: const Icon(
                                          Icons.workspace_premium_rounded,
                                          color: Colors.white,
                                          size: 20),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item.certificateNumber,
                                              style:
                                                  AppTypography.bodyStrong),
                                          const SizedBox(height: 2),
                                          Text('Status: ${item.status}',
                                              style: AppTypography.caption),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded,
                                        color: AppColors.inkSubtle),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text('Achievement badges', style: AppTypography.title),
              const SizedBox(height: AppSpacing.md),
              badges.when(
                loading: () => const AppSkeleton.cardList(count: 2),
                error: (error, _) => AppErrorState(
                  error: error is AppException
                      ? error
                      : UnknownException(error.toString()),
                  onRetry: () => ref.invalidate(myBadgesProvider),
                ),
                data: (items) => items.isEmpty
                    ? const Text('No badges awarded yet.',
                        style: AppTypography.bodyMuted)
                    : Column(
                        children: [
                          for (final item in items)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
                              child: AppCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: const BoxDecoration(
                                          color: AppColors.accentSoft,
                                          shape: BoxShape.circle),
                                      child: const Icon(
                                          Icons.verified_rounded,
                                          color: AppColors.accentStrong,
                                          size: 20),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Badge ${item.badgeId.substring(0, 8)}',
                                              style:
                                                  AppTypography.bodyStrong),
                                          const SizedBox(height: 2),
                                          Text('Status: ${item.status}',
                                              style: AppTypography.caption),
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
            ],
          ),
        ),
      ),
    );
  }
}