import '../../../../core/utils/flexible_decimal.dart';

/// Mirrors `app/modules/config_engine/schemas.py`'s `EventConfigurationOut`
/// in full — unlike `events/data/models/event_configuration_summary.dart`
/// (Phase 2's lightweight embedded version), this is where `rules` and
/// `details` are actually modeled with typed accessors, per this class's
/// original design note in Phase 2: "the full rules/details/field-schema
/// handling belongs in Phase 3's config_engine feature."
///
/// `rules` and `details` stay as raw `Map<String, dynamic>` underneath —
/// exactly the console's own RulesEditor approach — with named getters for
/// the KNOWN keys this app's registration flow actually needs to check
/// client-side for form UX (e.g. showing an age hint), while every other
/// key is preserved untouched. The backend's `/configuration/validate`
/// endpoint remains the only real authority on eligibility (Section 3's
/// governing principle) — these getters are read-only conveniences, never
/// used to reject a submission client-side.
class EventConfiguration {
  final String id;
  final String eventId;
  final List<String> participationTypes;
  final double? feeAmount;
  final String currency;
  final int? capacity;
  final bool approvalRequired;
  final Map<String, dynamic> details;
  final Map<String, dynamic> rules;
  final Map<String, dynamic>? discountRules;

  const EventConfiguration({
    required this.id,
    required this.eventId,
    required this.participationTypes,
    required this.feeAmount,
    required this.currency,
    required this.capacity,
    required this.approvalRequired,
    required this.details,
    required this.rules,
    required this.discountRules,
  });

  factory EventConfiguration.fromJson(Map<String, dynamic> json) {
    final rawTypes = json['participation_types'] as List<dynamic>? ?? [];
    return EventConfiguration(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      participationTypes: rawTypes.map((t) => t as String).toList(),
      feeAmount: parseFlexibleDecimal(json['fee_amount']),
      currency: json['currency'] as String? ?? 'INR',
      capacity: json['capacity'] as int?,
      approvalRequired: json['approval_required'] as bool? ?? false,
      details: (json['details'] as Map<String, dynamic>?) ?? {},
      rules: (json['rules'] as Map<String, dynamic>?) ?? {},
      discountRules: json['discount_rules'] as Map<String, dynamic>?,
    );
  }

  bool get isFree => feeAmount == null || feeAmount == 0;

  // ---- Known rule-key accessors (mirrors the console's RulesEditor) ----

  int? get minAge => rules['min_age'] as int?;
  int? get maxAge => rules['max_age'] as int?;

  int? get minTeamSize => (rules['team_size'] as Map<String, dynamic>?)?['min'] as int?;
  int? get maxTeamSize => (rules['team_size'] as Map<String, dynamic>?)?['max'] as int?;

  List<String> get requiredDocuments {
    final raw = rules['required_documents'] as List<dynamic>?;
    return raw?.map((d) => d as String).toList() ?? [];
  }

  bool get hasAgeRule => minAge != null || maxAge != null;
  bool get hasTeamSizeRule => rules['team_size'] != null;

  // ---- Known details-key accessors ----
  // `details` is entirely freeform (Section 2.1) — these are the only
  // keys this app currently knows how to render on the event detail
  // screen; anything else is simply never displayed, never dropped from
  // the underlying data.
  String? get bannerImageUrl => details['banner_image_url'] as String?;
  String? get contactEmail => details['contact_email'] as String?;
  String? get contactPhone => details['contact_phone'] as String?;
  String? get termsUrl => details['terms_url'] as String?;
}
