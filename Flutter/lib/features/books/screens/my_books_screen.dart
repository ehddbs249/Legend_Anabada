import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../data/models/book.dart';
import '../../../data/models/locker.dart';
import '../../../data/providers/book_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/locker_provider.dart';
import '../../../app/routes/app_router.dart';
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
                    if (book.bookStatus == 'pending')
                      _buildPendingBookActions(book)
                    else
                      _buildAvailableBookActions(book),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// pending 상태 책 액션 버튼들
  Widget _buildPendingBookActions(Book book) {
    return FutureBuilder<String?>(
      future: context.read<BookProvider>().getAssignedLockerId(book.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              _buildDeleteButton(book),
            ],
          );
        }

        final hasLocker = snapshot.data != null;

        return Row(
          children: [
            // 사물함 미배정: "사물함 배정" 버튼
            if (!hasLocker)
              ElevatedButton.icon(
                onPressed: () {
                  context.push(AppRoutes.lockerAssignment(book.id, book.title));
                },
                icon: const Icon(Icons.lock_open, size: 16),
                label: const Text('사물함 배정'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
            // 사물함 배정됨: "사물함 제어" 버튼
            else
              OutlinedButton.icon(
                onPressed: () => _showLockerControlDialog(book),
                icon: const Icon(Icons.lock, size: 16),
                label: const Text('사물함 제어'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            const SizedBox(width: 8),
            _buildDeleteButton(book),
          ],
        );
      },
    );
  }

  /// available/sold 상태 책 액션 버튼들
  Widget _buildAvailableBookActions(Book book) {
    return Row(
      children: [
        // 수정 버튼
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('교재 수정 기능은 준비 중입니다')),
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
        _buildDeleteButton(book),
      ],
    );
  }

  /// 삭제 버튼
  Widget _buildDeleteButton(Book book) {
    return OutlinedButton.icon(
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

  /// 사물함 제어 다이얼로그
  Future<void> _showLockerControlDialog(Book book) async {
    final bookProvider = context.read<BookProvider>();
    final lockerProvider = context.read<LockerProvider>();

    // 책에 배정된 사물함 조회
    final lockerId = await bookProvider.getAssignedLockerId(book.id);

    if (!mounted) return;

    if (lockerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('배정된 사물함이 없습니다. 먼저 사물함을 배정해주세요.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // 사물함 정보 가져오기
    final locker = await lockerProvider.getLocker(lockerId);

    if (!mounted) return;

    if (locker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사물함 정보를 가져올 수 없습니다.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 사물함 제어 다이얼로그 표시
    showDialog(
      context: context,
      builder: (dialogContext) => _LockerControlDialog(
        book: book,
        locker: locker,
      ),
    );
  }
}

/// 사물함 제어 다이얼로그
class _LockerControlDialog extends StatefulWidget {
  final Book book;
  final Locker locker;

  const _LockerControlDialog({
    required this.book,
    required this.locker,
  });

  @override
  State<_LockerControlDialog> createState() => _LockerControlDialogState();
}

class _LockerControlDialogState extends State<_LockerControlDialog> {
  bool _isLoading = false;
  bool _isLockerOpen = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isLockerOpen ? Icons.lock_open : Icons.lock,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          const Text('사물함 제어'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '사물함 #${widget.locker.lockerNum}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _isLockerOpen ? '열림' : '닫힘',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _isLockerOpen ? AppColors.success : AppColors.primary,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _toggleLocker,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(_isLockerOpen ? Icons.lock : Icons.lock_open),
              label: Text(
                _isLoading
                    ? '처리 중...'
                    : _isLockerOpen
                        ? '사물함 닫기'
                        : '사물함 열기',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isLockerOpen ? AppColors.warning : AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, size: 16, color: AppColors.info),
                    const SizedBox(width: 8),
                    const Text(
                      '안내',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• 사물함을 열어 책을 넣은 후 반드시 닫아주세요\n'
                  '• 사물함을 닫으면 판매가 시작됩니다',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }

  /// 사물함 열기/닫기
  Future<void> _toggleLocker() async {
    setState(() => _isLoading = true);

    try {
      final lockerProvider = context.read<LockerProvider>();
      final bookProvider = context.read<BookProvider>();

      final success = _isLockerOpen
          ? await lockerProvider.closeLocker(widget.locker.id)
          : await lockerProvider.openLocker(widget.locker.id);

      if (success && mounted) {
        // 사물함을 닫았을 때 book_status를 available로 업데이트
        if (!_isLockerOpen) {
          await bookProvider.updateBookStatus(widget.book.id, 'available');

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ 사물함이 닫혔습니다! 판매가 시작되었습니다.'),
                backgroundColor: AppColors.success,
              ),
            );

            // 목록 새로고침
            final authProvider = context.read<AuthProvider>();
            if (authProvider.currentUser != null) {
              bookProvider.fetchMyBooks(authProvider.currentUser!.id);
            }
            return;
          }
        }

        setState(() => _isLockerOpen = !_isLockerOpen);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isLockerOpen ? '✅ 사물함이 열렸습니다!' : '🔒 사물함이 닫혔습니다!',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ ${lockerProvider.errorMessage ?? "사물함 제어에 실패했습니다"}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 오류: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
