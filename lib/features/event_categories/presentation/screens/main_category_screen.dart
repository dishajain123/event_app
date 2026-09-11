import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/utils/pillar_style.dart';
import '../../../../shared/widgets/misc/pressable.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/event_categories_providers.dart';
import '../../data/models/category_models.dart';

/// The screen every pillar tile on Home leads to. Rebuilt to match the rest
/// of the app's visual language — [AppBackground], the same [PillarStyle]
/// gradient/icon identity used on Home's tiles and event covers, and
/// themed list rows — instead of a bare default [Scaffold]/[Card]/
/// [ListTile] stack that read as unstyled boilerplate.
class MainCategoryScreen extends ConsumerWidget {
  final String categoryId;
  const MainCategoryScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxonomy = ref.watch(mainCategoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Category')),
      body: AppBackground(
        child: SafeArea(
          child: taxonomy.when(
            skipLoadingOnReload: true,
            skipError: true,
            loading: () => const AppSkeleton.cardList(),
            error: (error, _) => AppErrorState(
              error: error is AppException
                  ? error
                  : UnknownException(error.toString()),
              onRetry: () => ref.invalidate(mainCategoriesProvider),
            ),
            data: (categories) {
              final category = categories.cast<MainCategory?>().firstWhere(
                    (item) => item?.id == categoryId,
                    orElse: () => null,
                  );
              if (category == null) {
                return const AppEmptyState(
                  icon: Icons.category_outlined,
                  title: 'Category unavailable',
                  description: 'This category is no longer published.',
                );
              }
              return _CategoryContent(category: category);
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryContent extends StatelessWidget {
  final MainCategory category;
  const _CategoryContent({required this.category});

  @override
  Widget build(BuildContext context) {
    final subcategories = category.activeSubCategoriesSorted;
    final style = pillarStyleForCategory(category.name);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      children: [
        _PillarHero(category: category, style: style),
        const SizedBox(height: AppSpacing.xl),
        if (subcategories.isEmpty)
          AppEmptyState(
            icon: Icons.layers_outlined,
            title: 'No subcategories yet',
            description: 'Organizers have not added subcategories here.',
            actionLabel: 'View category events',
            onAction: () =>
                context.push(RoutePaths.categoryEventsPath(category.id)),
          )
        else ...[
          const Text('Browse by topic', style: AppTypography.overline),
          const SizedBox(height: AppSpacing.sm),
          ...subcategories.map(
            (subcategory) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _SubCategoryRow(
                subcategory: subcategory,
                style: style,
                onTap: () => context.push(RoutePaths.categoryEventsPath(
                  category.id,
                  subCategoryId: subcategory.id,
                )),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// The pillar's own gradient identity, carried into its detail screen —
/// the same visual language as Home's tiles and event covers, so arriving
/// here never feels like a different app.
class _PillarHero extends StatelessWidget {
  final MainCategory category;
  final PillarStyle style;
  const _PillarHero({required this.category, required this.style});

  @override
  Widget build(BuildContext context) {
    final description = category.description?.trim();
    final subcategoryCount = category.activeSubCategoriesSorted.length;

    return Container(
      decoration: BoxDecoration(
        gradient: style.gradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: style.solid.withValues(alpha: 0.32),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Icon(style.icon,
                color: Colors.white.withValues(alpha: 0.16), size: 140),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(style.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  category.name,
                  style: AppTypography.headline.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodyMuted.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        subcategoryCount == 1
                            ? '1 topic'
                            : '$subcategoryCount topics',
                        style:
                            AppTypography.caption.copyWith(color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    Pressable(
                      onTap: () => GoRouter.of(context)
                          .push(RoutePaths.categoryEventsPath(category.id)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('All events',
                                style: AppTypography.caption.copyWith(
                                    color: style.solid,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded,
                                size: 13, color: style.solid),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubCategoryRow extends StatelessWidget {
  final SubCategory subcategory;
  final PillarStyle style;
  final VoidCallback onTap;
  const _SubCategoryRow({
    required this.subcategory,
    required this.style,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final description = subcategory.description?.trim();
    final icon = iconForTopic(subcategory.name);

    return Pressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: const Color(0x0A000000)),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: style.solid.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: style.solid, size: 21),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subcategory.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyStrong,
                  ),
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.captionSubtle,
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right_rounded,
                  size: 16, color: AppColors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
