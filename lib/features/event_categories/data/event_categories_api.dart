import 'package:dio/dio.dart';
import 'models/category_models.dart';

/// Mirrors `app/modules/event_categories/router.py`'s read endpoints —
/// mobile never writes categories (Section 9.11: category CRUD is
/// Operations Admin/Super Admin console-only).
class EventCategoriesApi {
  final Dio _dio;
  const EventCategoriesApi(this._dio);

  /// Returns the full two-level taxonomy in one call — see
  /// [MainCategory]'s doc comment.
  Future<List<MainCategory>> listMainCategories() async {
    final response = await _dio.get<List<dynamic>>('/event-categories/main');
    return response.data!
        .map((item) => MainCategory.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
