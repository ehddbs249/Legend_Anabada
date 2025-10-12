/// 수요 예측 데이터 모델
/// Spring Boot Entity: PredForecast (pred_id, book_id, pred_demand, pred_basis, pred_at, semester)
/// AI 예측 결과 저장용 (Phase 4)
class PredForecast {
  /// 예측 ID (UUID) ← pred_id
  final String id;

  /// 책 ID (UUID) ← book_id
  final String bookId;

  /// 예측 수요량 ← pred_demand
  final int predDemand;

  /// 예측 근거 (nullable) ← pred_basis
  final String? predBasis;

  /// 예측 생성 시간 ← pred_at
  final DateTime predAt;

  /// 학기 정보 (예: "2024-1", "2024-2") ← semester
  final String semester;

  const PredForecast({
    required this.id,
    required this.bookId,
    required this.predDemand,
    this.predBasis,
    required this.predAt,
    required this.semester,
  });

  /// JSON에서 PredForecast 객체 생성
  factory PredForecast.fromJson(Map<String, dynamic> json) {
    return PredForecast(
      id: json['pred_id'] as String,
      bookId: json['book_id'] as String,
      predDemand: json['pred_demand'] as int? ?? 0,
      predBasis: json['pred_basis'] as String?,
      predAt: DateTime.parse(json['pred_at'] as String),
      semester: json['semester'] as String,
    );
  }

  /// PredForecast 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'pred_id': id,
      'book_id': bookId,
      'pred_demand': predDemand,
      if (predBasis != null) 'pred_basis': predBasis,
      'pred_at': predAt.toIso8601String(),
      'semester': semester,
    };
  }

  /// PredForecast 객체 복사 (일부 값 변경 가능)
  PredForecast copyWith({
    String? id,
    String? bookId,
    int? predDemand,
    String? predBasis,
    DateTime? predAt,
    String? semester,
  }) {
    return PredForecast(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      predDemand: predDemand ?? this.predDemand,
      predBasis: predBasis ?? this.predBasis,
      predAt: predAt ?? this.predAt,
      semester: semester ?? this.semester,
    );
  }

  /// 수요 수준 한글 표시
  String get demandLevel {
    if (predDemand >= 100) return '매우 높음';
    if (predDemand >= 50) return '높음';
    if (predDemand >= 20) return '보통';
    if (predDemand >= 10) return '낮음';
    return '매우 낮음';
  }

  /// 수요 레벨 (0-5 단계)
  int get demandLevelScore {
    if (predDemand >= 100) return 5;
    if (predDemand >= 50) return 4;
    if (predDemand >= 20) return 3;
    if (predDemand >= 10) return 2;
    if (predDemand > 0) return 1;
    return 0;
  }

  /// 예측 신뢰도가 높은지 (근거가 있는지)
  bool get hasReliableBasis => predBasis != null && predBasis!.isNotEmpty;

  /// 수요가 높은지 (50 이상)
  bool get isHighDemand => predDemand >= 50;

  /// 수요가 보통 이상인지 (20 이상)
  bool get isModerateOrHighDemand => predDemand >= 20;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredForecast &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PredForecast{id: $id, bookId: $bookId, predDemand: $predDemand, semester: $semester}';
  }
}
