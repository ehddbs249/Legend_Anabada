/// 거래 데이터 모델
/// Spring Boot Entity: BookTransaction (trans_id, book_id, user_id, trans_status, trans_date, borrower_id)
class Transaction {
  /// 거래 ID (UUID) ← trans_id
  final String id;

  /// 책 ID (UUID) ← book_id
  final String bookId;

  /// 대여자(소유자) 사용자 ID (UUID) ← user_id
  final String userId;

  /// 차용자 사용자 ID (UUID, nullable) ← borrower_id
  final String? borrowerId;

  /// 거래 상태 (pending, active, completed, cancelled) ← trans_status
  final String transStatus;

  /// 거래 일시 ← trans_date
  final DateTime transDate;

  const Transaction({
    required this.id,
    required this.bookId,
    required this.userId,
    this.borrowerId,
    required this.transStatus,
    required this.transDate,
  });

  /// JSON에서 Transaction 객체 생성
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['trans_id'] as String,
      bookId: json['book_id'] as String,
      userId: json['user_id'] as String,
      borrowerId: json['borrower_id'] as String?,
      transStatus: json['trans_status'] as String,
      transDate: DateTime.parse(json['trans_date'] as String),
    );
  }

  /// Transaction 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'trans_id': id,
      'book_id': bookId,
      'user_id': userId,
      'borrower_id': borrowerId,
      'trans_status': transStatus,
      'trans_date': transDate.toIso8601String(),
    };
  }

  /// Transaction 객체 복사 (일부 값 변경 가능)
  Transaction copyWith({
    String? id,
    String? bookId,
    String? userId,
    String? borrowerId,
    String? transStatus,
    DateTime? transDate,
  }) {
    return Transaction(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      borrowerId: borrowerId ?? this.borrowerId,
      transStatus: transStatus ?? this.transStatus,
      transDate: transDate ?? this.transDate,
    );
  }

  /// 거래 상태 한글 표시
  String get transStatusDisplayName {
    switch (transStatus) {
      case 'pending':
        return '대기 중';
      case 'active':
        return '진행 중';
      case 'completed':
        return '완료';
      case 'cancelled':
        return '취소됨';
      case 'overdue':
        return '연체';
      default:
        return '알 수 없음';
    }
  }

  /// 거래 완료 여부
  bool get isCompleted => transStatus == 'completed';

  /// 거래 진행 중 여부
  bool get isActive => transStatus == 'active';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Transaction{id: $id, bookId: $bookId, status: $transStatus}';
  }
}
