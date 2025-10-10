import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';

/// 반응형 디자인을 위한 헬퍼 클래스
/// 다양한 화면 크기에 적응하는 레이아웃 시스템

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

enum ScreenSize {
  small,   // < 600px
  medium,  // 600px - 1200px
  large,   // > 1200px
}

class ResponsiveHelper {
  /// 화면 브레이크포인트
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  /// 현재 디바이스 타입 반환
  static DeviceType getDeviceType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (screenWidth < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// 현재 화면 크기 반환
  static ScreenSize getScreenSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < mobileBreakpoint) {
      return ScreenSize.small;
    } else if (screenWidth < tabletBreakpoint) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }

  /// 모바일 디바이스 여부
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// 태블릿 디바이스 여부
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// 데스크톱 디바이스 여부
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// 화면 너비
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// 화면 높이
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// 안전 영역을 고려한 화면 높이
  static double safeScreenHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height -
           mediaQuery.padding.top -
           mediaQuery.padding.bottom;
  }

  /// 반응형 값 반환
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// 반응형 패딩
  static EdgeInsets responsivePadding(BuildContext context) {
    return responsiveValue(
      context,
      mobile: AppPadding.medium,
      tablet: AppPadding.large,
      desktop: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxxl,
        vertical: AppSpacing.xl,
      ),
    );
  }

  /// 반응형 마진
  static EdgeInsets responsiveMargin(BuildContext context) {
    return responsiveValue(
      context,
      mobile: AppMargin.medium,
      tablet: AppMargin.large,
      desktop: const EdgeInsets.all(AppSpacing.xxxl),
    );
  }

  /// 반응형 그리드 컬럼 수
  static int getGridColumns(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );
  }

  /// 반응형 카드 가로세로 비율
  static double getCardAspectRatio(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 0.7,
      tablet: 0.75,
      desktop: 0.8,
    );
  }

  /// 반응형 폰트 크기 스케일
  static double getFontScale(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 1.0,
      tablet: 1.1,
      desktop: 1.2,
    );
  }

  /// 최대 콘텐츠 너비 (데스크톱용)
  static double getMaxContentWidth(BuildContext context) {
    return responsiveValue(
      context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1200,
    );
  }

  /// 반응형 아이콘 크기
  static double getIconSize(BuildContext context, {double baseSize = 24}) {
    final scale = getFontScale(context);
    return baseSize * scale;
  }

  /// 반응형 간격
  static double getSpacing(BuildContext context, double baseSpacing) {
    return responsiveValue(
      context,
      mobile: baseSpacing,
      tablet: baseSpacing * 1.2,
      desktop: baseSpacing * 1.4,
    );
  }
}

/// 반응형 위젯 빌더
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);
    return builder(context, deviceType);
  }
}

/// 반응형 그리드 뷰
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double? childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.childAspectRatio,
    this.crossAxisSpacing = AppSpacing.lg,
    this.mainAxisSpacing = AppSpacing.lg,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.getGridColumns(context);
    final aspectRatio = childAspectRatio ??
                       ResponsiveHelper.getCardAspectRatio(context);

    return GridView.builder(
      padding: padding ?? ResponsiveHelper.responsivePadding(context),
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// 반응형 컨테이너 (최대 너비 제한)
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Alignment alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      margin: margin,
      color: color,
      child: Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.getMaxContentWidth(context),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 반응형 열 레이아웃
class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const ResponsiveColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = AppSpacing.lg,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveSpacing = ResponsiveHelper.getSpacing(context, spacing);

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: _addSpacing(children, responsiveSpacing),
    );
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) return children;

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }
    return spacedChildren;
  }
}

/// 반응형 행 레이아웃
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final bool wrapOnMobile;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing = AppSpacing.lg,
    this.wrapOnMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveSpacing = ResponsiveHelper.getSpacing(context, spacing);
    final isMobile = ResponsiveHelper.isMobile(context);

    // 모바일에서 Wrap으로 변경하는 옵션
    if (wrapOnMobile && isMobile) {
      return Wrap(
        spacing: responsiveSpacing,
        runSpacing: responsiveSpacing,
        children: children,
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: _addSpacing(children, responsiveSpacing),
    );
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) return children;

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing));
      }
    }
    return spacedChildren;
  }
}

/// 반응형 텍스트
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    required this.baseStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final fontScale = ResponsiveHelper.getFontScale(context);
    final responsiveStyle = baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14) * fontScale,
    );

    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// 화면 크기별 위젯 표시
class ScreenSizeBuilder extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ScreenSizeBuilder({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? Container();
      case DeviceType.tablet:
        return tablet ?? mobile ?? Container();
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile ?? Container();
    }
  }
}

/// 반응형 패딩 위젯
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.responsiveValue(
      context,
      mobile: mobile ?? AppPadding.medium,
      tablet: tablet ?? AppPadding.large,
      desktop: desktop ?? const EdgeInsets.all(AppSpacing.xxxl),
    );

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// 미디어 쿼리 확장
extension MediaQueryExtensions on MediaQueryData {
  bool get isMobile => size.width < ResponsiveHelper.mobileBreakpoint;
  bool get isTablet => size.width >= ResponsiveHelper.mobileBreakpoint &&
                      size.width < ResponsiveHelper.tabletBreakpoint;
  bool get isDesktop => size.width >= ResponsiveHelper.tabletBreakpoint;

  DeviceType get deviceType {
    if (isMobile) return DeviceType.mobile;
    if (isTablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }
}