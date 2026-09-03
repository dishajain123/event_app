import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../../event_categories/application/event_categories_providers.dart';
import '../../application/events_providers.dart';
import '../widgets/event_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsListProvider(noEventsFilter));
    final categoriesAsync = ref.watch(mainCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push(RoutePaths.search),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(eventsListProvider(noEventsFilter));
          ref.invalidate(mainCategoriesProvider);
        },
        child: eventsAsync.when(
          loading: () => const AppSkeleton.cardList(),
          error: (error, stackTrace) => ListView(
            children: [
              const SizedBox(height: AppSpacing.xxxl),
              AppErrorState(
                error: error is AppException ? error : UnknownException(error.toString()),
                onRetry: () => ref.invalidate(eventsListProvider(noEventsFilter)),
              ),
            ],
          ),
          data: (events) => ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            children: [
              // Category chips (Section 8, Phase 2) — tapping one navigates
              // to Search & Filter pre-filtered, rather than duplicating
              // filtering logic on this screen too.
              categoriesAsync.when(
                loading: () => const SizedBox(height: 40),
                error: (_, __) => const SizedBox.shrink(),
                data: (categories) => SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ActionChip(
                        label: Text(category.name),
                        onPressed: () => context.push(
                          RoutePaths.search,
                          extra: {'mainCategoryId': category.id, 'mainCategoryName': category.name},
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              if (events.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xxxl),
                  child: Center(
                    child: Text('No events published yet — check back soon.', style: AppTypography.bodyMuted),
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text('Upcoming events', style: AppTypography.title),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final event in events)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: FeaturedEventCard(
                      event: event,
                      onTap: () => context.push(RoutePaths.eventDetailPath(event.id)),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
