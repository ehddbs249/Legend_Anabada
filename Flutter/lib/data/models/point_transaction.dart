/// 포인트 거래 데이터 모델
/// Spring Boot Entity: PointTransaction (trans_id, user_id, point_change, trans_type, trans_date)
class PointTransaction {
  /// 거래 ID (UUID) ← trans_id
  final String id;

  /// 사용자 ID (UUID) ← user_id
  final String userId;

  /// 포인트 변동량 (양수: 적립, 음수: 차감) ← point_change
  final int pointChange;

  /// 거래 유형 (rental, return, bonus 등) ← trans_type
  final String transType;

  /// 거래 발생 시간 ← trans_date
  final DateTime transDate;

  const PointTransaction({
    required this.id,
    required this.userId,
    required this.pointChange,
    required this.transType,
    required this.transDate,
  });

  /// JSON에서 PointTransaction 객체 생성
  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['trans_id'] as String,
      userId: json['user_id'] as String,
      pointChange: json['point_change'] as int? ?? 0,
      transType: json['trans_type'] as String,
      transDate: DateTime.parse(json['trans_date'] as String),
    );
  }

  /// PointTransaction 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'trans_id': id,
      'user_id': userId,
      'point_change': pointChange,
      'trans_type': transType,
      'trans_date': transDate.toIso8601String(),
    };
  }

  /// PointTransaction 객체 복사 (일부 값 변경 가능)
  PointTransaction copyWith({
    String? id,
    String? userId,
    int? pointChange,
    String? transType,
    DateTime? transDate,
  }) {
    return PointTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pointChange: pointChange ?? this.pointChange,
      transType: transType ?? this.transType,
      transDate: transDate ?? this.transDate,
    );
  }

  /// 포인트 적립 여부 (양수)
  bool get isEarned => pointChange > 0;

  /// 포인트 차감 여부 (음수)
  bool get isSpent => pointChange < 0;

  /// 포인트 변동 없음 (0)
  bool get isNeutral => pointChange == 0;

  /// 거래 유형 한글 표시
  String get transTypeDisplayName {
    switch (transType) {
      case 'rental':
        return '대여';
      case 'return':
        return '반납';
      case 'bonus':
        return '보너스';
      case 'refund':
        return '환불';
      case 'penalty':
        return '패널티';
      case 'signup':
        return '가입 보너스';
      default:
        return transType;
    }
  }

  /// 포인트 표시 (부호 포함)
  String get displayAmount {
    if (pointChange > 0) {
      return '+${pointChange}P';
    } else if (pointChange < 0) {
      return '${pointChange}P';
    } else {
      return '0P';
    }
  }

  /// 절대값 표시
  String get displayAbsoluteAmount {
    return '${pointChange.abs()}P';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PointTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PointTransaction{id: $id, pointChange: $pointChange, transType: $transType}';
  }
}
