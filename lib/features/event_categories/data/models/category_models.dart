/// Mirrors `app/modules/event_categories/schemas.py`'s `SubCategoryOut`
/// exactly.
class SubCategory {
  final String id;
  final String mainCategoryId;
  final String name;
  final String? description;
  final bool isActive;

  const SubCategory({
    required this.id,
    required this.mainCategoryId,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] as String,
      mainCategoryId: json['main_category_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
    );
  }
}

/// Mirrors `app/modules/event_categories/schemas.py`'s `MainCategoryOut`
/// exactly — note `sub_categories` is nested directly, so a single
/// GET /event-categories/main call returns the full two-level taxonomy
/// (Section 9.3).
class MainCategory {
  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final List<SubCategory> subCategories;

  const MainCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.subCategories,
  });

  factory MainCategory.fromJson(Map<String, dynamic> json) {
    final rawSubCategories = json['sub_categories'] as List<dynamic>? ?? [];
    return MainCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
      subCategories: rawSubCategories
          .map((s) => SubCategory.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Mirrors `app/modules/events/schemas.py`'s `MainCategorySummary` — the
/// lightweight shape embedded directly on `EventOut`, distinct from the
/// full [MainCategory] the category-browse screen uses.
class MainCategorySummary {
  final String id;
  final String name;
  const MainCategorySummary({required this.id, required this.name});

  factory MainCategorySummary.fromJson(Map<String, dynamic> json) {
    return MainCategorySummary(
        id: json['id'] as String, name: json['name'] as String);
  }
}

/// Mirrors `app/modules/events/schemas.py`'s `SubCategorySummary`.
class SubCategorySummary {
  final String id;
  final String mainCategoryId;
  final String name;
  const SubCategorySummary(
      {required this.id, required this.mainCategoryId, required this.name});

  factory SubCategorySummary.fromJson(Map<String, dynamic> json) {
    return SubCategorySummary(
      id: json['id'] as String,
      mainCategoryId: json['main_category_id'] as String,
      name: json['name'] as String,
    );
  }
}
