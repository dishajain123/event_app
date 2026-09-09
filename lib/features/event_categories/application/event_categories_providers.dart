import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/providers/discovery_refresh_provider.dart';
import '../data/event_categories_api.dart';
import '../data/event_categories_repository.dart';
import '../data/models/category_models.dart';

final eventCategoriesRepositoryProvider =
    Provider<EventCategoriesRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return EventCategoriesRepository(EventCategoriesApi(dio));
});

/// Backend taxonomy, refreshed on resume and while discovery is visible.
final mainCategoriesProvider =
    FutureProvider.autoDispose<List<MainCategory>>((ref) async {
  ref.watch(discoveryRefreshProvider);
  final repository = ref.watch(eventCategoriesRepositoryProvider);
  return repository.listMainCategories();
});
