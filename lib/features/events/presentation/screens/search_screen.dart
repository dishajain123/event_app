import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/events_providers.dart';
import '../widgets/event_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialMainCategoryId;
  final String? initialMainCategoryName;

  const SearchScreen(
      {super.key, this.initialMainCategoryId, this.initialMainCategoryName});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _mainCategoryId;
  String? _mainCategoryName;

  @override
  void initState() {
    super.initState();
    _mainCategoryId = widget.initialMainCategoryId;
    _mainCategoryName = widget.initialMainCategoryName;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearCategoryFilter() {
    setState(() {
      _mainCategoryId = null;
      _mainCategoryName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The backend has no free-text search parameter (Section 9.3) — the
    // category filter is a real query param sent to the backend, while
    // the text query is applied client-side over whatever that call
    // returns, the same pattern the web console uses for its own list
    // screens without a backend search endpoint.
    final eventsAsync = ref.watch(
      eventsListProvider(
          (mainCategoryId: _mainCategoryId, subCategoryId: null)),
    );

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: widget.initialMainCategoryId == null,
          decoration: const InputDecoration(
            hintText: 'Search events…',
            border: InputBorder.none,
          ),
          onChanged: (value) =>
              setState(() => _query = value.trim().toLowerCase()),
        ),
      ),
      body: Column(
        children: [
          if (_mainCategoryName != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  label: Text(_mainCategoryName!),
                  onDeleted: _clearCategoryFilter,
                ),
              ),
            ),
          Expanded(
            child: eventsAsync.when(
              loading: () => const AppSkeleton.cardList(),
              error: (error, stackTrace) => AppErrorState(
                error: error is AppException
                    ? error
                    : UnknownException(error.toString()),
                onRetry: () => ref.invalidate(
                  eventsListProvider(
                      (mainCategoryId: _mainCategoryId, subCategoryId: null)),
                ),
              ),
              data: (events) {
                final filtered = _query.isEmpty
                    ? events
                    : events
                        .where((e) => e.name.toLowerCase().contains(_query))
                        .toList();

                if (filtered.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: events.isEmpty ? 'No events found' : 'No matches',
                    description: events.isEmpty
                        ? 'Try a different category or check back later.'
                        : 'Try a different search term.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final event = filtered[index];
                    return CompactEventCard(
                      event: event,
                      onTap: () =>
                          context.push(RoutePaths.eventDetailPath(event.id)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
