import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 프리미엄 디자인의 버튼 컴포넌트
class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isGradient;
  final List<Color>? gradientColors;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double elevation;
  final ButtonType type;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isGradient = true,
    this.gradientColors,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height = 56,
    this.padding,
    this.borderRadius,
    this.elevation = 3,
    this.type = ButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColorsForType();
    final borderRadius = this.borderRadius ?? BorderRadius.circular(16);

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: isGradient && !isLoading
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors ?? colors['gradientColors'],
              )
            : null,
        color: isGradient ? null : (backgroundColor ?? colors['backgroundColor']),
        boxShadow: elevation > 0 && onPressed != null
            ? [
                BoxShadow(
                  color: (colors['shadowColor'] as Color).withValues(alpha:0.3),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation / 2),
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius,
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null && !isLoading) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                if (isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? colors['textColor'],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  isLoading ? '로딩 중...' : text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor ?? colors['textColor'],
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getColorsForType() {
    switch (type) {
      case ButtonType.primary:
        return {
          'gradientColors': AppColors.primaryGradientColors,
          'backgroundColor': AppColors.primary,
          'textColor': Colors.white,
          'shadowColor': AppColors.primary,
        };
      case ButtonType.secondary:
        return {
          'gradientColors': AppColors.secondaryGradientColors,
          'backgroundColor': AppColors.secondary,
          'textColor': Colors.white,
          'shadowColor': AppColors.secondary,
        };
      case ButtonType.accent:
        return {
          'gradientColors': AppColors.accentGradientColors,
          'backgroundColor': AppColors.accent,
          'textColor': Colors.white,
          'shadowColor': AppColors.accent,
        };
      case ButtonType.outlined:
        return {
          'gradientColors': [Colors.transparent, Colors.transparent],
          'backgroundColor': Colors.transparent,
          'textColor': AppColors.primary,
          'shadowColor': AppColors.primary,
        };
      case ButtonType.text:
        return {
          'gradientColors': [Colors.transparent, Colors.transparent],
          'backgroundColor': Colors.transparent,
          'textColor': AppColors.primary,
          'shadowColor': Colors.transparent,
        };
    }
  }
}

/// 아웃라인 버튼 특화 컴포넌트
class PremiumOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color borderColor;
  final Color textColor;
  final Widget? icon;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const PremiumOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.borderColor = AppColors.primary,
    this.textColor = AppColors.primary,
    this.icon,
    this.width,
    this.height = 56,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(16);

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: onPressed != null ? borderColor : AppColors.divider,
          width: 1.5,
        ),
        color: onPressed != null
            ? borderColor.withValues(alpha:0.05)
            : AppColors.surfaceVariant,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null && !isLoading) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                if (isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  isLoading ? '로딩 중...' : text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: onPressed != null
                            ? textColor
                            : AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 플로팅 액션 버튼 특화 컴포넌트
class PremiumFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String? tooltip;
  final bool isExtended;
  final String? label;

  const PremiumFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.isExtended = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (isExtended && label != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha:0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: onPressed,
          icon: icon,
          label: Text(
            label!,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          tooltip: tooltip,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        tooltip: tooltip,
        child: icon,
      ),
    );
  }
}

enum ButtonType {
  primary,
  secondary,
  accent,
  outlined,
  text,
}