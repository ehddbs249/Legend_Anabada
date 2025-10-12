import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/widgets/onboarding_widgets.dart';

/// 아나바다 앱의 온보딩 화면
/// 앱의 주요 기능과 가치를 소개하는 화면
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = OnboardingData.getDefaultOnboarding();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: AppAnimations.pageTransition,
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: AppAnimations.pageTransition,
        curve: AppAnimations.emphasizedDecelerate,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  void _finishOnboarding() {
    // 온보딩 완료 상태 저장 (SharedPreferences 등)
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 건너뛰기 버튼
            if (_currentPage < _onboardingData.length - 1)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      '건너뛰기',
                      style: AppTypography.labelMedium.withColor(AppColors.textSecondary),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: AppSpacing.appBarHeight),

            // 페이지 뷰
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return _buildOnboardingPage(data);
                },
              ),
            ),

            // 하단 컨트롤러
            OnboardingController(
              currentPage: _currentPage,
              totalPages: _onboardingData.length,
              onNext: _nextPage,
              onSkip: _skipOnboarding,
              onFinish: _finishOnboarding,
              nextText: '다음',
              finishText: '시작하기',
              skipText: '건너뛰기',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return OnboardingPage(
      title: data.title,
      subtitle: data.subtitle,
      illustration: _buildIllustration(data),
    );
  }

  Widget _buildIllustration(OnboardingData data) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 배경 애니메이션
        _buildBackgroundAnimation(data.backgroundColor),

        // 메인 일러스트레이션
        OnboardingIllustration(
          icon: data.icon,
          iconColor: data.iconColor,
          backgroundColor: data.backgroundColor,
          size: 240,
          decorations: _buildDecorations(data),
        ),
      ],
    );
  }

  Widget _buildBackgroundAnimation(Color backgroundColor) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_animationController.value * 0.2),
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: backgroundColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDecorations(OnboardingData data) {
    return [
      // 떠다니는 점들
      Positioned(
        top: 30,
        right: 40,
        child: _buildFloatingDot(AppColors.primary, 8),
      ),
      Positioned(
        bottom: 50,
        left: 30,
        child: _buildFloatingDot(AppColors.secondary, 6),
      ),
      Positioned(
        top: 80,
        left: 20,
        child: _buildFloatingDot(AppColors.accent, 4),
      ),

      // 원형 테두리
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: data.iconColor.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildFloatingDot(Color color, double size) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            -10 * _animationController.value,
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

/// 온보딩 상태 관리를 위한 헬퍼 클래스
class OnboardingHelper {
  /// 온보딩을 봤는지 확인
  static Future<bool> hasSeenOnboarding() async {
    // SharedPreferences 구현 필요
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getBool('has_seen_onboarding') ?? false;
    return false; // 임시
  }

  /// 온보딩 완료 상태 저장
  static Future<void> setOnboardingComplete() async {
    // SharedPreferences 구현 필요
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('has_seen_onboarding', true);
  }

  /// 온보딩 상태 초기화 (개발/테스트용)
  static Future<void> resetOnboarding() async {
    // SharedPreferences 구현 필요
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove(_onboardingKey);
  }
}

/// 특정 기능에 대한 가이드 오버레이 표시
class FeatureGuideOverlay extends StatefulWidget {
  final Widget child;
  final String featureKey;
  final String title;
  final String description;

  const FeatureGuideOverlay({
    super.key,
    required this.child,
    required this.featureKey,
    required this.title,
    required this.description,
  });

  @override
  State<FeatureGuideOverlay> createState() => _FeatureGuideOverlayState();
}

class _FeatureGuideOverlayState extends State<FeatureGuideOverlay> {
  bool _shouldShowGuide = false;

  @override
  void initState() {
    super.initState();
    _checkShouldShowGuide();
  }

  Future<void> _checkShouldShowGuide() async {
    // 해당 기능의 가이드를 본 적이 있는지 확인
    // SharedPreferences 구현 필요
    // TODO: 백엔드 연동 시 구현
  }

  void _dismissGuide() {
    setState(() {
      _shouldShowGuide = false;
    });

    // 가이드 완료 상태 저장
    _markGuideAsSeen();
  }

  Future<void> _markGuideAsSeen() async {
    // SharedPreferences에 해당 기능 가이드 완료 상태 저장
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('guide_${widget.featureKey}', true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowGuide) {
      return widget.child;
    }

    return TutorialOverlay(
      title: widget.title,
      description: widget.description,
      onNext: _dismissGuide,
      onSkip: _dismissGuide,
      child: widget.child,
    );
  }
}