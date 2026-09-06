import '../../../../core/network/dio_exception_mapper.dart';
import 'feedback_api.dart';
import 'models/feedback.dart';

class FeedbackRepository {
  final FeedbackApi _api;
  const FeedbackRepository(this._api);

  Future<List<FeedbackCategoryOption>> listCategories() async {
    try {
      return await _api.listCategories();
    } catch (error) {
      throw mapDioException(error);
    }
  }

  Future<List<EventFeedback>> listMine({String? eventId}) async {
    try {
      return await _api.listMine(eventId: eventId);
    } catch (error) {
      throw mapDioException(error);
    }
  }

  Future<EventFeedback> submit({
    required String eventId,
    required String category,
    required int rating,
    String? comment,
  }) async {
    try {
      return await _api.submit(
          eventId: eventId,
          category: category,
          rating: rating,
          comment: comment);
    } catch (error) {
      throw mapDioException(error);
    }
  }
}
