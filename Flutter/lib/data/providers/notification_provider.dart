import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification.dart' as model;
import '../services/supabase_service.dart';

/// 알림 상태 관리 Provider
class NotificationProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  /// 알림 목록
  List<model.Notification> _notifications = [];

  /// 실시간 구독
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  /// 로딩 상태
  bool _isLoading = false;

  /// 에러 메시지
  String? _errorMessage;

  /// Getters
  List<model.Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 안읽은 알림 개수
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// 안읽은 알림 목록
  List<model.Notification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  /// 읽은 알림 목록
  List<model.Notification> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();

  /// 알림 타입별 필터링
  List<model.Notification> getNotificationsByType(model.NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// 특정 카테고리 알림 필터링 (거래/포인트/사물함/시스템)
  List<model.Notification> getNotificationsByCategory(String category) {
    switch (category) {
      case 'transaction':
        return _notifications.where((n) {
          return n.type == model.NotificationType.bookRequest ||
              n.type == model.NotificationType.bookApproved ||
              n.type == model.NotificationType.bookRejected ||
              n.type == model.NotificationType.bookReturned ||
              n.type == model.NotificationType.bookOverdue;
        }).toList();
      case 'point':
        return _notifications.where((n) {
          return n.type == model.NotificationType.pointsReceived ||
              n.type == model.NotificationType.pointsDeducted;
        }).toList();
      case 'locker':
        return _notifications.where((n) {
          return n.type == model.NotificationType.lockerAssigned ||
              n.type == model.NotificationType.lockerOpened;
        }).toList();
      case 'system':
        return _notifications.where((n) {
          return n.type == model.NotificationType.system ||
              n.type == model.NotificationType.promotion ||
              n.type == model.NotificationType.reviewReceived;
        }).toList();
      default:
        return _notifications;
    }
  }

  /// 알림 실시간 구독 시작
  Future<void> subscribeToNotifications(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 이전 구독 취소
      await _subscription?.cancel();

      // 새로운 구독 시작
      _subscription = _supabaseService
          .subscribeToNotifications(userId)
          .listen(
            (data) {
              _notifications = data
                  .map((json) => model.Notification.fromJson(json))
                  .toList();
              _isLoading = false;
              notifyListeners();
            },
            onError: (error) {
              _errorMessage = '알림 구독 중 오류 발생: ${error.toString()}';
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e) {
      _errorMessage = '알림 구독 실패: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(String notificationId) async {
    try {
      // Supabase 업데이트
      await _supabaseService.markNotificationAsRead(notificationId);

      // 로컬 상태 업데이트
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].markAsRead();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '알림 읽음 처리 실패: ${e.toString()}';
      notifyListeners();
    }
  }

  /// 전체 알림 읽음 처리
  Future<void> markAllAsRead(String userId) async {
    try {
      // Supabase 업데이트
      await _supabaseService.markAllNotificationsAsRead(userId);

      // 로컬 상태 업데이트
      _notifications = _notifications.map((n) => n.markAsRead()).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = '전체 읽음 처리 실패: ${e.toString()}';
      notifyListeners();
    }
  }

  /// 알림 생성 (테스트용 또는 수동 생성)
  Future<void> createNotification({
    required String userId,
    required model.NotificationType type,
    required String title,
    required String message,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _supabaseService.createNotification(
        userId: userId,
        type: type,
        title: title,
        message: message,
        actionUrl: actionUrl,
        metadata: metadata,
      );
    } catch (e) {
      _errorMessage = '알림 생성 실패: ${e.toString()}';
      notifyListeners();
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Provider 정리 (구독 취소)
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
