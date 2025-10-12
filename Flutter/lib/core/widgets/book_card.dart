import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import 'premium_card.dart';

/// 교재 정보를 표시하는 카드 위젯
/// 홈화면 및 검색 결과에서 사용
class BookDisplayCard extends StatelessWidget {
  final String title;
  final String author;
  final String condition;
  final String price;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool isWishlisted;
  final VoidCallback? onWishlistTap;

  const BookDisplayCard({
    super.key,
    required this.title,
    required this.author,
    required this.condition,
    required this.price,
    this.imageUrl,
    this.onTap,
    this.isWishlisted = false,
    this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 책 이미지 섹션
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // 메인 이미지
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.cardRadius),
                    ),
                  ),
                  child: imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppSpacing.cardRadius),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _buildImagePlaceholder(),
                            errorWidget: (context, url, error) => _buildImagePlaceholder(),
                          ),
                        )
                      : _buildImagePlaceholder(),
                ),
                // 위시리스트 버튼
                if (onWishlistTap != null)
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onWishlistTap,
                          borderRadius: BorderRadius.circular(16),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isWishlisted ? AppColors.error : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                // 상태 배지
                Positioned(
                  bottom: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getConditionColor(condition).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                    ),
                    child: Text(
                      condition,
                      style: AppTypography.labelSmall.withColor(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 정보 섹션
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    title,
                    style: AppTypography.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // 저자
                  Text(
                    author,
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // 가격 및 추가 정보
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: AppTypography.titleSmall.withColor(AppColors.primary),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: AppColors.textTertiary,
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

  /// 이미지 플레이스홀더 위젯
  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 32,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '이미지 없음',
            style: AppTypography.labelSmall,
          ),
        ],
      ),
    );
  }

  /// 상태에 따른 색상 반환
  Color _getConditionColor(String condition) {
    switch (condition) {
      case '최상':
        return AppColors.success;
      case '상':
        return AppColors.info;
      case '중':
        return AppColors.warning;
      case '하':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

/// 컴팩트한 가로형 책 카드 (리스트용)
class BookCardHorizontal extends StatelessWidget {
  final String title;
  final String author;
  final String condition;
  final String price;
  final String? imageUrl;
  final VoidCallback? onTap;

  const BookCardHorizontal({
    super.key,
    required this.title,
    required this.author,
    required this.condition,
    required this.price,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // 썸네일 이미지
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildThumbnailPlaceholder(),
                      errorWidget: (context, url, error) => _buildThumbnailPlaceholder(),
                    ),
                  )
                : _buildThumbnailPlaceholder(),
          ),
          const SizedBox(width: AppSpacing.md),
          // 정보 섹션
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  author,
                  style: AppTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _getConditionColor(condition).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                      ),
                      child: Text(
                        condition,
                        style: AppTypography.labelSmall.withColor(_getConditionColor(condition)),
                      ),
                    ),
                    Text(
                      price,
                      style: AppTypography.titleSmall.withColor(AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Icon(
        Icons.menu_book_outlined,
        size: 24,
        color: AppColors.textTertiary,
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case '최상':
        return AppColors.success;
      case '상':
        return AppColors.info;
      case '중':
        return AppColors.warning;
      case '하':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}