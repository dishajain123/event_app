import 'package:dio/dio.dart';
import 'models/feedback.dart';

class FeedbackApi {
  final Dio _dio;
  const FeedbackApi(this._dio);

  Future<List<FeedbackCategoryOption>> listCategories() async {
    final response = await _dio.get<List<dynamic>>('/feedback/categories');
    return response.data!
        .map((item) =>
            FeedbackCategoryOption.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<EventFeedback>> listMine({String? eventId}) async {
    final response = await _dio.get<List<dynamic>>(
      '/feedback/mine',
      queryParameters: {if (eventId != null) 'event_id': eventId},
    );
    return response.data!
        .map((item) => EventFeedback.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<EventFeedback> submit({
    required String eventId,
    required String category,
    required int rating,
    String? comment,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/feedback',
      data: {
        'event_id': eventId,
        'category': category,
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      },
    );
    return EventFeedback.fromJson(response.data!);
  }
}
