import 'package:flutter/material.dart';
import 'app_spacing.dart';

/// 아나바다 앱의 애니메이션 시스템
/// 일관된 모션 디자인과 인터랙션 제공
class AppAnimations {
  /// 애니메이션 지속 시간
  static const Duration fast = Duration(milliseconds: AppSpacing.animationDurationFast);
  static const Duration medium = Duration(milliseconds: AppSpacing.animationDurationMedium);
  static const Duration slow = Duration(milliseconds: AppSpacing.animationDurationSlow);
  static const Duration verySlow = Duration(milliseconds: AppSpacing.animationDurationVerySlow);

  /// 페이지 전환 애니메이션
  static const Duration pageTransition = Duration(milliseconds: AppSpacing.pageTransitionDuration);

  /// 애니메이션 커브
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;

  /// 프리미엄 커브 (Material Design 3)
  static const Curve emphasized = Cubic(0.2, 0.0, 0, 1.0);
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);

  /// 버튼 프레스 애니메이션
  static const Duration buttonPress = fast;
  static const Curve buttonCurve = emphasized;

  /// 카드 호버 애니메이션
  static const Duration cardHover = fast;
  static const Curve cardCurve = easeOut;

  /// 모달 애니메이션
  static const Duration modal = medium;
  static const Curve modalCurve = emphasizedDecelerate;

  /// 리스트 아이템 애니메이션
  static const Duration listItem = medium;
  static const Curve listItemCurve = easeOut;

  /// 페이드 인/아웃
  static const Duration fade = medium;
  static const Curve fadeCurve = easeInOut;

  /// 슬라이드 애니메이션
  static const Duration slide = medium;
  static const Curve slideCurve = emphasizedDecelerate;

  /// 스케일 애니메이션
  static const Duration scale = fast;
  static const Curve scaleCurve = emphasized;

  /// 로딩 애니메이션
  static const Duration loading = slow;
  static const Curve loadingCurve = easeInOut;

  /// 스플래시 애니메이션
  static const Duration splash = verySlow;
  static const Curve splashCurve = emphasizedDecelerate;
}

/// 커스텀 페이지 전환 애니메이션
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  SlideUpPageRoute({
    required this.child,
    this.duration = AppAnimations.pageTransition,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = animation.drive(
              tween.chain(CurveTween(curve: AppAnimations.emphasizedDecelerate)),
            );

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

/// 페이드 전환 애니메이션
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  FadePageRoute({
    required this.child,
    this.duration = AppAnimations.pageTransition,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(
                CurveTween(curve: AppAnimations.fadeCurve),
              ),
              child: child,
            );
          },
        );
}

/// 스케일 전환 애니메이션
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  ScalePageRoute({
    required this.child,
    this.duration = AppAnimations.pageTransition,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: animation.drive(
                Tween(begin: 0.8, end: 1.0).chain(
                  CurveTween(curve: AppAnimations.scaleCurve),
                ),
              ),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

/// 애니메이션 헬퍼 함수들
class AnimationHelpers {
  /// 지연된 애니메이션 (리스트 아이템용)
  static Animation<double> createDelayedAnimation(
    AnimationController controller,
    int index, {
    Duration delay = const Duration(milliseconds: 50),
    Duration duration = AppAnimations.medium,
  }) {
    final start = (index * delay.inMilliseconds) / duration.inMilliseconds;
    final end = start + 0.5;

    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          start.clamp(0.0, 1.0),
          end.clamp(0.0, 1.0),
          curve: AppAnimations.easeOut,
        ),
      ),
    );
  }

  /// 바운스 애니메이션
  static Animation<double> createBounceAnimation(
    AnimationController controller,
  ) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: AppAnimations.bounceOut,
      ),
    );
  }

  /// 스태거드 애니메이션 (복합 애니메이션)
  static Map<String, Animation<double>> createStaggeredAnimations(
    AnimationController controller,
  ) {
    return {
      'fade': Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.6, curve: AppAnimations.easeOut),
        ),
      ),
      'slide': Tween<double>(
        begin: 50.0,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.2, 0.8, curve: AppAnimations.emphasizedDecelerate),
        ),
      ),
      'scale': Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.4, 1.0, curve: AppAnimations.elasticOut),
        ),
      ),
    };
  }
}

/// 애니메이션 Mixin - 공통 애니메이션 로직 제공
mixin AnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.fadeCurve,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.slideCurve,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.scaleCurve,
      ),
    );

    // 자동 시작
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 애니메이션 접근자
  AnimationController get animationController => _animationController;
  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<Offset> get slideAnimation => _slideAnimation;
  Animation<double> get scaleAnimation => _scaleAnimation;

  // 애니메이션 제어 메서드
  void playAnimation() => _animationController.forward();
  void reverseAnimation() => _animationController.reverse();
  void resetAnimation() => _animationController.reset();
  void stopAnimation() => _animationController.stop();
}

/// 애니메이션된 위젯을 쉽게 만들 수 있는 빌더
class AnimatedSlideUp extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;

  const AnimatedSlideUp({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppAnimations.medium,
    this.curve = AppAnimations.emphasizedDecelerate,
  });

  @override
  State<AnimatedSlideUp> createState() => _AnimatedSlideUpState();
}

class _AnimatedSlideUpState extends State<AnimatedSlideUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    // 지연 후 애니메이션 시작
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}