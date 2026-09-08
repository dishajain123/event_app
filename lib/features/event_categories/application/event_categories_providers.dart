import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/event_categories_api.dart';
import '../data/event_categories_repository.dart';
import '../data/models/category_models.dart';

final eventCategoriesRepositoryProvider =
    Provider<EventCategoriesRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return EventCategoriesRepository(EventCategoriesApi(dio));
});

/// The full main/sub-category taxonomy — fetched once and cached for the
/// session by Riverpod's default `Provider`/`FutureProvider` caching;
/// categories change rarely enough that re-fetching per screen visit
/// would be wasteful. Screens that need to force a refresh call
/// `ref.invalidate(mainCategoriesProvider)`.
final mainCategoriesProvider = FutureProvider<List<MainCategory>>((ref) async {
  final repository = ref.watch(eventCategoriesRepositoryProvider);
  return repository.listMainCategories();
});
