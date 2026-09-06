enum SponsorshipInquiryStatus {
  newRequest('new'),
  reviewing('reviewing'),
  approved('approved'),
  confirmed('confirmed'),
  rejected('rejected'),
  closed('closed');

  final String wireValue;
  const SponsorshipInquiryStatus(this.wireValue);

  static SponsorshipInquiryStatus fromWire(String value) =>
      SponsorshipInquiryStatus.values.firstWhere(
        (status) => status.wireValue == value,
        orElse: () => SponsorshipInquiryStatus.newRequest,
      );
}

class SponsorshipCategory {
  final String id;
  final String name;
  final String? description;

  const SponsorshipCategory(
      {required this.id, required this.name, required this.description});

  factory SponsorshipCategory.fromJson(Map<String, dynamic> json) =>
      SponsorshipCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
      );
}

class SponsorshipPackage {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final List<String> benefits;

  const SponsorshipPackage({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.benefits,
  });

  factory SponsorshipPackage.fromJson(Map<String, dynamic> json) =>
      SponsorshipPackage(
        id: json['id'] as String,
        categoryId: json['category_id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        benefits: (json['benefits'] as List<dynamic>? ?? []).cast<String>(),
      );
}

class SponsorshipInquiry {
  final String id;
  final String companyName;
  final String contactPerson;
  final String email;
  final String status;
  final List<String> eventIds;
  final DateTime createdAt;

  const SponsorshipInquiry({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.email,
    required this.status,
    required this.eventIds,
    required this.createdAt,
  });

  factory SponsorshipInquiry.fromJson(Map<String, dynamic> json) =>
      SponsorshipInquiry(
        id: json['id'] as String,
        companyName: json['company_name'] as String,
        contactPerson: json['contact_person'] as String,
        email: json['email'] as String,
        status: json['status'] as String,
        eventIds: (json['event_ids'] as List<dynamic>? ?? []).cast<String>(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
