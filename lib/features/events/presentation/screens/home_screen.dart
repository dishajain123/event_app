import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cards/piller_card.dart';
import '../../../../shared/widgets/misc/section_header.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../../auth/application/auth_state_provider.dart';
import '../../../event_categories/application/event_categories_providers.dart';
import '../../../event_categories/data/models/category_models.dart';
import '../../application/events_providers.dart';
import '../widgets/event_card.dart';

/// Home is intentionally taxonomy-only: Home -> main category -> subcategory
/// -> events. All names and IDs are loaded from the public backend API.
/// The one addition here is a real, backend-driven "Upcoming across
/// GO-360°" strip, fetched from the same [eventsListProvider] the Events
/// tab already uses with no filter — no mock data, no new endpoints.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(mainCategoriesProvider);
    final authState = ref.watch(authStateProvider);
    final greetingName = authState is AuthAuthenticated
        ? (authState.user.name?.trim().isNotEmpty == true
            ? authState.user.name!.trim().split(' ').first
            : null)
        : null;

    return Scaffold(
      drawer: const _HomeDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
            style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.7)),
          ),
        ),
        titleSpacing: 0,
        title: const _BrandMark(),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push(RoutePaths.search),
            style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push(RoutePaths.notifications),
            style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push(RoutePaths.profile),
            style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(mainCategoriesProvider);
              ref.invalidate(eventsListProvider(noEventsFilter));
            },
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
              data: (items) => _CategoryHomeContent(
                categories: items,
                greetingName: greetingName,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryHomeContent extends ConsumerWidget {
  final List<MainCategory> categories;
  final String? greetingName;
  const _CategoryHomeContent({required this.categories, this.greetingName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = ref.watch(eventsListProvider(noEventsFilter));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      children: [
        Text(
          greetingName != null ? 'Hi, $greetingName 👋' : 'Welcome',
          style: AppTypography.hero.copyWith(fontSize: 28, height: 34 / 28),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'One GO-ID. All of GO-360°. Pick a pillar to explore.',
          style: AppTypography.bodyMuted,
        ),
        const SizedBox(height: AppSpacing.xl),
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
        const SizedBox(height: AppSpacing.xxl),
        upcoming.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (events) {
            if (events.isEmpty) return const SizedBox.shrink();
            final visible = events.take(8).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  eyebrow: 'GO-360°',
                  title: 'Upcoming across the league',
                  onSeeAll: () => context.push(RoutePaths.events),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: visible.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final event = visible[index];
                      return SizedBox(
                        width: 260,
                        child: FeaturedEventCard(
                          event: event,
                          onTap: () => context
                              .push(RoutePaths.eventDetailPath(event.id)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
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

  static const _gradients = [
    AppColors.pillarCorporate,
    AppColors.pillarCommunity,
    AppColors.pillarContribute,
    AppColors.pillarLive,
  ];
  static const _icons = [
    Icons.business_center_rounded,
    Icons.groups_rounded,
    Icons.volunteer_activism_rounded,
    Icons.star_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return PillarCard(
      title: category.name,
      subtitle: category.description?.trim().isNotEmpty == true
          ? category.description!
          : 'Explore this category',
      icon: _icons[index % _icons.length],
      gradient: _gradients[index % _gradients.length],
      onTap: onTap,
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: const Column(
          children: [
            Icon(Icons.category_outlined,
                size: 44, color: AppColors.inkSubtle),
            SizedBox(height: AppSpacing.md),
            Text('No categories available', style: AppTypography.title),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Published categories will appear here when configured by organizers.',
              textAlign: TextAlign.center,
              style: AppTypography.captionSubtle,
            ),
          ],
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
        backgroundColor: AppColors.surface,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const _BrandMark(),
              const SizedBox(height: AppSpacing.xs),
              const Text('People · Purpose · Progress',
                  style: AppTypography.captionSubtle),
              const SizedBox(height: AppSpacing.xl),
              _DrawerTile(
                icon: Icons.event_outlined,
                label: 'All events',
                onTap: () {
                  Navigator.pop(context);
                  context.go(RoutePaths.events);
                },
              ),
              _DrawerTile(
                icon: Icons.handshake_outlined,
                label: 'Sponsorships',
                onTap: () {
                  Navigator.pop(context);
                  context.push(RoutePaths.sponsorship);
                },
              ),
              _DrawerTile(
                icon: Icons.volunteer_activism_outlined,
                label: 'Volunteer',
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

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          leading: Icon(icon, color: AppColors.inkMuted),
          title: Text(label, style: AppTypography.bodyStrong),
          onTap: onTap,
        ),
      ),
    );
  }
}
