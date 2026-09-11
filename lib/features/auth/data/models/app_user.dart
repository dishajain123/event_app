/// Mirrors `app/modules/identity/schemas.py`'s `UserOut` exactly.
class AppUser {
  final String id;
  final String? mobileNumber;
  final String? name;
  final String? email;
  final DateTime? emailVerifiedAt;
  final bool isActive;

  const AppUser({
    required this.id,
    required this.mobileNumber,
    required this.name,
    required this.email,
    required this.emailVerifiedAt,
    required this.isActive,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      mobileNumber: json['mobile_number'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      emailVerifiedAt: json['email_verified_at'] == null
          ? null
          : DateTime.tryParse(json['email_verified_at'] as String),
      isActive: json['is_active'] as bool,
    );
  }

  AppUser copyWith({String? name, String? email}) {
    return AppUser(
      id: id,
      mobileNumber: mobileNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt,
      isActive: isActive,
    );
  }
}
