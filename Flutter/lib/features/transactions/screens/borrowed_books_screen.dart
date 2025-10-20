import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/models/transaction.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 구매한 교재 화면
/// 내가 빌린 교재 목록을 표시합니다.
class BorrowedBooksScreen extends StatefulWidget {
  const BorrowedBooksScreen({super.key});

  @override
  State<BorrowedBooksScreen> createState() => _BorrowedBooksScreenState();
}

class _BorrowedBooksScreenState extends State<BorrowedBooksScreen> {
  final DateFormat _dateFormat = DateFormat('yyyy.MM.dd');
  final NumberFormat _numberFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();

    // 내가 빌린 교재 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final transactionProvider = context.read<TransactionProvider>();

      if (authProvider.currentUser != null) {
        transactionProvider.fetchMyBorrowingTransactions(
          authProvider.currentUser!.id,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('구매한 교재')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          // 로딩 중
          if (provider.isLoading && provider.myBorrowingTransactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // 에러 발생
          if (provider.errorMessage != null) {
            return _buildErrorState(provider.errorMessage!);
          }

          // 구매한 교재가 없을 때
          if (provider.myBorrowingTransactions.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.shopping_bag_outlined,
              title: '구매한 교재가 없습니다',
              description: '교재를 검색하고 필요한 교재를 구매해보세요!',
            );
          }

          // 교재 목록 표시
          return RefreshIndicator(
            onRefresh: () async {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.currentUser != null) {
                await provider.fetchMyBorrowingTransactions(
                  authProvider.currentUser!.id,
                );
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.myBorrowingTransactions.length,
              itemBuilder: (context, index) {
                final transaction = provider.myBorrowingTransactions[index];
                return _buildTransactionCard(transaction);
              },
            ),
          );
        },
      ),
    );
  }

  /// 거래 카드 위젯
  Widget _buildTransactionCard(Transaction transaction) {
    // Transaction 모델에서 정보 가져오기
    final bookTitle = transaction.bookTitle ?? '제목 없음';
    final bookImageUrl = transaction.bookImgUrl;
    final pointPrice = transaction.pointPrice;

    // 판매자 정보
    final sellerName = transaction.sellerName ?? '알 수 없음';

    // 상태 정보
    final status = transaction.transStatus;
    final statusText = _getStatusText(status);
    final statusColor = _getStatusColor(status);
    final transDate = transaction.transDate;

    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          // TODO: 거래 상세 페이지로 이동
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 교재 이미지
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: bookImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: bookImageUrl,
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 60,
                          height: 80,
                          color: AppColors.background,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 80,
                          color: AppColors.background,
                          child: const Icon(Icons.book),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 80,
                        color: AppColors.background,
                        child: const Icon(
                          Icons.book,
                          size: 30,
                          color: AppColors.textSecondary,
                        ),
                      ),
              ),
              const SizedBox(width: 16),

              // 교재 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      bookTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 판매자
                    Text(
                      '판매자: $sellerName',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 상태와 날짜
                    Row(
                      children: [
                        // 상태 배지
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusText,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 날짜
                        Text(
                          _dateFormat.format(transDate),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 가격
                    Text(
                      '${_numberFormat.format(pointPrice)}P',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 에러 상태 위젯
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('오류가 발생했습니다', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              final transactionProvider = context.read<TransactionProvider>();
              if (authProvider.currentUser != null) {
                transactionProvider.fetchMyBorrowingTransactions(
                  authProvider.currentUser!.id,
                );
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  /// 거래 상태 텍스트 반환
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '대기 중';
      case 'active':
        return '진행 중';
      case 'completed':
        return '완료';
      case 'cancelled':
        return '취소됨';
      default:
        return '알 수 없음';
    }
  }

  /// 거래 상태 색상 반환
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'active':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
