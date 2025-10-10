import 'package:flutter/material.dart';

class AppColors {
  // 프리미엄 민트-에메랄드 색상 팔레트 - 지속가능성과 현대적 세련미
  static const Color primary = Color(0xFF0D7377); // 깊은 틸 - 신뢰감과 안정성
  static const Color primaryDark = Color(0xFF14A085); // 에메랄드 그린 - 자연과 성장
  static const Color primaryLight = Color(0xFF7FDBDA); // 아쿠아 민트 - 활기찬 느낌
  static const Color primarySoft = Color(0xFFE6F7F7); // 매우 연한 민트 - 배경용

  // 세련된 블루 액센트 - 기술적 신뢰감과 혁신
  static const Color secondary = Color(0xFF3B82F6); // 모던 블루
  static const Color secondaryDark = Color(0xFF1E40AF); // 딥 블루
  static const Color secondaryLight = Color(0xFF93C5FD); // 라이트 블루
  static const Color secondarySoft = Color(0xFFEFF6FF); // 매우 연한 블루

  // 따뜻한 골드 액센트 - 프리미엄감과 가치 표현
  static const Color accent = Color(0xFFF59E0B); // 앰버 골드
  static const Color accentDark = Color(0xFFD97706); // 딥 오렌지
  static const Color accentLight = Color(0xFFFCD34D); // 밝은 골드
  static const Color accentSoft = Color(0xFFFEF3C7); // 매우 연한 골드

  // 상태별 색상 - 감정적 인식을 높이는 모던 톤
  static const Color success = Color(0xFF10B981); // 에메랄드 그린
  static const Color successLight = Color(0xFF6EE7B7);
  static const Color successSoft = Color(0xFFECFDF5);

  static const Color error = Color(0xFFEF4444); // 코랄 레드
  static const Color errorLight = Color(0xFFFCA5A5);
  static const Color errorSoft = Color(0xFFFEF2F2);

  static const Color warning = Color(0xFFF59E0B); // 앰버
  static const Color warningLight = Color(0xFFFCD34D);
  static const Color warningSoft = Color(0xFFFEF3C7);

  static const Color info = Color(0xFF3B82F6); // 스카이 블루
  static const Color infoLight = Color(0xFF93C5FD);
  static const Color infoSoft = Color(0xFFEFF6FF);

  // 프리미엄 배경 색상 시스템 - 층감과 깊이감 표현
  static const Color background = Color(0xFFFAFAFA); // 웜 화이트
  static const Color surface = Color(0xFFFFFFFF); // 퓨어 화이트
  static const Color surfaceVariant = Color(0xFFF8FAFC); // 쿨 그레이 화이트
  static const Color surfaceElevated = Color(0xFFFFFFFF); // 높은 elevation용
  static const Color onSurface = Color(0xFF0F172A); // 딥 슬레이트

  // 세련된 텍스트 색상 시스템 - 가독성과 계층감
  static const Color textPrimary = Color(0xFF0F172A); // 딥 슬레이트 - 최고 가독성
  static const Color textSecondary = Color(0xFF475569); // 미디움 슬레이트 - 보조 정보
  static const Color textTertiary = Color(0xFF94A3B8); // 라이트 슬레이트 - 힌트/레이블
  static const Color textQuaternary = Color(0xFFCBD5E1); // 매우 연한 - 비활성
  static const Color textHint = Color(0xFFE2E8F0); // 플레이스홀더
  static const Color divider = Color(0xFFE2E8F0); // 구분선

  // 카드 및 컨테이너 - 프리미엄 머터리얼 느낌
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardElevated = Color(0xFFFDFDFD);
  static const Color cardHover = Color(0xFFF8FAFC);
  static const Color scaffoldBackground = Color(0xFFFAFAFA);

  // 그라데이션 시스템 - 깊이감과 프리미엄 느낌
  static const List<Color> primaryGradientColors = [
    Color(0xFF14A085), // 에메랄드 시작
    Color(0xFF0D7377), // 틸 끝
  ];

  static const List<Color> secondaryGradientColors = [
    Color(0xFF3B82F6), // 블루 시작
    Color(0xFF1E40AF), // 딥 블루 끝
  ];

  static const List<Color> accentGradientColors = [
    Color(0xFFF59E0B), // 골드 시작
    Color(0xFFD97706), // 딥 오렌지 끝
  ];

  // 특별한 효과를 위한 색상
  static const Color shadowLight = Color(0x0A000000); // 5% 블랙
  static const Color shadowMedium = Color(0x14000000); // 8% 블랙
  static const Color shadowStrong = Color(0x1F000000); // 12% 블랙

  // 오버레이
  static const Color overlay = Color(0x80000000); // 50% 블랙
  static const Color overlayLight = Color(0x40000000); // 25% 블랙

  static const MaterialColor primarySwatch = MaterialColor(0xFF0D7377, {
    50: Color(0xFFE6F7F7),
    100: Color(0xFFCCEFEE),
    200: Color(0xFF99DFDE),
    300: Color(0xFF66CFCD),
    400: Color(0xFF33BFBC),
    500: Color(0xFF0D7377),
    600: Color(0xFF0A5C5F),
    700: Color(0xFF084547),
    800: Color(0xFF052E30),
    900: Color(0xFF031718),
  });

  // 고급스러운 그라데이션 컬렉션
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: primaryGradientColors,
    stops: [0.0, 1.0],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: secondaryGradientColors,
    stops: [0.0, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: accentGradientColors,
    stops: [0.0, 1.0],
  );

  // 카드용 미묘한 그라데이션
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFDFDFD),
    ],
    stops: [0.0, 1.0],
  );

  // 배경용 서브틀 그라데이션
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFCFCFC),
      Color(0xFFF8FAFC),
    ],
    stops: [0.0, 1.0],
  );

  // 성공/경고/에러 그라데이션
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF059669)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warning, accentDark],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, Color(0xFFDC2626)],
  );
}