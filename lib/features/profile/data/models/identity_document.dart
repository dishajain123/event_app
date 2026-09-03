/// Mirrors `app/modules/identity/models.py`'s `DocumentType` StrEnum
/// exactly.
enum DocumentType {
  aadhaar('aadhaar'),
  pan('pan'),
  drivingLicence('driving_licence'),
  passport('passport'),
  other('other');

  final String wireValue;
  const DocumentType(this.wireValue);

  static DocumentType fromWire(String value) {
    return DocumentType.values.firstWhere(
      (t) => t.wireValue == value,
      orElse: () => DocumentType.other,
    );
  }

  String get label => switch (this) {
        DocumentType.aadhaar => 'Aadhaar',
        DocumentType.pan => 'PAN',
        DocumentType.drivingLicence => 'Driving Licence',
        DocumentType.passport => 'Passport',
        DocumentType.other => 'Other',
      };
}

/// Mirrors `VerificationStatus` exactly.
enum VerificationStatus {
  pending('pending'),
  verified('verified'),
  rejected('rejected');

  final String wireValue;
  const VerificationStatus(this.wireValue);

  static VerificationStatus fromWire(String value) {
    return VerificationStatus.values.firstWhere(
      (s) => s.wireValue == value,
      orElse: () => throw FormatException('Unknown verification status from backend: $value'),
    );
  }

  String get label => switch (this) {
        VerificationStatus.pending => 'Pending review',
        VerificationStatus.verified => 'Verified',
        VerificationStatus.rejected => 'Rejected',
      };
}

/// Mirrors `IdentityDocumentOut` exactly — deliberately does NOT include
/// the document number (the backend never returns it once submitted,
/// since it's encrypted at rest; confirmed directly against the schema).
class IdentityDocument {
  final String id;
  final DocumentType documentType;
  final VerificationStatus verificationStatus;

  const IdentityDocument({
    required this.id,
    required this.documentType,
    required this.verificationStatus,
  });

  factory IdentityDocument.fromJson(Map<String, dynamic> json) {
    return IdentityDocument(
      id: json['id'] as String,
      documentType: DocumentType.fromWire(json['document_type'] as String),
      verificationStatus: VerificationStatus.fromWire(json['verification_status'] as String),
    );
  }
}
