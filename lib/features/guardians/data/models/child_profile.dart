/// Mirrors `app/modules/guardians/schemas.py`'s `ChildProfileOut` exactly.
class ChildProfile {
  final String id;
  final String fullName;
  final DateTime dateOfBirth;
  final DateTime createdAt;

  const ChildProfile({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.createdAt,
  });

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  int get ageInYears {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}
