import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../data/models/book.dart';
import '../../../data/providers/book_provider.dart';
import '../../../data/providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 내 교재 관리 화면
/// 사용자가 등록한 교재를 관리하고 수정/삭제할 수 있습니다.
class MyBooksScreen extends StatefulWidget {
  const MyBooksScreen({super.key});

  @override
  State<MyBooksScreen> createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen> {
  final NumberFormat _numberFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();

    // 내 교재 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final bookProvider = context.read<BookProvider>();

      if (authProvider.currentUser != null) {
        bookProvider.fetchMyBooks(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 교재 관리'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
      ),
      body: Consumer<BookProvider>(
        builder: (context, provider, child) {
          // 로딩 중
          if (provider.isLoading && provider.myBooks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // 에러 발생
          if (provider.errorMessage != null) {
            return _buildErrorState(provider.errorMessage!);
          }

          // 등록한 교재가 없을 때
          if (provider.myBooks.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.book_outlined,
              title: '등록한 교재가 없습니다',
              description: '교재를 등록하고 다른 학생들과 공유해보세요!',
              actionText: '교재 등록하기',
              onAction: () => context.push('/register'),
            );
          }

          // 교재 목록 표시
          return RefreshIndicator(
            onRefresh: () async {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.currentUser != null) {
                await provider.fetchMyBooks(authProvider.currentUser!.id);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.myBooks.length,
              itemBuilder: (context, index) {
                final book = provider.myBooks[index];
                return _buildBookCard(book);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/register'),
        icon: const Icon(Icons.add),
        label: const Text('교재 등록'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// 교재 카드 위젯
  Widget _buildBookCard(Book book) {
    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          context.push('/book/${book.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 교재 이미지
              Hero(
                tag: 'book-${book.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: book.imgUrl != null
                      ? CachedNetworkImage(
                          imageUrl: book.imgUrl!,
                          width: 80,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 80,
                            height: 100,
                            color: AppColors.background,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 80,
                            height: 100,
                            color: AppColors.background,
                            child: const Icon(Icons.book),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 100,
                          color: AppColors.background,
                          child: const Icon(
                            Icons.book,
                            size: 40,
                            color: AppColors.textSecondary,
                          ),
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
                      book.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 저자
                    Text(
                      book.author,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // 상태와 가격
                    Row(
                      children: [
                        // 상태 배지
                        if (book.conditionGrade != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getConditionColor(book.conditionGrade!)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getConditionText(book.conditionGrade!),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: _getConditionColor(
                                        book.conditionGrade!),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        const SizedBox(width: 8),

                        // 가격
                        Text(
                          '${_numberFormat.format(book.pointPrice)}P',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 액션 버튼들
                    Row(
                      children: [
                        // 수정 버튼
                        OutlinedButton.icon(
                          onPressed: () {
                            // TODO: 교재 수정 페이지로 이동
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('교재 수정 기능은 준비 중입니다')),
                            );
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('수정'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 삭제 버튼
                        OutlinedButton.icon(
                          onPressed: () => _showDeleteDialog(book),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('삭제'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
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
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            '오류가 발생했습니다',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              final bookProvider = context.read<BookProvider>();
              if (authProvider.currentUser != null) {
                bookProvider.fetchMyBooks(authProvider.currentUser!.id);
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  /// 삭제 확인 다이얼로그
  void _showDeleteDialog(Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('교재 삭제'),
        content: Text('${book.title}을(를) 삭제하시겠습니까?\n이 작업은 취소할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBook(book);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('삭제'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  /// 교재 삭제
  Future<void> _deleteBook(Book book) async {
    final provider = context.read<BookProvider>();
    final success = await provider.deleteBook(book.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('교재가 삭제되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? '교재 삭제에 실패했습니다'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 상태 등급에 따른 색상 반환
  Color _getConditionColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'excellent':
        return AppColors.success;
      case 'good':
        return AppColors.primary;
      case 'fair':
        return AppColors.warning;
      case 'poor':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  /// 상태 등급에 따른 텍스트 반환
  String _getConditionText(String grade) {
    switch (grade.toLowerCase()) {
      case 'excellent':
        return '최상';
      case 'good':
        return '양호';
      case 'fair':
        return '보통';
      case 'poor':
        return '불량';
      default:
        return '알 수 없음';
    }
  }
}
