import '../../../auth/data/models/app_user.dart';
import '../../../event_categories/data/models/category_models.dart';
import 'event_configuration_summary.dart';
import 'event_status.dart';

/// Mirrors `app/modules/events/schemas.py`'s `EventOut` exactly, including
/// the nested `main_category`/`sub_category`/`organizer`/`configuration`
/// summaries that ship inline on this one response — a single
/// GET /events/{id} call carries everything Phase 2's detail screen needs
/// without extra round trips (Section 2.1's note on this exact point).
class AppEvent {
  final String id;
  final String? organizationId;
  final String? organizerUserId;
  final String name;
  final String? description;

  /// Legacy free-text category — retained by the backend for backward
  /// compatibility (Section 2.1) but superseded by [mainCategory]/
  /// [subCategory] wherever both are available.
  final String? category;

  final String? mainCategoryId;
  final String? subCategoryId;
  final MainCategorySummary? mainCategory;
  final SubCategorySummary? subCategory;
  final AppUser? organizer;
  final EventConfigurationSummary? configuration;
  final DateTime startDate;
  final DateTime endDate;
  final EventStatus status;

  const AppEvent({
    required this.id,
    required this.organizationId,
    required this.organizerUserId,
    required this.name,
    required this.description,
    required this.category,
    required this.mainCategoryId,
    required this.subCategoryId,
    required this.mainCategory,
    required this.subCategory,
    required this.organizer,
    required this.configuration,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory AppEvent.fromJson(Map<String, dynamic> json) {
    return AppEvent(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String?,
      organizerUserId: json['organizer_user_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      mainCategoryId: json['main_category_id'] as String?,
      subCategoryId: json['sub_category_id'] as String?,
      mainCategory: json['main_category'] != null
          ? MainCategorySummary.fromJson(
              json['main_category'] as Map<String, dynamic>)
          : null,
      subCategory: json['sub_category'] != null
          ? SubCategorySummary.fromJson(
              json['sub_category'] as Map<String, dynamic>)
          : null,
      organizer: json['organizer'] != null
          ? AppUser.fromJson(json['organizer'] as Map<String, dynamic>)
          : null,
      configuration: json['configuration'] != null
          ? EventConfigurationSummary.fromJson(
              json['configuration'] as Map<String, dynamic>)
          : null,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: EventStatus.fromWire(json['status'] as String),
    );
  }

  /// The exact structured taxonomy label selected in the Console. The
  /// legacy free-text value is only a fallback for older events created
  /// before the category hierarchy existed.
  String? get displayCategory {
    if (mainCategory != null && subCategory != null) {
      return '${mainCategory!.name} / ${subCategory!.name}';
    }
    return subCategory?.name ?? mainCategory?.name ?? category;
  }

  bool get isSameDayEvent {
    return startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day;
  }
}
