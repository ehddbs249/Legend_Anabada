/// 사물함 상태 열거형
enum LockerStatus {
  available,    // 사용 가능
  occupied,     // 사용 중
  maintenance,  // 점검 중
  broken        // 고장
}

/// 사물함 상태 확장
extension LockerStatusExtension on LockerStatus {
  String get displayName {
    switch (this) {
      case LockerStatus.available:
        return '사용 가능';
      case LockerStatus.occupied:
        return '사용 중';
      case LockerStatus.maintenance:
        return '점검 중';
      case LockerStatus.broken:
        return '고장';
    }
  }

  String get value {
    switch (this) {
      case LockerStatus.available:
        return 'available';
      case LockerStatus.occupied:
        return 'occupied';
      case LockerStatus.maintenance:
        return 'maintenance';
      case LockerStatus.broken:
        return 'broken';
    }
  }

  static LockerStatus fromString(String value) {
    switch (value) {
      case 'available':
        return LockerStatus.available;
      case 'occupied':
        return LockerStatus.occupied;
      case 'maintenance':
        return LockerStatus.maintenance;
      case 'broken':
        return LockerStatus.broken;
      default:
        return LockerStatus.available;
    }
  }
}

/// 사물함 위치 데이터 모델
class LockerPosition {
  final int row;
  final int column;

  const LockerPosition({
    required this.row,
    required this.column,
  });

  /// JSON에서 LockerPosition 객체 생성
  factory LockerPosition.fromJson(Map<String, dynamic> json) {
    return LockerPosition(
      row: json['row'] as int,
      column: json['column'] as int,
    );
  }

  /// LockerPosition 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'row': row,
      'column': column,
    };
  }

  /// 사물함 번호 생성 (예: A1, B2)
  String get displayName {
    final rowChar = String.fromCharCode(65 + row); // A, B, C, ...
    return '$rowChar${column + 1}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LockerPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          column == other.column;

  @override
  int get hashCode => row.hashCode ^ column.hashCode;

  @override
  String toString() => 'LockerPosition{row: $row, column: $column}';
}

/// 사물함 데이터 모델
class Locker {
  final int id;
  final String location;
  final LockerPosition position;
  final LockerStatus status;
  final String? currentTransactionId;
  final String? raspberryPiId;
  final DateTime? lastAccessed;
  final String? accessCode;
  final DateTime? reservedUntil;

  // 관련 데이터
  final String? currentUserName;
  final String? currentBookTitle;

  const Locker({
    required this.id,
    required this.location,
    required this.position,
    required this.status,
    this.currentTransactionId,
    this.raspberryPiId,
    this.lastAccessed,
    this.accessCode,
    this.reservedUntil,
    // 관련 데이터
    this.currentUserName,
    this.currentBookTitle,
  });

  /// JSON에서 Locker 객체 생성
  factory Locker.fromJson(Map<String, dynamic> json) {
    return Locker(
      id: json['id'] as int,
      location: json['location'] as String,
      position: LockerPosition(
        row: json['row_number'] as int,
        column: json['column_number'] as int,
      ),
      status: LockerStatusExtension.fromString(json['status'] as String),
      currentTransactionId: json['current_transaction_id'] as String?,
      raspberryPiId: json['raspberry_pi_id'] as String?,
      lastAccessed: json['last_accessed'] != null
          ? DateTime.parse(json['last_accessed'] as String)
          : null,
      accessCode: json['access_code'] as String?,
      reservedUntil: json['reserved_until'] != null
          ? DateTime.parse(json['reserved_until'] as String)
          : null,
      // 관련 데이터
      currentUserName: json['current_user_name'] as String?,
      currentBookTitle: json['current_book_title'] as String?,
    );
  }

  /// Locker 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'row_number': position.row,
      'column_number': position.column,
      'status': status.value,
      'current_transaction_id': currentTransactionId,
      'raspberry_pi_id': raspberryPiId,
      'last_accessed': lastAccessed?.toIso8601String(),
      'access_code': accessCode,
      'reserved_until': reservedUntil?.toIso8601String(),
    };
  }

  /// Locker 객체 복사 (일부 값 변경 가능)
  Locker copyWith({
    int? id,
    String? location,
    LockerPosition? position,
    LockerStatus? status,
    String? currentTransactionId,
    String? raspberryPiId,
    DateTime? lastAccessed,
    String? accessCode,
    DateTime? reservedUntil,
    String? currentUserName,
    String? currentBookTitle,
  }) {
    return Locker(
      id: id ?? this.id,
      location: location ?? this.location,
      position: position ?? this.position,
      status: status ?? this.status,
      currentTransactionId: currentTransactionId ?? this.currentTransactionId,
      raspberryPiId: raspberryPiId ?? this.raspberryPiId,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      accessCode: accessCode ?? this.accessCode,
      reservedUntil: reservedUntil ?? this.reservedUntil,
      currentUserName: currentUserName ?? this.currentUserName,
      currentBookTitle: currentBookTitle ?? this.currentBookTitle,
    );
  }

  /// 사물함 사용 가능 여부
  bool get isAvailable => status == LockerStatus.available;

  /// 사물함 예약 여부
  bool get isReserved {
    return reservedUntil != null &&
           DateTime.now().isBefore(reservedUntil!) &&
           status == LockerStatus.available;
  }

  /// 사물함 표시 이름
  String get displayName => position.displayName;

  /// 사물함 전체 주소
  String get fullAddress => '$location ${position.displayName}';

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
    return 'Locker{id: $id, position: ${position.displayName}, status: ${status.displayName}}';
  }
}