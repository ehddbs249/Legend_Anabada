/// 사용자 데이터 모델
/// Supabase Table: User (user_id, email, password, student_number, department, name, created_at, role, grade)
class User {
  /// 사용자 ID (UUID) ← user_id (Supabase Auth와 연동)
  final String id;

  /// 이메일 주소 ← email
  final String email;

  /// 비밀번호 (Supabase Auth 사용으로 사용하지 않음) ← password
  final String? password;

  /// 학번 ← student_number
  final String studentNumber;

  /// 학과 ← department
  final String department;

  /// 이름 ← name
  final String name;

  /// 계정 생성일 ← created_at
  final DateTime createdAt;

  /// 사용자 역할 (user, admin 등) ← role
  final String role;

  /// 학년 정보 ← grade
  final String? grade;

  const User({
    required this.id,
    required this.email,
    this.password,
    required this.studentNumber,
    required this.department,
    required this.name,
    required this.createdAt,
    required this.role,
    this.grade,
  });

  /// JSON에서 User 객체 생성
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      studentNumber: json['student_number'] as String,
      department: json['department'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      role: json['role'] as String,
      grade: json['grade'] as String?,
    );
  }

  /// User 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'email': email,
      if (password != null) 'password': password,
      'student_number': studentNumber,
      'department': department,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'role': role,
      if (grade != null) 'grade': grade,
    };
  }

  /// User 객체 복사 (일부 값 변경 가능)
  User copyWith({
    String? id,
    String? email,
    String? password,
    String? studentNumber,
    String? department,
    String? name,
    DateTime? createdAt,
    String? role,
    String? grade,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      studentNumber: studentNumber ?? this.studentNumber,
      department: department ?? this.department,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      grade: grade ?? this.grade,
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
    return 'User{id: $id, name: $name, email: $email, role: $role, grade: $grade}';
  }

  /// 관리자 권한 여부
  bool get isAdmin => role == 'admin';

  /// 일반 사용자 권한 여부
  bool get isUser => role == 'user';
}
