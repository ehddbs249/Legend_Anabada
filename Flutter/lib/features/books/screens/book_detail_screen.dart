import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../data/models/book.dart';
import '../../../data/models/user.dart' as app_user;
import '../../../data/providers/book_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../app/routes/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 책 상세 화면
/// 책의 상세 정보, 판매자 정보, 대여 요청 기능 제공
class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({
    super.key,
    required this.bookId,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Book? _book;
  app_user.User? _seller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBookDetails();
  }

  /// 책 상세 정보 및 판매자 정보 로드
  Future<void> _loadBookDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      final book = await bookProvider.getBook(widget.bookId);

      if (book == null) {
        setState(() {
          _errorMessage = '책 정보를 찾을 수 없습니다.';
          _isLoading = false;
        });
        return;
      }

      // 판매자 정보 로드
      final sellerData = await Supabase.instance.client
          .from('User')
          .select()
          .eq('user_id', book.userId)
          .single();

      setState(() {
        _book = book;
        _seller = app_user.User.fromJson(sellerData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '정보를 불러오는데 실패했습니다: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// 대여 요청 확인 다이얼로그
  Future<void> _showRentalConfirmDialog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      _showErrorDialog('로그인이 필요합니다.');
      return;
    }

    if (_book == null) {
      _showErrorDialog('책 정보를 찾을 수 없습니다.');
      return;
    }

    // 본인 책인 경우
    if (_book!.userId == currentUser.id) {
      _showErrorDialog('본인이 등록한 책은 대여할 수 없습니다.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('대여 요청'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_book!.title}을(를) 대여하시겠습니까?'),
            const SizedBox(height: AppSpacing.md),
            Text(
              '대여 포인트: ${_book!.pointPrice} P',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('대여 요청'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _requestRental();
    }
  }

  /// 대여 요청 처리
  Future<void> _requestRental() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null || _book == null) return;

    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 거래 생성
      final result = await transactionProvider.createTransaction(
        bookId: _book!.id,
        borrowerId: currentUser.id,
      );

      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.of(context).pop();

      if (result['success'] == true) {
        // 성공 시 거래 내역 화면으로 이동하고 성공 메시지 표시
        if (mounted) {
          _showSuccessDialog('대여 요청이 완료되었습니다.\n거래 내역에서 확인해주세요.');
        }
      } else {
        // 실패 시 에러 메시지 표시
        final message = result['message'] as String? ?? '대여 요청에 실패했습니다.';
        _showErrorDialog(message);
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showErrorDialog('대여 요청 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 성공 다이얼로그
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('성공'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.transactions);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 에러 다이얼로그
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 판매자 프로필 보기
  void _showSellerProfile() {
    if (_seller == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // 판매자 정보
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(
                    _seller!.name[0],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _seller!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _seller!.department,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            // 추가 정보
            _buildInfoRow(Icons.school_rounded, '학번', _seller!.studentNumber),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow(Icons.email_rounded, '이메일', _seller!.email),
            if (_seller!.grade != null) ...[
              const SizedBox(height: AppSpacing.md),
              _buildInfoRow(Icons.grade_rounded, '학년', _seller!.grade!),
            ],
            const Spacer(),
            // 닫기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('책 상세'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              // TODO: 공유 기능 구현
            },
          ),
          IconButton(
            icon: const Icon(Icons.report_rounded),
            onPressed: () {
              // TODO: 신고 기능 구현
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ElevatedButton(
                        onPressed: _loadBookDetails,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
      floatingActionButton: _book != null && _errorMessage == null
          ? FloatingActionButton.extended(
              onPressed: _showRentalConfirmDialog,
              icon: const Icon(Icons.shopping_cart_rounded),
              label: const Text('대여 요청'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  Widget _buildContent() {
    if (_book == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 책 이미지 (Hero 애니메이션)
          _buildBookImage(),
          const SizedBox(height: AppSpacing.lg),

          // 책 기본 정보 카드
          _buildBookInfoCard(),
          const SizedBox(height: AppSpacing.md),

          // 가격 정보 카드
          _buildPriceInfoCard(),
          const SizedBox(height: AppSpacing.md),

          // 판매자 정보 카드
          _buildSellerInfoCard(),

          // FloatingActionButton 공간 확보
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  /// 책 이미지 위젯
  Widget _buildBookImage() {
    return Hero(
      tag: 'book-${_book!.id}',
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.surfaceVariant,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _book!.imgUrl != null
              ? CachedNetworkImage(
                  imageUrl: _book!.imgUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => _buildPlaceholderImage(),
                )
              : _buildPlaceholderImage(),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        Icons.menu_book_rounded,
        size: 80,
        color: AppColors.primary.withValues(alpha: 0.6),
      ),
    );
  }

  /// 책 기본 정보 카드
  Widget _buildBookInfoCard() {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기본 정보',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _book!.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoItem(Icons.person_rounded, '저자', _book!.author),
          if (_book!.publisher != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _buildInfoItem(Icons.business_rounded, '출판사', _book!.publisher!),
          ],
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '상태',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getConditionColor(_book!.conditionGradeDisplayName)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _book!.conditionGradeDisplayName,
                        style: TextStyle(
                          color: _getConditionColor(_book!.conditionGradeDisplayName),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_book!.dmgTag != null) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '손상 태그',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _book!.dmgTag!,
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// 가격 정보 카드
  Widget _buildPriceInfoCard() {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '가격 정보',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '대여 가격',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_book!.pointPrice} P',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 판매자 정보 카드
  Widget _buildSellerInfoCard() {
    if (_seller == null) return const SizedBox();

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '판매자 정보',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  _seller!.name[0],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _seller!.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _seller!.department,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                child: OutlinedButton(
                  onPressed: _showSellerProfile,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  child: const Text('프로필'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
      case '나쁨':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}
