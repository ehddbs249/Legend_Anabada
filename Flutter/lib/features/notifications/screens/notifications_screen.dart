import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/notification.dart' as model;
import '../widgets/notification_card.dart';

/// 알림 화면
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // 알림 구독 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final notificationProvider = context.read<NotificationProvider>();

      final userId = authProvider.currentUser?.id;
      if (userId != null) {
        notificationProvider.subscribeToNotifications(userId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 전체 알림 읽음 처리
  Future<void> _markAllAsRead() async {
    final authProvider = context.read<AuthProvider>();
    final notificationProvider = context.read<NotificationProvider>();

    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      await notificationProvider.markAllAsRead(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모든 알림을 읽음으로 표시했습니다'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 알림 클릭 시 처리
  void _handleNotificationTap(model.Notification notification) {
    // 알림 읽음 처리
    context.read<NotificationProvider>().markAsRead(notification.id);

    // actionUrl이 있으면 해당 페이지로 이동
    if (notification.actionUrl != null && notification.actionUrl!.isNotEmpty) {
      context.push(notification.actionUrl!);
    } else {
      // actionUrl이 없으면 타입에 따라 적절한 페이지로 이동
      _navigateByType(notification);
    }
  }

  /// 알림 타입에 따른 네비게이션
  void _navigateByType(model.Notification notification) {
    switch (notification.type) {
      case model.NotificationType.bookRequest:
      case model.NotificationType.bookApproved:
      case model.NotificationType.bookRejected:
      case model.NotificationType.bookReturned:
      case model.NotificationType.bookOverdue:
        // 거래 내역으로 이동
        context.go('/transactions');
        break;
      case model.NotificationType.pointsReceived:
      case model.NotificationType.pointsDeducted:
        // 프로필(포인트 내역)로 이동
        context.go('/profile');
        break;
      case model.NotificationType.lockerAssigned:
      case model.NotificationType.lockerOpened:
        // 사물함 화면으로 이동
        context.go('/locker');
        break;
      case model.NotificationType.reviewReceived:
        // 프로필로 이동
        context.go('/profile');
        break;
      case model.NotificationType.system:
      case model.NotificationType.promotion:
        // 홈으로 이동
        context.go('/home');
        break;
    }
  }

  /// 알림 목록 빌드
  Widget _buildNotificationList(List<model.Notification> notifications) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationCard(
          notification: notification,
          onTap: () => _handleNotificationTap(notification),
        );
      },
    );
  }

  /// Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '알림이 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '새로운 알림이 도착하면 여기에 표시됩니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        actions: [
          // 전체 읽음 버튼
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              final hasUnread = provider.unreadCount > 0;
              return IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: '전체 읽음',
                onPressed: hasUnread ? _markAllAsRead : null,
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  return _buildTabLabel('전체', provider.notifications.length);
                },
              ),
            ),
            Tab(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  final count = provider.getNotificationsByCategory('transaction').length;
                  return _buildTabLabel('거래', count);
                },
              ),
            ),
            Tab(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  final count = provider.getNotificationsByCategory('point').length;
                  return _buildTabLabel('포인트', count);
                },
              ),
            ),
            Tab(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  final count = provider.getNotificationsByCategory('locker').length;
                  return _buildTabLabel('사물함', count);
                },
              ),
            ),
            Tab(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  final count = provider.getNotificationsByCategory('system').length;
                  return _buildTabLabel('시스템', count);
                },
              ),
            ),
          ],
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          // 로딩 상태
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 에러 상태
          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    provider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      final userId = context.read<AuthProvider>().currentUser?.id;
                      if (userId != null) {
                        provider.subscribeToNotifications(userId);
                      }
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          // 탭별 알림 목록
          return TabBarView(
            controller: _tabController,
            children: [
              // 전체
              _buildNotificationList(provider.notifications),
              // 거래
              _buildNotificationList(provider.getNotificationsByCategory('transaction')),
              // 포인트
              _buildNotificationList(provider.getNotificationsByCategory('point')),
              // 사물함
              _buildNotificationList(provider.getNotificationsByCategory('locker')),
              // 시스템
              _buildNotificationList(provider.getNotificationsByCategory('system')),
            ],
          );
        },
      ),
    );
  }

  /// 탭 라벨 빌드 (카운트 포함)
  Widget _buildTabLabel(String label, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count > 99 ? '99+' : count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
