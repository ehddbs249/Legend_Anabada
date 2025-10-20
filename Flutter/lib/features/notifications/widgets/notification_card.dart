import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/notification.dart' as model;

/// 알림 카드 위젯
class NotificationCard extends StatelessWidget {
  final model.Notification notification;
  final VoidCallback onTap;
  final VoidCallback? onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.onMarkAsRead,
  });

  /// 알림 타입에 따른 아이콘 반환
  IconData _getIcon() {
    switch (notification.type) {
      case model.NotificationType.bookRequest:
      case model.NotificationType.bookApproved:
      case model.NotificationType.bookRejected:
      case model.NotificationType.bookReturned:
        return Icons.menu_book;
      case model.NotificationType.bookOverdue:
        return Icons.warning_amber_rounded;
      case model.NotificationType.lockerAssigned:
      case model.NotificationType.lockerOpened:
        return Icons.lock_open;
      case model.NotificationType.pointsReceived:
        return Icons.add_circle_outline;
      case model.NotificationType.pointsDeducted:
        return Icons.remove_circle_outline;
      case model.NotificationType.reviewReceived:
        return Icons.star_outline;
      case model.NotificationType.system:
        return Icons.info_outline;
      case model.NotificationType.promotion:
        return Icons.campaign;
    }
  }

  /// 알림 타입에 따른 색상 반환
  Color _getColor() {
    switch (notification.type) {
      case model.NotificationType.bookRequest:
      case model.NotificationType.lockerAssigned:
        return AppColors.primary;
      case model.NotificationType.bookApproved:
      case model.NotificationType.pointsReceived:
        return AppColors.success;
      case model.NotificationType.bookRejected:
      case model.NotificationType.bookOverdue:
        return AppColors.error;
      case model.NotificationType.bookReturned:
      case model.NotificationType.lockerOpened:
        return AppColors.info;
      case model.NotificationType.pointsDeducted:
        return AppColors.warning;
      case model.NotificationType.reviewReceived:
        return Colors.amber;
      case model.NotificationType.system:
        return AppColors.textSecondary;
      case model.NotificationType.promotion:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getColor();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : AppColors.primary.withValues(alpha: 0.03),
          border: Border(
            left: BorderSide(
              color: notification.isRead
                  ? Colors.transparent
                  : AppColors.primary,
              width: 3,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIcon(),
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                        ),
                      ),
                      // 안읽음 인디케이터
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // 메시지
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // 시간
                  Text(
                    notification.timeAgo,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 간단한 알림 카드 (홈 화면용)
class SimpleNotificationCard extends StatelessWidget {
  final model.Notification notification;
  final VoidCallback onTap;

  const SimpleNotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  /// 알림 타입에 따른 색상 반환
  Color _getColor() {
    switch (notification.type) {
      case model.NotificationType.bookRequest:
      case model.NotificationType.lockerAssigned:
        return AppColors.primary;
      case model.NotificationType.bookApproved:
      case model.NotificationType.pointsReceived:
        return AppColors.success;
      case model.NotificationType.bookRejected:
      case model.NotificationType.bookOverdue:
        return AppColors.error;
      case model.NotificationType.bookReturned:
      case model.NotificationType.lockerOpened:
        return AppColors.info;
      case model.NotificationType.pointsDeducted:
        return AppColors.warning;
      case model.NotificationType.reviewReceived:
        return Colors.amber;
      case model.NotificationType.system:
        return AppColors.textSecondary;
      case model.NotificationType.promotion:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // 안읽음 인디케이터
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            if (!notification.isRead) const SizedBox(width: AppSpacing.sm),

            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // 시간
            Text(
              notification.timeAgo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
