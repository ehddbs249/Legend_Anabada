/// 시스템 로그 데이터 모델
/// Spring Boot Entity: SystemLog (log_id, locker_id, user_id, event_type, occurred_at, result_status)
class SystemLog {
  /// 로그 ID (UUID) ← log_id
  final String id;

  /// 사물함 ID (UUID) ← locker_id
  final String lockerId;

  /// 사용자 ID (UUID) ← user_id
  final String userId;

  /// 이벤트 유형 (open, close, deposit, retrieve 등) ← event_type
  final String eventType;

  /// 이벤트 발생 시간 ← occurred_at
  final DateTime occurredAt;

  /// 결과 상태 (success, failure 등) ← result_status
  final String resultStatus;

  const SystemLog({
    required this.id,
    required this.lockerId,
    required this.userId,
    required this.eventType,
    required this.occurredAt,
    required this.resultStatus,
  });

  /// JSON에서 SystemLog 객체 생성
  factory SystemLog.fromJson(Map<String, dynamic> json) {
    return SystemLog(
      id: json['log_id'] as String,
      lockerId: json['locker_id'] as String,
      userId: json['user_id'] as String,
      eventType: json['event_type'] as String,
      occurredAt: DateTime.parse(json['occurred_at'] as String),
      resultStatus: json['result_status'] as String,
    );
  }

  /// SystemLog 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'log_id': id,
      'locker_id': lockerId,
      'user_id': userId,
      'event_type': eventType,
      'occurred_at': occurredAt.toIso8601String(),
      'result_status': resultStatus,
    };
  }

  /// SystemLog 객체 복사 (일부 값 변경 가능)
  SystemLog copyWith({
    String? id,
    String? lockerId,
    String? userId,
    String? eventType,
    DateTime? occurredAt,
    String? resultStatus,
  }) {
    return SystemLog(
      id: id ?? this.id,
      lockerId: lockerId ?? this.lockerId,
      userId: userId ?? this.userId,
      eventType: eventType ?? this.eventType,
      occurredAt: occurredAt ?? this.occurredAt,
      resultStatus: resultStatus ?? this.resultStatus,
    );
  }

  /// 이벤트 성공 여부
  bool get isSuccess => resultStatus.toLowerCase() == 'success';

  /// 이벤트 실패 여부
  bool get isFailure => resultStatus.toLowerCase() == 'failure';

  /// 이벤트 유형 한글 표시
  String get eventTypeDisplayName {
    switch (eventType) {
      case 'open':
        return '사물함 열기';
      case 'close':
        return '사물함 닫기';
      case 'deposit':
        return '책 보관';
      case 'retrieve':
        return '책 회수';
      case 'maintenance':
        return '유지보수';
      case 'error':
        return '오류 발생';
      default:
        return eventType;
    }
  }

  /// 결과 상태 한글 표시
  String get resultStatusDisplayName {
    switch (resultStatus.toLowerCase()) {
      case 'success':
        return '성공';
      case 'failure':
        return '실패';
      case 'pending':
        return '대기 중';
      case 'timeout':
        return '시간 초과';
      default:
        return resultStatus;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemLog && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SystemLog{id: $id, eventType: $eventType, resultStatus: $resultStatus}';
  }
}
