import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/event_categories_providers.dart';
import '../../data/models/category_models.dart';

class MainCategoryScreen extends ConsumerWidget {
  final String categoryId;
  const MainCategoryScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxonomy = ref.watch(mainCategoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Category')),
      body: taxonomy.when(
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
    );
  }
}

class _CategoryContent extends StatelessWidget {
  final MainCategory category;
  const _CategoryContent({required this.category});

  @override
  Widget build(BuildContext context) {
    final subcategories = category.subCategories;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(category.name, style: AppTypography.headline),
        if (category.description?.trim().isNotEmpty == true) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(category.description!, style: AppTypography.captionSubtle),
        ],
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
        else
          ...subcategories.map(
            (subcategory) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  leading: const CircleAvatar(
                    child: Icon(Icons.grid_view_rounded),
                  ),
                  title: Text(
                    subcategory.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: subcategory.description == null
                      ? null
                      : Text(
                          subcategory.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(RoutePaths.categoryEventsPath(
                    category.id,
                    subCategoryId: subcategory.id,
                  )),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
