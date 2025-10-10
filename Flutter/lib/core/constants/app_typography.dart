import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// 아나바다 앱의 타이포그래피 시스템
/// 한국어에 최적화된 가독성과 위계 구조 제공
class AppTypography {
  /// 기본 폰트 패밀리 (Noto Sans KR - 한국어 최적화)
  static String get fontFamily => GoogleFonts.notoSans().fontFamily!;

  /// 폰트 크기 시스템 (Type Scale)
  static const double fontSize10 = 10.0;
  static const double fontSize11 = 11.0;
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize22 = 22.0;
  static const double fontSize24 = 24.0;
  static const double fontSize28 = 28.0;
  static const double fontSize32 = 32.0;
  static const double fontSize36 = 36.0;
  static const double fontSize40 = 40.0;
  static const double fontSize48 = 48.0;

  /// 폰트 가중치
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  /// 줄 간격 (Line Height)
  static const double lineHeightTight = 1.1;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;
  static const double lineHeightLoose = 1.8;

  /// 자간 (Letter Spacing) - 한국어 최적화
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = -0.2;
  static const double letterSpacingWide = 0.1;
  static const double letterSpacingExtraWide = 0.3;

  /// Display 스타일 (대형 제목용)
  static TextStyle get displayLarge => GoogleFonts.notoSans(
        fontSize: fontSize48,
        fontWeight: black,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingTight,
        height: lineHeightTight,
      );

  static TextStyle get displayMedium => GoogleFonts.notoSans(
        fontSize: fontSize40,
        fontWeight: extraBold,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingTight,
        height: lineHeightTight,
      );

  static TextStyle get displaySmall => GoogleFonts.notoSans(
        fontSize: fontSize36,
        fontWeight: bold,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingNormal,
        height: lineHeightTight,
      );

  /// Headline 스타일 (섹션 제목용)
  static TextStyle get headlineLarge => GoogleFonts.notoSans(
        fontSize: fontSize32,
        fontWeight: bold,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
      );

  static TextStyle get headlineMedium => GoogleFonts.notoSans(
        fontSize: fontSize28,
        fontWeight: bold,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
      );

  static TextStyle get headlineSmall => GoogleFonts.notoSans(
        fontSize: fontSize24,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
      );

  /// Title 스타일 (컴포넌트 제목용)
  static TextStyle get titleLarge => GoogleFonts.notoSans(
        fontSize: fontSize22,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
      );

  static TextStyle get titleMedium => GoogleFonts.notoSans(
        fontSize: fontSize20,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
      );

  static TextStyle get titleSmall => GoogleFonts.notoSans(
        fontSize: fontSize18,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
      );

  /// Body 스타일 (본문용)
  static TextStyle get bodyLarge => GoogleFonts.notoSans(
        fontSize: fontSize16,
        fontWeight: regular,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingNormal,
        height: lineHeightRelaxed,
      );

  static TextStyle get bodyMedium => GoogleFonts.notoSans(
        fontSize: fontSize14,
        fontWeight: regular,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
      );

  static TextStyle get bodySmall => GoogleFonts.notoSans(
        fontSize: fontSize12,
        fontWeight: regular,
        color: AppColors.textSecondary,
        letterSpacing: letterSpacingWide,
        height: lineHeightNormal,
      );

  /// Label 스타일 (라벨, 버튼 텍스트용)
  static TextStyle get labelLarge => GoogleFonts.notoSans(
        fontSize: fontSize16,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingWide,
        height: lineHeightNormal,
      );

  static TextStyle get labelMedium => GoogleFonts.notoSans(
        fontSize: fontSize14,
        fontWeight: medium,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingWide,
        height: lineHeightNormal,
      );

  static TextStyle get labelSmall => GoogleFonts.notoSans(
        fontSize: fontSize12,
        fontWeight: medium,
        color: AppColors.textSecondary,
        letterSpacing: letterSpacingExtraWide,
        height: lineHeightNormal,
      );

  /// 특수 용도 스타일
  /// 버튼 텍스트
  static TextStyle get button => GoogleFonts.notoSans(
        fontSize: fontSize16,
        fontWeight: semiBold,
        color: Colors.white,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
      );

  /// 캡션 (설명 텍스트)
  static TextStyle get caption => GoogleFonts.notoSans(
        fontSize: fontSize11,
        fontWeight: regular,
        color: AppColors.textTertiary,
        letterSpacing: letterSpacingWide,
        height: lineHeightNormal,
      );

  /// 오버라인 (상단 라벨)
  static TextStyle get overline => GoogleFonts.notoSans(
        fontSize: fontSize10,
        fontWeight: medium,
        color: AppColors.textTertiary,
        letterSpacing: letterSpacingExtraWide,
        height: lineHeightNormal,
      );

  /// 가격 표시용 (강조)
  static TextStyle get price => GoogleFonts.notoSans(
        fontSize: fontSize20,
        fontWeight: bold,
        color: AppColors.primary,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
      );

  /// 포인트 표시용
  static TextStyle get points => GoogleFonts.notoSans(
        fontSize: fontSize24,
        fontWeight: extraBold,
        color: AppColors.accent,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
      );

