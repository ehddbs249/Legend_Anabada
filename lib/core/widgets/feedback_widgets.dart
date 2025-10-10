import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../constants/app_animations.dart';
import 'premium_card.dart';

/// 앱 전체의 피드백 및 상태 표시 위젯들
/// 일관된 UX를 위한 표준화된 컴포넌트

/// 빈 상태 표시 위젯
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Widget? customIllustration;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.customIllustration,
    this.iconColor,
  });

  /// 미리 정의된 빈 상태들
  static Widget noBooks({VoidCallback? onAddBook}) => EmptyStateWidget(
        icon: Icons.menu_book_outlined,
        title: '등록된 교재가 없어요',
        subtitle: '첫 번째 교재를 등록하고\n다른 학생들과 공유해보세요!',
        actionText: '교재 등록하기',
        onActionPressed: onAddBook,
        iconColor: AppColors.primary,
      );

  static Widget noSearchResults({VoidCallback? onSearchAgain}) => EmptyStateWidget(
        icon: Icons.search_off_outlined,
        title: '검색 결과가 없어요',
        subtitle: '다른 키워드로 검색하거나\n필터를 조정해보세요',
        actionText: '다시 검색하기',
        onActionPressed: onSearchAgain,
        iconColor: AppColors.textTertiary,
      );

  static Widget noTransactions({VoidCallback? onStartTransaction}) => EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: '거래 내역이 없어요',
        subtitle: '교재를 대여하거나 등록하면\n거래 내역을 확인할 수 있어요',
        actionText: '교재 찾아보기',
        onActionPressed: onStartTransaction,
        iconColor: AppColors.secondary,
      );

  static Widget networkError({VoidCallback? onRetry}) => EmptyStateWidget(
        icon: Icons.wifi_off_outlined,
        title: '인터넷 연결을 확인해주세요',
        subtitle: '네트워크 상태를 확인하고\n다시 시도해주세요',
        actionText: '다시 시도',
        onActionPressed: onRetry,
        iconColor: AppColors.error,
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppPadding.large,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘 또는 커스텀 일러스트
            customIllustration ??
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.textTertiary).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: iconColor ?? AppColors.textTertiary,
                  ),
                ),
            const SizedBox(height: AppSpacing.xxl),
            // 제목
            Text(
              title,
              style: AppTypography.titleMedium.withColor(AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            // 부제목
            Text(
              subtitle,
              style: AppTypography.bodyMedium.withColor(AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            // 액션 버튼
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: onActionPressed,
                  child: Text(actionText!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 로딩 상태 위젯
class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool isFullScreen;
  final Color? color;
  final double? size;

  const LoadingWidget({
    super.key,
    this.message,
    this.isFullScreen = false,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final loadingIndicator = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size ?? 40,
          height: size ?? 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primary,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            message!,
            style: AppTypography.bodyMedium.withColor(AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isFullScreen) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: Center(child: loadingIndicator),
      );
    }

    return Center(child: loadingIndicator);
  }
}

/// 쉬머 로딩 효과
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final baseColor = widget.baseColor ?? AppColors.surfaceVariant;
    final highlightColor =
        widget.highlightColor ?? AppColors.surface;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// 에러 상태 위젯
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final bool isFullScreen;

  const ErrorStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.error_outline,
    this.actionText,
    this.onAction,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: AppPadding.large,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              title,
              style: AppTypography.titleMedium.withColor(AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                subtitle!,
                style: AppTypography.bodyMedium.withColor(AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: onAction,
                  child: Text(actionText!),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (isFullScreen) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: content,
      );
    }

    return content;
  }
}

/// 성공 피드백 위젯
class SuccessMessageWidget extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback? onDismiss;

  const SuccessMessageWidget({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
  });

  @override
  State<SuccessMessageWidget> createState() => _SuccessMessageWidgetState();
}

class _SuccessMessageWidgetState extends State<SuccessMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.bounceOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );

    _controller.forward();

    // 자동 사라짐
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: PremiumCard(
              backgroundColor: AppColors.success,
              padding: AppPadding.medium,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: AppTypography.bodyMedium.withColor(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 인라인 에러 메시지
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.small,
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.withColor(AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// 토스트 메시지 헬퍼
class AppToast {
  static void showSuccess(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.withColor(Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        ),
        margin: const EdgeInsets.all(AppSpacing.lg),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.withColor(Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        ),
        margin: const EdgeInsets.all(AppSpacing.lg),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showWarning(BuildContext context, String message) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.withColor(Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        ),
        margin: const EdgeInsets.all(AppSpacing.lg),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.withColor(Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        ),
        margin: const EdgeInsets.all(AppSpacing.lg),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}