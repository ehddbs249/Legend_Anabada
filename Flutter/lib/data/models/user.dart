/// 사용자 데이터 모델
/// Spring Boot Entity: User (user_id, email, password, student_number, department, name, created_at, role, verify, expiryDate)
class User {
  /// 사용자 ID (UUID) ← user_id
  final String id;

  /// 이메일 주소 ← email
  final String email;

  /// 비밀번호 (보안상 API 응답에 포함되지 않을 수 있음) ← password
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

  /// 이메일 인증 여부 ← verify
  final bool verify;

  /// 인증 토큰 만료 시간 ← expiryDate (nullable)
  final DateTime? expiryDate;

  const User({
    required this.id,
    required this.email,
    this.password,
    required this.studentNumber,
    required this.department,
    required this.name,
    required this.createdAt,
    required this.role,
    this.verify = false,
    this.expiryDate,
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
      verify: json['verify'] as bool? ?? false,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
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
      'verify': verify,
      if (expiryDate != null) 'expiryDate': expiryDate!.toIso8601String(),
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
    bool? verify,
    DateTime? expiryDate,
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
      verify: verify ?? this.verify,
      expiryDate: expiryDate ?? this.expiryDate,
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
    return 'User{id: $id, name: $name, email: $email, role: $role, verify: $verify}';
  }

  /// 이메일 인증 완료 여부
  bool get isVerified => verify;

  /// 이메일 인증 대기 중
  bool get isPendingVerification => !verify;

  /// 인증 토큰 만료 여부 확인
  bool get isTokenExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// 인증 토큰 유효 여부
  bool get isTokenValid {
    if (expiryDate == null) return false;
    return DateTime.now().isBefore(expiryDate!);
  }

  /// 관리자 권한 여부
  bool get isAdmin => role == 'admin';

  /// 일반 사용자 권한 여부
  bool get isUser => role == 'user';
}
