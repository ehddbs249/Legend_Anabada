/// 거래 상태 열거형
enum TransactionStatus {
  pending,    // 대기 중
  active,     // 진행 중
  completed,  // 완료
  cancelled,  // 취소됨
  overdue     // 연체
}

/// 거래 상태 확장
extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return '대기 중';
      case TransactionStatus.active:
        return '진행 중';
      case TransactionStatus.completed:
        return '완료';
      case TransactionStatus.cancelled:
        return '취소됨';
      case TransactionStatus.overdue:
        return '연체';
    }
  }

  String get value {
    switch (this) {
      case TransactionStatus.pending:
        return 'pending';
      case TransactionStatus.active:
        return 'active';
      case TransactionStatus.completed:
        return 'completed';
      case TransactionStatus.cancelled:
        return 'cancelled';
      case TransactionStatus.overdue:
        return 'overdue';
    }
  }

  static TransactionStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return TransactionStatus.pending;
      case 'active':
        return TransactionStatus.active;
      case 'completed':
        return TransactionStatus.completed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      case 'overdue':
        return TransactionStatus.overdue;
      default:
        return TransactionStatus.pending;
    }
  }
}

/// 거래 데이터 모델
class Transaction {
  final String id;
  final String bookId;
  final String lenderId;
  final String borrowerId;
  final int? lockerId;
  final int rentalDays;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? returnDate;
  final TransactionStatus status;
  final String? accessCode;
  final int pointsTransferred;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 관련 데이터 (조인된 데이터)
  final String? bookTitle;
  final String? bookImageUrl;
  final String? lenderName;
  final String? borrowerName;

  const Transaction({
    required this.id,
    required this.bookId,
    required this.lenderId,
    required this.borrowerId,
    this.lockerId,
    required this.rentalDays,
    required this.startDate,
    this.endDate,
    this.returnDate,
    required this.status,
    this.accessCode,
    required this.pointsTransferred,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    // 조인된 데이터
    this.bookTitle,
    this.bookImageUrl,
    this.lenderName,
    this.borrowerName,
  });

  /// JSON에서 Transaction 객체 생성
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      lenderId: json['lender_id'] as String,
      borrowerId: json['borrower_id'] as String,
      lockerId: json['locker_id'] as int?,
      rentalDays: json['rental_days'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      returnDate: json['return_date'] != null
          ? DateTime.parse(json['return_date'] as String)
          : null,
      status: TransactionStatusExtension.fromString(json['status'] as String),
      accessCode: json['access_code'] as String?,
      pointsTransferred: json['points_transferred'] as int,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // 조인된 데이터
      bookTitle: json['book_title'] as String?,
      bookImageUrl: json['book_image_url'] as String?,
      lenderName: json['lender_name'] as String?,
      borrowerName: json['borrower_name'] as String?,
    );
  }

  /// Transaction 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'lender_id': lenderId,
      'borrower_id': borrowerId,
      'locker_id': lockerId,
      'rental_days': rentalDays,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'return_date': returnDate?.toIso8601String(),
      'status': status.value,
      'access_code': accessCode,
      'points_transferred': pointsTransferred,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Transaction 객체 복사 (일부 값 변경 가능)
  Transaction copyWith({
    String? id,
    String? bookId,
    String? lenderId,
    String? borrowerId,
    int? lockerId,
    int? rentalDays,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? returnDate,
    TransactionStatus? status,
    String? accessCode,
    int? pointsTransferred,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bookTitle,
    String? bookImageUrl,
    String? lenderName,
    String? borrowerName,
  }) {
    return Transaction(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      lenderId: lenderId ?? this.lenderId,
      borrowerId: borrowerId ?? this.borrowerId,
      lockerId: lockerId ?? this.lockerId,
      rentalDays: rentalDays ?? this.rentalDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
      accessCode: accessCode ?? this.accessCode,
      pointsTransferred: pointsTransferred ?? this.pointsTransferred,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bookTitle: bookTitle ?? this.bookTitle,
      bookImageUrl: bookImageUrl ?? this.bookImageUrl,
      lenderName: lenderName ?? this.lenderName,
      borrowerName: borrowerName ?? this.borrowerName,
    );
  }

  /// 예상 반납일 계산
  DateTime get expectedReturnDate {
    return startDate.add(Duration(days: rentalDays));
  }

  /// 연체 여부 확인
  bool get isOverdue {
    if (status == TransactionStatus.completed) return false;
    return DateTime.now().isAfter(expectedReturnDate);
  }

  /// 남은 일수 계산
  int get remainingDays {
    if (status == TransactionStatus.completed) return 0;
    final difference = expectedReturnDate.difference(DateTime.now()).inDays;
    return difference < 0 ? 0 : difference;
  }

  /// 연체 일수 계산
  int get overdueDays {
    if (!isOverdue) return 0;
    return DateTime.now().difference(expectedReturnDate).inDays;
  }

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
    return 'Transaction{id: $id, bookId: $bookId, status: ${status.displayName}}';
  }
}