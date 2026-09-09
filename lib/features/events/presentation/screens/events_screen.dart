import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/chips/app_chip.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../../event_categories/application/event_categories_providers.dart';
import '../../../event_categories/data/models/category_models.dart';
import '../../application/events_providers.dart';
import '../widgets/event_card.dart';

/// Event discovery keeps filtering server-side. The selected taxonomy IDs
/// are sent unchanged to GET /events; Flutter never reconstructs
/// relationships from names or filters an unbounded global dataset
/// locally. State fields ([_mainCategoryId], [_subCategoryId], [_query])
/// and the provider calls built from them are unchanged — only the filter
/// control is now a horizontal chip row instead of two dropdowns.
class EventsScreen extends ConsumerStatefulWidget {
  final String? initialMainCategoryId;
  final String? initialSubCategoryId;
  const EventsScreen({
    super.key,
    this.initialMainCategoryId,
    this.initialSubCategoryId,
  });

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  String? _mainCategoryId;
  String? _subCategoryId;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _mainCategoryId = widget.initialMainCategoryId;
    _subCategoryId = widget.initialSubCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final taxonomy = ref.watch(mainCategoriesProvider);
    // A console deletion/deactivation must not leave an invisible filter active.
    final categories = taxonomy.asData?.value;
    if (categories != null && _mainCategoryId != null) {
      final selected = categories.where((item) => item.id == _mainCategoryId);
      if (selected.isEmpty) {
        _mainCategoryId = null;
        _subCategoryId = null;
      } else if (_subCategoryId != null &&
          !selected.first.subCategories.any((item) => item.id == _subCategoryId)) {
        _subCategoryId = null;
      }
    }
    final events = ref.watch(eventsListProvider(
      (mainCategoryId: _mainCategoryId, subCategoryId: _subCategoryId),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(mainCategoriesProvider);
              ref.invalidate(eventsListProvider((
                mainCategoryId: _mainCategoryId,
                subCategoryId: _subCategoryId,
              )));
            },
          ),
        ],
      ),
      body: AppBackground(
        child: Column(
          children: [
            taxonomy.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => const SizedBox.shrink(),
              data: (categories) => _Filters(
                categories: categories,
                mainCategoryId: _mainCategoryId,
                subCategoryId: _subCategoryId,
                onMainChanged: (id) => setState(() {
                  _mainCategoryId = id;
                  _subCategoryId = null;
                }),
                onSubChanged: (id) => setState(() => _subCategoryId = id),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search loaded events',
                    filled: false,
                    border: InputBorder.none,
                  ),
                  onChanged: (value) =>
                      setState(() => _query = value.trim().toLowerCase()),
                ),
              ),
            ),
            Expanded(
              child: events.when(
                loading: () => const AppSkeleton.cardList(),
                error: (error, _) => AppErrorState(
                  error: error is AppException
                      ? error
                      : UnknownException(error.toString()),
                  onRetry: () => ref.invalidate(eventsListProvider((
                    mainCategoryId: _mainCategoryId,
                    subCategoryId: _subCategoryId,
                  ))),
                ),
                data: (items) {
                  final visible = _query.isEmpty
                      ? items
                      : items
                          .where((item) =>
                              item.name.toLowerCase().contains(_query))
                          .toList();
                  if (visible.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.event_busy_rounded,
                      title: 'No events found',
                      description: _query.isEmpty
                          ? 'Published events for this selection will appear here.'
                          : 'Try a different event name.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: visible.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final event = visible[index];
                      return CompactEventCard(
                        event: event,
                        onTap: () => context
                            .push(RoutePaths.eventDetailPath(event.id)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  final List<MainCategory> categories;
  final String? mainCategoryId;
  final String? subCategoryId;
  final ValueChanged<String?> onMainChanged;
  final ValueChanged<String?> onSubChanged;
  const _Filters({
    required this.categories,
    required this.mainCategoryId,
    required this.subCategoryId,
    required this.onMainChanged,
    required this.onSubChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected =
        categories.where((item) => item.id == mainCategoryId).firstOrNull;
    final subcategories = selected?.subCategories ?? const <SubCategory>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              AppChip(
                label: 'All categories',
                selected: mainCategoryId == null,
                onTap: () => onMainChanged(null),
              ),
              const SizedBox(width: AppSpacing.sm),
              for (final category in categories) ...[
                AppChip(
                  label: category.name,
                  selected: category.id == mainCategoryId,
                  onTap: () => onMainChanged(category.id),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
        if (mainCategoryId != null && subcategories.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: [
                AppChip(
                  label: 'All subcategories',
                  selected: subCategoryId == null,
                  onTap: () => onSubChanged(null),
                ),
                const SizedBox(width: AppSpacing.sm),
                for (final sub in subcategories) ...[
                  AppChip(
                    label: sub.name,
                    selected: sub.id == subCategoryId,
                    onTap: () => onSubChanged(sub.id),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}