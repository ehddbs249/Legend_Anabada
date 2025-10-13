/// 사용자 포인트 잔액 데이터 모델
/// Spring Boot Entity: UserPointBalance (user_id, point_total, total_earned, total_spent)
/// User와 1:1 관계
class UserPointBalance {
  /// 사용자 ID (UUID, PK이자 FK) ← user_id
  final String userId;

  /// 총 포인트 잔액 ← point_total
  final int pointTotal;

  /// 총 획득 포인트 ← total_earned
  final int totalEarned;

  /// 총 사용 포인트 ← total_spent
  final int totalSpent;

  const UserPointBalance({
    required this.userId,
    required this.pointTotal,
    this.totalEarned = 0,
    this.totalSpent = 0,
  });

  /// JSON에서 UserPointBalance 객체 생성
  factory UserPointBalance.fromJson(Map<String, dynamic> json) {
    return UserPointBalance(
      userId: json['user_id'] as String,
      pointTotal: json['point_total'] as int? ?? 0,
      totalEarned: json['total_earned'] as int? ?? 0,
      totalSpent: json['total_spent'] as int? ?? 0,
    );
  }

  /// UserPointBalance 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'point_total': pointTotal,
      'total_earned': totalEarned,
      'total_spent': totalSpent,
    };
  }

  /// UserPointBalance 객체 복사 (일부 값 변경 가능)
  UserPointBalance copyWith({
    String? userId,
    int? pointTotal,
    int? totalEarned,
    int? totalSpent,
  }) {
    return UserPointBalance(
      userId: userId ?? this.userId,
      pointTotal: pointTotal ?? this.pointTotal,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }

  /// 포인트 잔액 표시
  String get displayBalance => '${pointTotal}P';

  /// 포인트 잔액이 충분한지 확인
  bool hasSufficientBalance(int requiredPoints) {
    return pointTotal >= requiredPoints;
  }

  /// 포인트가 0 이하인지 확인
  bool get isEmpty => pointTotal <= 0;

  /// 포인트가 있는지 확인
  bool get hasBalance => pointTotal > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPointBalance &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'UserPointBalance{userId: $userId, pointTotal: $pointTotal}';
  }
}
