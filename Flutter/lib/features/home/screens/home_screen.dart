import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/book_provider.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/point_provider.dart';
import '../../../data/models/book.dart';
import '../../../data/services/ocr_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 로드 시 데이터 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  /// 초기 데이터 로드
  Future<void> _initializeData() async {
    final authProvider = context.read<AuthProvider>();
    final bookProvider = context.read<BookProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final pointProvider = context.read<PointProvider>();

    // 인증 상태 확인
    await authProvider.checkAuthState();

    if (authProvider.currentUser != null) {
      final userId = authProvider.currentUser!.id;

      // 병렬로 데이터 로드
      await Future.wait([
        bookProvider.fetchRecommendedBooks(userId),
        transactionProvider.fetchActiveTransactions(userId),
        pointProvider.fetchBalance(userId),
      ]);
    }
  }

  /// 새로고침 처리
  Future<void> _onRefresh() async {
    await _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: _buildAppBar(context),
      body:
          Consumer4<
            AuthProvider,
            BookProvider,
            TransactionProvider,
            PointProvider
          >(
            builder:
                (
                  context,
                  authProvider,
                  bookProvider,
                  transactionProvider,
                  pointProvider,
                  child,
                ) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AppColors.primary,
                    backgroundColor: Colors.white,
                    strokeWidth: 2.5,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // 웰컴 섹션과 포인트 카드
                        SliverToBoxAdapter(
                          child: ResponsivePadding(
                            child: Column(
                              children: [
                                AnimatedSlideUp(
                                  delay: Duration.zero,
                                  child: _buildWelcomeCard(
                                    context,
                                    authProvider,
                                  ),
                                ),
                                const SizedBox(
                                  height: AppSpacing.sectionSpacing,
                                ),
                                AnimatedSlideUp(
                                  delay: const Duration(milliseconds: 100),
                                  child: _buildQuickActions(context),
                                ),
                                const SizedBox(
                                  height: AppSpacing.sectionSpacing,
                                ),
                                AnimatedSlideUp(
                                  delay: const Duration(milliseconds: 200),
                                  child: _buildActiveTransactions(
                                    context,
                                    transactionProvider,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxxl),
                                AnimatedSlideUp(
                                  delay: const Duration(milliseconds: 300),
                                  child: _buildSectionHeader(
                                    context,
                                    '추천 교재',
                                    '모두 보기',
                                    () => context.go('/search'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 추천 교재 그리드
                        _buildRecommendedBooksGrid(context, bookProvider),
                        // 하단 패딩
                        const SliverPadding(
                          padding: EdgeInsets.only(bottom: 100),
                        ),
                      ],
                    ),
                  );
                },
          ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      actions: [_buildNotificationButton(context), const SizedBox(width: 12)],
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.notifications_outlined,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
              ),
              // 알림 배지
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    final userName = user?.name ?? '사용자';
    // PointProvider에서 포인트 조회
    final pointProvider = context.watch<PointProvider>();
    final userPoints = pointProvider.currentBalance?.pointTotal ?? 0;

    return PremiumCard(
      hasGradient: true,
      gradientColors: AppColors.primaryGradientColors,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$userName님, 안녕하세요! 👋',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '오늘도 지속가능한 교재 공유를\n함께해보세요',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '보유 포인트',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          userPoints.toString(),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        Text(
                          ' P',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.go('/transactions'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '내역 보기',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                '교재 등록',
                '내 교재를 공유하고\n포인트를 받으세요',
                Icons.add_circle_outline,
                AppColors.primarySoft,
                AppColors.primary,
                () => context.go('/register'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                context,
                '교재 찾기',
                '필요한 교재를\n쉽게 찾아보세요',
                Icons.search_rounded,
                AppColors.secondarySoft,
                AppColors.secondary,
                () => context.go('/search'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildQuickActionCard(
          context,
          'OCR 촬영 (임시)',
          '카메라로 교재를 촬영하여\n자동으로 정보를 추출하세요',
          Icons.camera_alt_rounded,
          const Color(0xFFFFF3E0),
          const Color(0xFFFF9800),
          () => _showOcrSourceDialog(context),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color backgroundColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return PremiumCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String actionText,
    VoidCallback onActionTap,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onActionTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 진행 중인 거래 표시
  Widget _buildActiveTransactions(
    BuildContext context,
    TransactionProvider transactionProvider,
  ) {
    final activeTransactions = transactionProvider.activeTransactions;

    if (activeTransactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _buildSectionHeader(
          context,
          '진행 중인 거래',
          '전체 보기',
          () => context.go('/transactions'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: activeTransactions.length,
            itemBuilder: (context, index) {
              final transaction = activeTransactions[index];
              return Container(
                width: 280,
                margin: EdgeInsets.only(
                  right: index < activeTransactions.length - 1 ? 16 : 0,
                ),
                child: _buildTransactionCard(context, transaction),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 거래 카드
  Widget _buildTransactionCard(BuildContext context, transaction) {
    return PremiumCard(
      backgroundColor: AppColors.surfaceVariant,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: transaction.transStatus == 'active'
                      ? AppColors.success
                      : AppColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '책 제목: ${transaction.bookTitle ?? "책 제목 없음"}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '구매자: ${transaction.borrowerName ?? "미정"}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '가격: ${transaction.pointPrice ?? "미정"}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  transaction.transStatusDisplayName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 추천 교재 그리드
  Widget _buildRecommendedBooksGrid(
    BuildContext context,
    BookProvider bookProvider,
  ) {
    final recommendedBooks = bookProvider.recommendedBooks;

    if (bookProvider.isLoading) {
      return SliverPadding(
        padding: ResponsiveHelper.responsivePadding(context),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveHelper.getGridColumns(context),
            childAspectRatio: ResponsiveHelper.getCardAspectRatio(context),
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) =>
                ShimmerLoading(isLoading: true, child: _buildShimmerCard()),
            childCount: 6,
          ),
        ),
      );
    }

    if (recommendedBooks.isEmpty) {
      return SliverToBoxAdapter(
        child: AnimatedSlideUp(
          delay: const Duration(milliseconds: 400),
          child: EmptyStateWidget.noBooks(
            onAddBook: () => context.go('/register'),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: ResponsiveHelper.responsivePadding(context),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveHelper.getGridColumns(context),
          childAspectRatio: ResponsiveHelper.getCardAspectRatio(context),
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.lg,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final book = recommendedBooks[index];
          return AnimatedSlideUp(
            delay: Duration(milliseconds: 500 + (index * 50)),
            child: BookDisplayCard(
              title: book.title,
              author: book.author,
              condition: book.conditionGradeDisplayName,
              price: '${book.pointPrice} P',
              imageUrl: book.imgUrl,
              onTap: () => _showBookDetailDialog(book),
            ),
          );
        }, childCount: recommendedBooks.length),
      ),
    );
  }

  /// 로딩 시뮬레이션용 Shimmer 카드
  Widget _buildShimmerCard() {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
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

  /// 책 상세 정보 다이얼로그
  void _showBookDetailDialog(Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('저자: ${book.author}'),
            Text('출판사: ${book.publisher ?? "미상"}'),
            Text('상태: ${book.conditionGradeDisplayName}'),
            Text('가격: ${book.pointPrice} P'),
            if (book.dmgTag != null) ...[
              const SizedBox(height: 8),
              Text('손상 태그: ${book.dmgTag}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestBookTransaction(book);
            },
            child: const Text('대여 요청'),
          ),
        ],
      ),
    );
  }

  /// 대여 요청 처리
  Future<void> _requestBookTransaction(Book book) async {
    final authProvider = context.read<AuthProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      _showSnackBar('로그인이 필요합니다');
      return;
    }

    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // 거래 생성 요청
    final result = await transactionProvider.createTransaction(
      bookId: book.id,
      borrowerId: currentUser.id,
    );

    // 로딩 다이얼로그 닫기
    if (mounted) Navigator.of(context).pop();

    // 결과 표시
    if (!mounted) return;

    if (result['success'] == true) {
      // 성공
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('거래 신청 완료'),
          content: Text(
            '${result['point_spent']}P가 차감되었습니다.\n'
            '거래가 완료되면 판매자에게 포인트가 지급됩니다.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      // 실패
      final message = result['message'];
      final required = result['required'];
      final current = result['current'];

      String detailMessage = message ?? '거래 신청에 실패했습니다';
      if (required != null && current != null) {
        detailMessage += '\n\n필요 포인트: ${required}P\n현재 포인트: ${current}P';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('거래 신청 실패'),
          content: Text(detailMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  /// 스낵바 표시
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// OCR 소스 선택 다이얼로그
  void _showOcrSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OCR 방식 선택'),
        content: const Text('어떤 방식으로 이미지를 제공하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/ocr-camera');
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt),
                SizedBox(width: 8),
                Text('카메라 촬영'),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _pickImageForOcr();
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_library),
                SizedBox(width: 8),
                Text('사진 업로드'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 갤러리에서 이미지 선택 후 OCR 처리
  Future<void> _pickImageForOcr() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // OCR 처리
        final OcrService ocrService = OcrService();

        // 로딩 다이얼로그 표시
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        try {
          final result = await ocrService.extractBookInfo(image);

          // 로딩 다이얼로그 닫기
          if (mounted) Navigator.of(context).pop();

          // OCR 결과와 이미지를 등록 화면으로 전달
          if (mounted) {
            final dataToPass = {
              ...result,
              'capturedImage': image,
            };
            context.go('/register', extra: dataToPass);
          }
        } catch (e) {
          // 로딩 다이얼로그 닫기
          if (mounted) Navigator.of(context).pop();

          // 에러 표시
          if (mounted) {
            _showSnackBar('OCR 처리 실패: ${e.toString()}');
          }
        }
      }
    } catch (e) {
      _showSnackBar('이미지 선택 실패: ${e.toString()}');
    }
  }
}
