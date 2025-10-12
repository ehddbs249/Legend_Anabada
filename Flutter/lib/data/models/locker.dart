/// 사물함 데이터 모델
/// Spring Boot Entity: Locker (locker_id, locker_status, is_broken, locker_num)
/// BREAKING CHANGE: id 타입이 int에서 String (UUID)으로 변경됨
class Locker {
  /// 사물함 ID (UUID) ← locker_id
  /// 이전에는 int였으나 Spring Boot Entity에서 UUID로 변경됨
  final String id;

  /// 사물함 상태 (available, occupied, maintenance) ← locker_status
  final String lockerStatus;

  /// 고장 여부 ← is_broken
  final bool? isBroken;

  /// 사물함 번호 ← locker_num
  final int? lockerNum;

  const Locker({
    required this.id,
    required this.lockerStatus,
    this.isBroken,
    this.lockerNum,
  });

  /// JSON에서 Locker 객체 생성
  factory Locker.fromJson(Map<String, dynamic> json) {
    return Locker(
      id: json['locker_id'] as String,
      lockerStatus: json['locker_status'] as String,
      isBroken: json['is_broken'] as bool?,
      lockerNum: json['locker_num'] as int?,
    );
  }

  /// Locker 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'locker_id': id,
      'locker_status': lockerStatus,
      'is_broken': isBroken,
      'locker_num': lockerNum,
    };
  }

  /// Locker 객체 복사 (일부 값 변경 가능)
  Locker copyWith({
    String? id,
    String? lockerStatus,
    bool? isBroken,
    int? lockerNum,
  }) {
    return Locker(
      id: id ?? this.id,
      lockerStatus: lockerStatus ?? this.lockerStatus,
      isBroken: isBroken ?? this.isBroken,
      lockerNum: lockerNum ?? this.lockerNum,
    );
  }

  /// 사물함 상태 한글 표시
  String get lockerStatusDisplayName {
    switch (lockerStatus) {
      case 'available':
        return '사용 가능';
      case 'occupied':
        return '사용 중';
      case 'maintenance':
        return '점검 중';
      case 'broken':
        return '고장';
      default:
        return '알 수 없음';
    }
  }

  /// 사물함 사용 가능 여부
  bool get isAvailable => lockerStatus == 'available' && isBroken != true;

  /// 사물함 표시 이름 (번호 기반)
  String get displayName {
    if (lockerNum != null) {
      return '#$lockerNum';
    }
    return id.substring(0, 8); // UUID 일부만 표시
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Locker &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Locker{id: $id, status: $lockerStatus, num: $lockerNum}';
  }
}
