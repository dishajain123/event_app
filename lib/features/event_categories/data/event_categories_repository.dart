import '../../../core/network/dio_exception_mapper.dart';
import 'event_categories_api.dart';
import 'models/category_models.dart';

class EventCategoriesRepository {
  final EventCategoriesApi _api;
  const EventCategoriesRepository(this._api);

  Future<List<MainCategory>> listMainCategories() async {
    try {
      return await _api.listMainCategories();
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