  /// 에러 메시지
  static TextStyle get error => GoogleFonts.notoSans(
        fontSize: fontSize14,
        fontWeight: medium,
        color: AppColors.error,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
      );

  /// 성공 메시지
  static TextStyle get success => GoogleFonts.notoSans(
        fontSize: fontSize14,
        fontWeight: medium,
        color: AppColors.success,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
      );

  /// 경고 메시지
  static TextStyle get warning => GoogleFonts.notoSans(
        fontSize: fontSize14,
        fontWeight: medium,
        color: AppColors.warning,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
      );

  /// 정보 메시지
  static TextStyle get info => GoogleFonts.notoSans(
        fontSize: fontSize14,
        fontWeight: medium,
        color: AppColors.info,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
      );

  /// 링크 텍스트
  static TextStyle get link => GoogleFonts.notoSans(
        fontSize: fontSize14,
        fontWeight: medium,
        color: AppColors.primary,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
        decoration: TextDecoration.underline,
      );

  /// 플레이스홀더 텍스트
  static TextStyle get placeholder => GoogleFonts.notoSans(
        fontSize: fontSize14,
        fontWeight: regular,
        color: AppColors.textTertiary,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
      );

  /// 앱바 제목
  static TextStyle get appBarTitle => GoogleFonts.notoSans(
        fontSize: fontSize20,
        fontWeight: semiBold,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingNormal,
        height: lineHeightNormal,
      );

  /// 탭 라벨
  static TextStyle get tabLabel => GoogleFonts.notoSans(
        fontSize: fontSize14,
        fontWeight: medium,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingWide,
        height: lineHeightNormal,
      );

  /// 네비게이션 라벨
  static TextStyle get navLabel => GoogleFonts.notoSans(
        fontSize: fontSize11,
        fontWeight: medium,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingWide,
        height: lineHeightNormal,
      );

  /// 칩 라벨
  static TextStyle get chipLabel => GoogleFonts.notoSans(
        fontSize: fontSize12,
        fontWeight: medium,
        color: AppColors.textPrimary,
        letterSpacing: letterSpacingWide,
        height: lineHeightNormal,
      );

  /// 배지 텍스트
  static TextStyle get badge => GoogleFonts.notoSans(
        fontSize: fontSize10,
        fontWeight: bold,
        color: Colors.white,
        letterSpacing: letterSpacingWide,
        height: lineHeightNormal,
      );
}

/// 텍스트 스타일 확장 메서드
extension TextStyleExtensions on TextStyle {
  /// 색상 변경
  TextStyle withColor(Color color) => copyWith(color: color);

  /// 폰트 크기 변경
  TextStyle withSize(double size) => copyWith(fontSize: size);

  /// 폰트 가중치 변경
  TextStyle withWeight(FontWeight weight) => copyWith(fontWeight: weight);

  /// 자간 변경
  TextStyle withLetterSpacing(double letterSpacing) =>
      copyWith(letterSpacing: letterSpacing);

  /// 줄 간격 변경
  TextStyle withHeight(double height) => copyWith(height: height);

  /// 장식 추가
  TextStyle withDecoration(TextDecoration decoration) =>
      copyWith(decoration: decoration);

  /// 그림자 추가
  TextStyle withShadow({
    Color color = Colors.black26,
    Offset offset = const Offset(0, 2),
    double blurRadius = 4,
  }) =>
      copyWith(
        shadows: [
          Shadow(
            color: color,
            offset: offset,
            blurRadius: blurRadius,
          ),
        ],
      );

  /// 기울임
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  /// 밑줄
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);

  /// 취소선
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);

  /// 대문자
  TextStyle get uppercase => this;

  /// 소문자
  TextStyle get lowercase => this;
}

/// 반응형 타이포그래피 헬퍼
class ResponsiveTypography {
  /// 화면 크기에 따른 폰트 크기 조정
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      // 모바일
      return baseFontSize;
    } else if (screenWidth < 1200) {
      // 태블릿
      return baseFontSize * 1.1;
    } else {
      // 데스크톱
      return baseFontSize * 1.2;
    }
  }

  /// 반응형 텍스트 스타일
  static TextStyle getResponsiveStyle(BuildContext context, TextStyle baseStyle) {
    final responsiveFontSize = getResponsiveFontSize(
      context,
      baseStyle.fontSize ?? AppTypography.fontSize14,
    );

    return baseStyle.copyWith(fontSize: responsiveFontSize);
  }
}

/// 접근성을 고려한 타이포그래피 헬퍼
class AccessibleTypography {
  /// 최소 대비율을 보장하는 텍스트 색상
  static Color getAccessibleTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? AppColors.textPrimary : Colors.white;
  }

  /// 접근성을 고려한 폰트 크기 (최소 크기 보장)
  static double getAccessibleFontSize(double fontSize) {
    const minFontSize = 12.0; // 접근성 가이드라인 최소 크기
    return fontSize < minFontSize ? minFontSize : fontSize;
  }

  /// 색각 이상자를 고려한 텍스트 스타일
  static TextStyle getColorBlindFriendlyStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      fontWeight: FontWeight.w600, // 더 굵은 폰트로 가독성 향상
      letterSpacing: 0.2, // 자간 확대
    );
  }
}