/// Mirrors `app/modules/media/models.py`'s `MediaType` StrEnum exactly —
/// three values, not two.
enum MediaType {
  image('image'),
  video('video'),
  other('other');

  final String wireValue;
  const MediaType(this.wireValue);

  static MediaType fromWire(String value) {
    return MediaType.values.firstWhere(
      (t) => t.wireValue == value,
      orElse: () => MediaType.other,
    );
  }
}

/// Mirrors `app/modules/media/schemas.py`'s `HighlightOut` exactly.
class Highlight {
  final String id;
  final String eventId;
  final String mediaId;
  final String title;
  final String? description;
  final bool isActive;
  final int displayOrder;

  const Highlight({
    required this.id,
    required this.eventId,
    required this.mediaId,
    required this.title,
    required this.description,
    required this.isActive,
    required this.displayOrder,
  });

  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      mediaId: json['media_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
      displayOrder: json['display_order'] as int,
    );
  }
}

/// Mirrors `app/modules/media/schemas.py`'s `MediaOut` exactly. Mobile
/// only ever fetches this via the public/optional-auth path (Section 2.6,
/// 2.7) — published items only, since the app never authenticates as an
/// event-manage-capable staff account in the sense that endpoint checks
/// for; every media item this app ever sees is already publish-approved.
class EventMedia {
  final String id;
  final String eventId;
  final String title;
  final String? caption;
  final String? category;
  final MediaType mediaType;
  final String publicUrl;
  final bool isPublished;
  final int sortOrder;
  final Highlight? highlight;

  const EventMedia({
    required this.id,
    required this.eventId,
    required this.title,
    required this.caption,
    required this.category,
    required this.mediaType,
    required this.publicUrl,
    required this.isPublished,
    required this.sortOrder,
    required this.highlight,
  });

  factory EventMedia.fromJson(Map<String, dynamic> json) {
    return EventMedia(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      title: json['title'] as String,
      caption: json['caption'] as String?,
      category: json['category'] as String?,
      mediaType: MediaType.fromWire(json['media_type'] as String),
      publicUrl: json['public_url'] as String,
      isPublished: json['is_published'] as bool,
      sortOrder: json['sort_order'] as int,
      highlight: json['highlight'] != null ? Highlight.fromJson(json['highlight'] as Map<String, dynamic>) : null,
    );
  }

  bool get isHighlight => highlight != null && highlight!.isActive;
}
