import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../../event_categories/application/event_categories_providers.dart';
import '../../../event_categories/data/models/category_models.dart';

/// Home is intentionally taxonomy-only: Home -> main category -> subcategory
/// -> events. All names and IDs are loaded from the public backend API.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(mainCategoriesProvider);
    return Scaffold(
      drawer: const _HomeDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        titleSpacing: 0,
        title: const _BrandMark(),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push(RoutePaths.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push(RoutePaths.profile),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(mainCategoriesProvider),
          child: categories.when(
            loading: () => const AppSkeleton.cardList(),
            error: (error, _) => ListView(
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                AppErrorState(
                  error: error is AppException
                      ? error
                      : UnknownException(error.toString()),
                  onRetry: () => ref.invalidate(mainCategoriesProvider),
                ),
              ],
            ),
            data: (items) => _CategoryHomeContent(categories: items),
          ),
        ),
      ),
    );
  }
}

class _CategoryHomeContent extends StatelessWidget {
  final List<MainCategory> categories;
  const _CategoryHomeContent({required this.categories});

  @override
  Widget build(BuildContext context) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        children: [
          Text('Explore', style: AppTypography.headline),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose a category to discover its subcategories and events.',
            style: AppTypography.captionSubtle,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (categories.isEmpty)
            const _EmptyCategories()
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisExtent: 164,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return _CategoryTile(
                  category: category,
                  index: index,
                  onTap: () => context.push(
                    RoutePaths.mainCategoryPath(category.id),
                  ),
                );
              },
            ),
        ],
      );
}

class _CategoryTile extends StatelessWidget {
  final MainCategory category;
  final int index;
  final VoidCallback onTap;
  const _CategoryTile({
    required this.category,
    required this.index,
    required this.onTap,
  });

  static const _colors = [
    [Color(0xFF155EEF), Color(0xFF3B82F6)],
    [Color(0xFFC026D3), Color(0xFFEC4899)],
    [Color(0xFF047857), Color(0xFF10B981)],
    [Color(0xFFB77900), Color(0xFFE6A700)],
  ];
  static const _icons = [
    Icons.business_center_rounded,
    Icons.groups_rounded,
    Icons.volunteer_activism_rounded,
    Icons.star_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final palette = _colors[index % _colors.length];
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: palette,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: palette.last.withValues(alpha: 0.24),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icons[index % _icons.length],
                  color: Colors.white, size: 30),
              const Spacer(),
              Text(
                category.name,
                style: AppTypography.bodyStrong.copyWith(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                category.description?.trim().isNotEmpty == true
                    ? category.description!
                    : 'Explore this category',
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.84),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories();

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Icon(Icons.category_outlined, size: 44),
              const SizedBox(height: AppSpacing.md),
              Text('No categories available', style: AppTypography.title),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Published categories will appear here when configured by organizers.',
                textAlign: TextAlign.center,
                style: AppTypography.captionSubtle,
              ),
            ],
          ),
        ),
      );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'GO-',
              style:
                  TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
            ),
            TextSpan(
              text: '360°',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      );
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer();

  @override
  Widget build(BuildContext context) => Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const _BrandMark(),
              const SizedBox(height: AppSpacing.xl),
              ListTile(
                leading: const Icon(Icons.event_outlined),
                title: const Text('All events'),
                onTap: () {
                  Navigator.pop(context);
                  context.go(RoutePaths.events);
                },
              ),
              ListTile(
                leading: const Icon(Icons.handshake_outlined),
                title: const Text('Sponsorships'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(RoutePaths.sponsorship);
                },
              ),
              ListTile(
                leading: const Icon(Icons.volunteer_activism_outlined),
                title: const Text('Volunteer'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(RoutePaths.volunteers);
                },
              ),
            ],
          ),
        ),
      );
}
