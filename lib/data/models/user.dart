/// 사용자 데이터 모델
class User {
  final String id;
  final String email;
  final String universityEmail;
  final String name;
  final String studentId;
  final int points;
  final String? university;
  final String? department;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.universityEmail,
    required this.name,
    required this.studentId,
    required this.points,
    this.university,
    this.department,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON에서 User 객체 생성
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      universityEmail: json['university_email'] as String,
      name: json['name'] as String,
      studentId: json['student_id'] as String,
      points: json['points'] as int? ?? 1000,
      university: json['university'] as String?,
      department: json['department'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// User 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'university_email': universityEmail,
      'name': name,
      'student_id': studentId,
      'points': points,
      'university': university,
      'department': department,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// User 객체 복사 (일부 값 변경 가능)
  User copyWith({
    String? id,
    String? email,
    String? universityEmail,
    String? name,
    String? studentId,
    int? points,
    String? university,
    String? department,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      universityEmail: universityEmail ?? this.universityEmail,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      points: points ?? this.points,
      university: university ?? this.university,
      department: department ?? this.department,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, points: $points}';
  }
}