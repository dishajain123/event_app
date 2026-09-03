/// Mirrors `app/modules/config_engine/schemas.py`'s `ConfigurableFieldOut`
/// exactly. `type` is deliberately freeform on the backend (verified
/// directly against the service — only "select" gets any special
/// handling, for its `options` list) — the dynamic field renderer
/// (presentation/widgets/dynamic_field_renderer.dart) renders known types
/// properly and falls back to a plain text input for anything it doesn't
/// recognize yet, never dropping the field.
class ConfigurableField {
  final String key;
  final String label;
  final String type;
  final bool required;
  final List<String>? options;

  const ConfigurableField({
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    required this.options,
  });

  factory ConfigurableField.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>?;
    return ConfigurableField(
      key: json['key'] as String,
      label: json['label'] as String,
      type: json['type'] as String,
      required: json['required'] as bool? ?? false,
      options: rawOptions?.map((o) => o as String).toList(),
    );
  }
}

/// Mirrors `app/modules/config_engine/schemas.py`'s `EventFieldSchemaOut`
/// — note the backend's `fields` is typed `list[dict]` on the wire (not a
/// validated list of ConfigurableFieldOut), so this parses defensively.
class EventFieldSchema {
  final String id;
  final String eventId;
  final String participationType;
  final List<ConfigurableField> fields;

  const EventFieldSchema({
    required this.id,
    required this.eventId,
    required this.participationType,
    required this.fields,
  });

  factory EventFieldSchema.fromJson(Map<String, dynamic> json) {
    final rawFields = json['fields'] as List<dynamic>? ?? [];
    return EventFieldSchema(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      participationType: json['participation_type'] as String,
      fields: rawFields.map((f) => ConfigurableField.fromJson(f as Map<String, dynamic>)).toList(),
    );
  }
}

/// Mirrors `app/modules/config_engine/schemas.py`'s `ValidationErrorItem`
/// and `ValidationResultOut` exactly — the real result of a
/// POST .../configuration/validate dry-run (Section 3, governing
/// principle: eligibility is never re-derived client-side).
class ValidationErrorItem {
  final String field;
  final String message;
  const ValidationErrorItem({required this.field, required this.message});

  factory ValidationErrorItem.fromJson(Map<String, dynamic> json) {
    return ValidationErrorItem(field: json['field'] as String, message: json['message'] as String);
  }
}

class ValidationResult {
  final bool isEligible;
  final List<ValidationErrorItem> errors;
  const ValidationResult({required this.isEligible, required this.errors});

  factory ValidationResult.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['errors'] as List<dynamic>? ?? [];
    return ValidationResult(
      isEligible: json['is_eligible'] as bool,
      errors: rawErrors.map((e) => ValidationErrorItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// A single combined message for a simple inline banner — most
  /// eligibility rejections carry one error, and joining any additional
  /// ones is still readable.
  String get combinedMessage => errors.map((e) => e.message).join(' ');
}
