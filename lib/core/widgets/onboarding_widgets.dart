import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../constants/app_animations.dart';
import 'premium_card.dart';
import 'premium_button.dart';

/// 온보딩 및 가이드 위젯들
/// 사용자의 첫 경험을 향상시키는 컴포넌트

/// 메인 온보딩 페이지 위젯
class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget illustration;
  final Color? backgroundColor;
  final List<Color>? gradientColors;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.illustration,
    this.backgroundColor,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.large,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradientColors != null
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors!,
              )
            : null,
      ),
      child: Column(
        children: [
          const Spacer(flex: 1),
          // 일러스트레이션
          Expanded(
            flex: 4,
            child: Center(child: illustration),
          ),
          const Spacer(flex: 1),
          // 텍스트 콘텐츠
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  title,
                  style: AppTypography.headlineMedium.withColor(
                    gradientColors != null ? Colors.white : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  subtitle,
                  style: AppTypography.bodyLarge.withColor(
                    gradientColors != null
                        ? Colors.white.withValues(alpha: 0.9)
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

/// 온보딩 일러스트레이션 위젯
class OnboardingIllustration extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double size;
  final List<Widget>? decorations;

  const OnboardingIllustration({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.size = 200,
    this.decorations,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          // 메인 아이콘
          Icon(
            icon,
            size: size * 0.4,
            color: iconColor,
          ),
          // 장식 요소들
          if (decorations != null) ...decorations!,
        ],
      ),
    );
  }
}

/// 온보딩 컨트롤러 위젯
class OnboardingController extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onSkip;
  final VoidCallback? onFinish;
  final String? nextText;
  final String? finishText;
  final String? skipText;

  const OnboardingController({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onNext,
    this.onPrevious,
    this.onSkip,
    this.onFinish,
    this.nextText,
    this.finishText,
    this.skipText,
  });

  bool get isLastPage => currentPage == totalPages - 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.large,
      child: Column(
        children: [
          // 페이지 인디케이터
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPages,
              (index) => AnimatedContainer(
                duration: AppAnimations.fast,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == currentPage ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == currentPage
                      ? AppColors.primary
                      : AppColors.textQuaternary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          // 컨트롤 버튼들
          Row(
            children: [
              // 건너뛰기 버튼
              if (!isLastPage && onSkip != null)
                TextButton(
                  onPressed: onSkip,
                  child: Text(skipText ?? '건너뛰기'),
                )
              else
                const SizedBox(width: 80),
              const Spacer(),
              // 다음/완료 버튼
              if (isLastPage)
                PremiumButton(
                  text: finishText ?? '시작하기',
                  onPressed: onFinish,
                  width: 160,
                )
              else
                PremiumButton(
                  text: nextText ?? '다음',
                  onPressed: onNext,
                  width: 120,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 기능 소개 카드 위젯
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color? iconColor;
  final Color? backgroundColor;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      backgroundColor: backgroundColor ?? AppColors.surface,
      padding: AppPadding.large,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
            ),
            child: Icon(
              icon,
              size: 32,
              color: iconColor ?? AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTypography.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            description,
            style: AppTypography.bodyMedium.withColor(AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 튜토리얼 오버레이 위젯
class TutorialOverlay extends StatefulWidget {
  final Widget child;
  final String title;
  final String description;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final Alignment targetAlignment;
  final bool showArrow;

  const TutorialOverlay({
    super.key,
    required this.child,
    required this.title,
    required this.description,
    this.onNext,
    this.onSkip,
    this.targetAlignment = Alignment.center,
    this.showArrow = true,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.emphasized),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // 오버레이
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                color: Colors.black.withValues(alpha: 0.8),
                child: Stack(
                  children: [
                    // 설명 카드
                    Positioned(
                      bottom: 100,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: PremiumCard(
                          backgroundColor: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: AppTypography.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                widget.description,
                                style: AppTypography.bodyMedium
                                    .withColor(AppColors.textSecondary),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (widget.onSkip != null)
                                    TextButton(
                                      onPressed: widget.onSkip,
                                      child: const Text('건너뛰기'),
                                    ),
                                  const SizedBox(width: AppSpacing.md),
                                  PremiumButton(
                                    text: '다음',
                                    onPressed: widget.onNext,
                                    width: 100,
                                    height: 40,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 화살표 (선택적)
                    if (widget.showArrow)
                      Positioned(
                        bottom: 250,
                        left: MediaQuery.of(context).size.width / 2 - 12,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// 힌트 말풍선 위젯
class HintBubble extends StatefulWidget {
  final String message;
  final Widget child;
  final bool show;
  final VoidCallback? onDismiss;
  final Duration duration;

  const HintBubble({
    super.key,
    required this.message,
    required this.child,
    this.show = false,
    this.onDismiss,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<HintBubble> createState() => _HintBubbleState();
}

class _HintBubbleState extends State<HintBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );

    if (widget.show) {
      _controller.forward();
      Future.delayed(widget.duration, () {
        if (mounted) {
          _controller.reverse().then((_) {
            widget.onDismiss?.call();
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(HintBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _controller.forward();
      Future.delayed(widget.duration, () {
        if (mounted) {
          _controller.reverse().then((_) {
            widget.onDismiss?.call();
          });
        }
      });
    } else if (!widget.show && oldWidget.show) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (widget.show)
          Positioned(
            top: -60,
            left: -20,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: Opacity(
                    opacity: _animation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowMedium,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.message,
                            style: AppTypography.bodySmall.withColor(Colors.white),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          GestureDetector(
                            onTap: () {
                              _controller.reverse().then((_) {
                                widget.onDismiss?.call();
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// 온보딩 데이터 모델
class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  /// 아나바다 앱의 기본 온보딩 데이터
  static List<OnboardingData> getDefaultOnboarding() {
    return [
      const OnboardingData(
        title: '교재를 공유하고\n포인트를 받으세요',
        subtitle: '사용하지 않는 교재를 등록하고\n다른 학생들과 공유해보세요',
        icon: Icons.auto_stories_rounded,
        iconColor: AppColors.primary,
        backgroundColor: AppColors.primarySoft,
      ),
      const OnboardingData(
        title: '스마트 사물함으로\n안전한 거래',
        subtitle: 'QR 코드로 사물함을 열고\n언제든지 교재를 받아가세요',
        icon: Icons.lock_outline_rounded,
        iconColor: AppColors.secondary,
        backgroundColor: AppColors.secondarySoft,
      ),
      const OnboardingData(
        title: '지속가능한\n캠퍼스 문화',
        subtitle: '자원을 재활용하고\n환경을 보호하는 데 동참하세요',
        icon: Icons.eco_outlined,
        iconColor: AppColors.success,
        backgroundColor: AppColors.successSoft,
      ),
    ];
  }
}