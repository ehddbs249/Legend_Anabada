/// 예약 데이터 모델
/// Spring Boot Entity: Reservation (reservation_id, user_id, book_id, reserved_at, expires_at, status)
class Reservation {
  /// 예약 ID (UUID) ← reservation_id
  final String id;

  /// 사용자 ID (UUID) ← user_id
  final String userId;

  /// 책 ID (UUID) ← book_id
  final String bookId;

  /// 예약 생성 시간 ← reserved_at
  final DateTime reservedAt;

  /// 예약 만료 시간 ← expires_at
  final DateTime expiresAt;

  /// 예약 상태 (active, cancelled, completed 등) ← status
  final String status;

  const Reservation({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.reservedAt,
    required this.expiresAt,
    required this.status,
  });

  /// JSON에서 Reservation 객체 생성
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['reservation_id'] as String,
      userId: json['user_id'] as String,
      bookId: json['book_id'] as String,
      reservedAt: DateTime.parse(json['reserved_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      status: json['status'] as String,
    );
  }

  /// Reservation 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'reservation_id': id,
      'user_id': userId,
      'book_id': bookId,
      'reserved_at': reservedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'status': status,
    };
  }

  /// Reservation 객체 복사 (일부 값 변경 가능)
  Reservation copyWith({
    String? id,
    String? userId,
    String? bookId,
    DateTime? reservedAt,
    DateTime? expiresAt,
    String? status,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookId: bookId ?? this.bookId,
      reservedAt: reservedAt ?? this.reservedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
    );
  }

  /// 예약 만료 여부 확인
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// 활성 예약 여부 확인 (상태가 active이고 만료되지 않음)
  bool get isActive => status == 'active' && !isExpired;

  /// 남은 시간 (분 단위)
  int get remainingMinutes {
    if (isExpired) return 0;
    return expiresAt.difference(DateTime.now()).inMinutes;
  }

  /// 예약 상태 한글 표시
  String get statusDisplayName {
    switch (status) {
      case 'active':
        return isExpired ? '만료됨' : '활성';
      case 'cancelled':
        return '취소됨';
      case 'completed':
        return '완료됨';
      default:
        return status;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reservation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Reservation{id: $id, userId: $userId, bookId: $bookId, status: $status}';
  }
}
