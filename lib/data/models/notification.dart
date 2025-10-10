/// 알림 타입 열거형
enum NotificationType {
  bookRequest,     // 책 대여 요청
  bookApproved,    // 책 대여 승인
  bookRejected,    // 책 대여 거절
  bookReturned,    // 책 반납
  bookOverdue,     // 책 연체
  lockerAssigned,  // 사물함 배정
  lockerOpened,    // 사물함 열림
  pointsReceived,  // 포인트 수령
  pointsDeducted,  // 포인트 차감
  reviewReceived,  // 리뷰 수령
  system,          // 시스템 알림
  promotion        // 프로모션
}

/// 알림 타입 확장
extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.bookRequest:
        return '책 대여 요청';
      case NotificationType.bookApproved:
        return '책 대여 승인';
      case NotificationType.bookRejected:
        return '책 대여 거절';
      case NotificationType.bookReturned:
        return '책 반납';
      case NotificationType.bookOverdue:
        return '책 연체';
      case NotificationType.lockerAssigned:
        return '사물함 배정';
      case NotificationType.lockerOpened:
        return '사물함 열림';
      case NotificationType.pointsReceived:
        return '포인트 수령';
      case NotificationType.pointsDeducted:
        return '포인트 차감';
      case NotificationType.reviewReceived:
        return '리뷰 수령';
      case NotificationType.system:
        return '시스템 알림';
      case NotificationType.promotion:
        return '프로모션';
    }
  }

  String get value {
    switch (this) {
      case NotificationType.bookRequest:
        return 'book_request';
      case NotificationType.bookApproved:
        return 'book_approved';
      case NotificationType.bookRejected:
        return 'book_rejected';
      case NotificationType.bookReturned:
        return 'book_returned';
      case NotificationType.bookOverdue:
        return 'book_overdue';
      case NotificationType.lockerAssigned:
        return 'locker_assigned';
      case NotificationType.lockerOpened:
        return 'locker_opened';
      case NotificationType.pointsReceived:
        return 'points_received';
      case NotificationType.pointsDeducted:
        return 'points_deducted';
      case NotificationType.reviewReceived:
        return 'review_received';
      case NotificationType.system:
        return 'system';
      case NotificationType.promotion:
        return 'promotion';
    }
  }

  static NotificationType fromString(String value) {
    switch (value) {
      case 'book_request':
        return NotificationType.bookRequest;
      case 'book_approved':
        return NotificationType.bookApproved;
      case 'book_rejected':
        return NotificationType.bookRejected;
      case 'book_returned':
        return NotificationType.bookReturned;
      case 'book_overdue':
        return NotificationType.bookOverdue;
      case 'locker_assigned':
        return NotificationType.lockerAssigned;
      case 'locker_opened':
        return NotificationType.lockerOpened;
      case 'points_received':
        return NotificationType.pointsReceived;
      case 'points_deducted':
        return NotificationType.pointsDeducted;
      case 'review_received':
        return NotificationType.reviewReceived;
      case 'system':
        return NotificationType.system;
      case 'promotion':
        return NotificationType.promotion;
      default:
        return NotificationType.system;
    }
  }

  /// 알림 아이콘
  String get icon {
    switch (this) {
      case NotificationType.bookRequest:
      case NotificationType.bookApproved:
      case NotificationType.bookRejected:
      case NotificationType.bookReturned:
        return '📚';
      case NotificationType.bookOverdue:
        return '⚠️';
      case NotificationType.lockerAssigned:
      case NotificationType.lockerOpened:
        return '🔒';
      case NotificationType.pointsReceived:
        return '💰';
      case NotificationType.pointsDeducted:
        return '💸';
      case NotificationType.reviewReceived:
        return '⭐';
      case NotificationType.system:
        return '🔔';
      case NotificationType.promotion:
        return '🎉';
    }
  }
}

/// 알림 데이터 모델
class Notification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? readAt;

  const Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.actionUrl,
    this.metadata,
    required this.createdAt,
    this.readAt,
  });

  /// JSON에서 Notification 객체 생성
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: NotificationTypeExtension.fromString(json['type'] as String),
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      actionUrl: json['action_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }

  /// Notification 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.value,
      'title': title,
      'message': message,
      'is_read': isRead,
      'action_url': actionUrl,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  /// Notification 객체 복사 (일부 값 변경 가능)
  Notification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    bool? isRead,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  /// 읽음 표시
  Notification markAsRead() {
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  /// 생성된 지 얼마나 지났는지 계산
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Notification &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Notification{id: $id, type: ${type.displayName}, title: $title, isRead: $isRead}';
  }
}