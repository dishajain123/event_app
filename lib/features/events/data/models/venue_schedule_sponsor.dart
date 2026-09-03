/// Mirrors `app/modules/events/schemas.py`'s `VenueOut` exactly.
class Venue {
  final String id;
  final String eventId;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;

  const Venue({
    required this.id,
    required this.eventId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  bool get hasCoordinates => latitude != null && longitude != null;
}

/// Mirrors `app/modules/events/schemas.py`'s `ScheduleItemOut` exactly.
class ScheduleItem {
  final String id;
  final String eventId;
  final String? venueId;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;

  const ScheduleItem({
    required this.id,
    required this.eventId,
    required this.venueId,
    required this.title,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      venueId: json['venue_id'] as String?,
      title: json['title'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time'] as String) : null,
    );
  }
}

/// Mirrors `app/modules/events/schemas.py`'s `SponsorOut` exactly.
class Sponsor {
  final String id;
  final String eventId;
  final String name;
  final String? tier;
  final String? logoUrl;

  const Sponsor({
    required this.id,
    required this.eventId,
    required this.name,
    required this.tier,
    required this.logoUrl,
  });

  factory Sponsor.fromJson(Map<String, dynamic> json) {
    return Sponsor(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      name: json['name'] as String,
      tier: json['tier'] as String?,
      logoUrl: json['logo_url'] as String?,
    );
  }
}
