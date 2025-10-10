import 'package:flutter/material.dart';

/// 아나바다 앱의 간격(Spacing) 시스템
/// 8pt 기반 그리드로 일관된 레이아웃 구현
class AppSpacing {
  /// 기본 간격 단위 (8pt)
  static const double baseUnit = 8.0;

  /// 매우 작은 간격 (4pt)
  static const double xs = baseUnit * 0.5;

  /// 작은 간격 (8pt)
  static const double sm = baseUnit;

  /// 기본 간격 (12pt)
  static const double md = baseUnit * 1.5;

  /// 큰 간격 (16pt)
  static const double lg = baseUnit * 2;

  /// 매우 큰 간격 (20pt)
  static const double xl = baseUnit * 2.5;

  /// 특대 간격 (24pt)
  static const double xxl = baseUnit * 3;

  /// 거대 간격 (32pt)
  static const double xxxl = baseUnit * 4;

  /// 최대 간격 (40pt)
  static const double xxxxl = baseUnit * 5;

  /// 컨테이너 패딩 시스템
  static const double containerPaddingHorizontal = lg; // 16pt
  static const double containerPaddingVertical = xl; // 20pt

  /// 카드 내부 패딩
  static const double cardPadding = xl; // 20pt

  /// 섹션 간 간격
  static const double sectionSpacing = xxl; // 24pt

  /// 리스트 아이템 간격
  static const double listItemSpacing = md; // 12pt

  /// 버튼 내부 패딩
  static const double buttonPaddingHorizontal = xxl; // 24pt
  static const double buttonPaddingVertical = lg; // 16pt

  /// 텍스트 필드 패딩
  static const double textFieldPadding = xl; // 20pt

  /// 앱바 높이
  static const double appBarHeight = 56.0;

  /// 하단 네비게이션 높이
  static const double bottomNavHeight = 76.0;

  /// 탭바 높이
  static const double tabBarHeight = 48.0;

  /// 버튼 높이
  static const double buttonHeight = 56.0;
  static const double buttonHeightSmall = 44.0;
  static const double buttonHeightLarge = 64.0;

  /// 터치 타겟 최소 크기 (접근성 가이드라인)
  static const double minTouchTarget = 44.0;

  /// 아이콘 크기
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXLarge = 32.0;

  /// 프로필 이미지 크기
  static const double profileImageSmall = 32.0;
  static const double profileImageMedium = 48.0;
  static const double profileImageLarge = 64.0;

  /// 모서리 반지름 시스템
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircle = 50.0;

  /// 컴포넌트별 반지름
  static const double buttonRadius = radiusLG;
  static const double cardRadius = radiusXL;
  static const double textFieldRadius = radiusLG;
  static const double chipRadius = radiusSM;
  static const double avatarRadius = radiusCircle;

  /// 그림자 블러 반지름
  static const double shadowBlurSoft = 8.0;
  static const double shadowBlurMedium = 16.0;
  static const double shadowBlurHard = 24.0;

  /// 그림자 오프셋
  static const double shadowOffsetY = 4.0;
  static const double shadowOffsetX = 0.0;

  /// 애니메이션 지속 시간 (밀리초)
  static const int animationDurationFast = 150;
  static const int animationDurationMedium = 250;
  static const int animationDurationSlow = 400;
  static const int animationDurationVerySlow = 600;

  /// 페이지 전환 애니메이션
  static const int pageTransitionDuration = animationDurationMedium;

  /// 로딩 애니메이션
  static const int loadingAnimationDuration = animationDurationSlow;

  /// 스플래시 애니메이션
  static const int splashAnimationDuration = animationDurationVerySlow;
}

/// EdgeInsets 헬퍼 클래스
class AppPadding {
  /// 전체 컨테이너 패딩
  static const EdgeInsets container = EdgeInsets.symmetric(
    horizontal: AppSpacing.containerPaddingHorizontal,
    vertical: AppSpacing.containerPaddingVertical,
  );

  /// 카드 내부 패딩
  static const EdgeInsets card = EdgeInsets.all(AppSpacing.cardPadding);

  /// 작은 카드 패딩
  static const EdgeInsets cardSmall = EdgeInsets.all(AppSpacing.lg);

  /// 리스트 아이템 패딩
  static const EdgeInsets listItem = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.md,
  );

  /// 버튼 내부 패딩
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: AppSpacing.buttonPaddingHorizontal,
    vertical: AppSpacing.buttonPaddingVertical,
  );

  /// 텍스트 필드 패딩
  static const EdgeInsets textField = EdgeInsets.all(AppSpacing.textFieldPadding);

  /// 섹션 패딩
  static const EdgeInsets section = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.sectionSpacing,
  );

  /// 화면 패딩
  static const EdgeInsets screen = EdgeInsets.all(AppSpacing.lg);

  /// 작은 패딩
  static const EdgeInsets small = EdgeInsets.all(AppSpacing.sm);

  /// 중간 패딩
  static const EdgeInsets medium = EdgeInsets.all(AppSpacing.lg);

  /// 큰 패딩
  static const EdgeInsets large = EdgeInsets.all(AppSpacing.xl);

  /// 가로 패딩만
  static const EdgeInsets horizontal = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
  );

  /// 세로 패딩만
  static const EdgeInsets vertical = EdgeInsets.symmetric(
    vertical: AppSpacing.lg,
  );
}

/// 마진 헬퍼 클래스
class AppMargin {
  /// 작은 마진
  static const EdgeInsets small = EdgeInsets.all(AppSpacing.sm);

  /// 중간 마진
  static const EdgeInsets medium = EdgeInsets.all(AppSpacing.lg);

  /// 큰 마진
  static const EdgeInsets large = EdgeInsets.all(AppSpacing.xl);

  /// 리스트 아이템 마진
  static const EdgeInsets listItem = EdgeInsets.only(
    bottom: AppSpacing.listItemSpacing,
  );

  /// 섹션 마진
  static const EdgeInsets section = EdgeInsets.only(
    bottom: AppSpacing.sectionSpacing,
  );

  /// 카드 마진
  static const EdgeInsets card = EdgeInsets.symmetric(
    horizontal: AppSpacing.xs,
    vertical: AppSpacing.xs,
  );
}