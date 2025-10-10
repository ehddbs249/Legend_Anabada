import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 프리미엄 디자인의 카드 컴포넌트
/// 그라데이션 배경, 부드러운 그림자, 세련된 테두리를 제공
class PremiumCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;
  final bool hasGradient;
  final bool hasElevation;
  final double elevation;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;

  const PremiumCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
    this.gradientColors,
    this.hasGradient = false,
    this.hasElevation = true,
    this.elevation = 4,
    this.onTap,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(20);

    Widget card = Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: hasGradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors ?? AppColors.primaryGradientColors,
                stops: const [0.0, 1.0],
              )
            : null,
        color: hasGradient ? null : (backgroundColor ?? AppColors.cardBackground),
        border: border,
        boxShadow: hasElevation
            ? [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation / 2),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: AppColors.shadowMedium,
                  blurRadius: elevation,
                  offset: Offset(0, elevation / 4),
                  spreadRadius: -(elevation / 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ),
      ),
    );

    return card;
  }
}

/// 교재 카드용 특화 컴포넌트
class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String? publisher;
  final String? condition;
  final String price;
  final String? imageUrl;
  final String? department;
  final String? uploadTime;
  final VoidCallback? onTap;
  final bool isHorizontal;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    this.publisher,
    this.condition,
    required this.price,
    this.imageUrl,
    this.department,
    this.uploadTime,
    this.onTap,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildHorizontalCard(context);
    } else {
      return _buildVerticalCard(context);
    }
  }

  Widget _buildVerticalCard(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 섹션
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                gradient: imageUrl == null
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primarySoft,
                          AppColors.primarySoft.withValues(alpha:0.5),
                        ],
                      )
                    : null,
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderImage(),
                      ),
                    )
                  : _buildPlaceholderImage(),
            ),
          ),
          // 정보 섹션
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (condition != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getConditionColor(condition!).withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            condition!,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: _getConditionColor(condition!),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      Text(
                        price,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // 이미지 섹션
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              gradient: imageUrl == null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primarySoft,
                        AppColors.primarySoft.withValues(alpha:0.5),
                      ],
                    )
                  : null,
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderImageSmall(),
                    ),
                  )
                : _buildPlaceholderImageSmall(),
          ),
          const SizedBox(width: 16),
          // 정보 섹션
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$author${publisher != null ? ' | $publisher' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (condition != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getConditionColor(condition!).withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          condition!,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: _getConditionColor(condition!),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (department != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondarySoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          department!,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // 가격 및 시간 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (uploadTime != null) ...[
                const SizedBox(height: 8),
                Text(
                  uploadTime!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        Icons.menu_book_rounded,
        size: 48,
        color: AppColors.primary.withValues(alpha:0.6),
      ),
    );
  }

  Widget _buildPlaceholderImageSmall() {
    return Center(
      child: Icon(
        Icons.menu_book_rounded,
        size: 32,
        color: AppColors.primary.withValues(alpha:0.6),
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case '최상':
        return AppColors.success;
      case '양호':
        return AppColors.primary;
      case '보통':
        return AppColors.warning;
      case '하급':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}