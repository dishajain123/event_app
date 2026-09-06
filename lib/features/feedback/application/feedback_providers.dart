import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/feedback_api.dart';
import '../data/feedback_repository.dart';
import '../data/models/feedback.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository(FeedbackApi(ref.watch(apiClientProvider)));
});

final feedbackCategoriesProvider =
    FutureProvider<List<FeedbackCategoryOption>>((ref) async {
  return ref.watch(feedbackRepositoryProvider).listCategories();
});

final myFeedbackProvider = FutureProvider<List<EventFeedback>>((ref) async {
  return ref.watch(feedbackRepositoryProvider).listMine();
});

final eventFeedbackProvider =
    FutureProvider.family<List<EventFeedback>, String>((ref, eventId) async {
  return ref.watch(feedbackRepositoryProvider).listMine(eventId: eventId);
});
