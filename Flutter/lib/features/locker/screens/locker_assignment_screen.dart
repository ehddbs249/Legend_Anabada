import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/providers/locker_provider.dart';
import '../../../data/providers/book_provider.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../app/routes/app_router.dart';

/// 사물함 배정 화면
class LockerAssignmentScreen extends StatefulWidget {
  final String bookId;
  final String bookTitle;

  const LockerAssignmentScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  @override
  State<LockerAssignmentScreen> createState() => _LockerAssignmentScreenState();
}

class _LockerAssignmentScreenState extends State<LockerAssignmentScreen> {
  bool _isAssigning = false;
  String? _assignedLockerId;
  int? _assignedLockerNum;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLockerAssignment();
    });
  }

  /// 사물함 배정 요청
  Future<void> _requestLockerAssignment() async {
    // bookId 유효성 검사
    if (widget.bookId.isEmpty) {
      _showSnackBar('책 정보가 없습니다. 다시 시도해주세요.');
      if (mounted) {
        context.go(AppRoutes.home);
      }
      return;
    }

    setState(() => _isAssigning = true);

    try {
      final lockerProvider = context.read<LockerProvider>();

      // 사용 가능한 사물함 조회
      await lockerProvider.fetchAvailableLockers();
      final availableLockers = lockerProvider.availableLockers;

      if (availableLockers.isEmpty) {
        // 사물함이 없으면 대기 상태
        setState(() => _isAssigning = false);
        return;
      }

      // 첫 번째 사용 가능한 사물함 배정
      final locker = availableLockers.first;

      // locker 테이블의 current_book_id 업데이트
      await lockerProvider.assignBookToLocker(locker.id, widget.bookId);

      // 거래 목록 새로고침
      final transactionProvider = context.read<TransactionProvider>();
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        final userId = authProvider.currentUser!.id;
        await Future.wait([
          transactionProvider.fetchMyLendingTransactions(userId),
          transactionProvider.fetchMyBorrowingTransactions(userId),
          transactionProvider.fetchActiveTransactions(userId),
        ]);
      }

      setState(() {
        _assignedLockerId = locker.id;
        _assignedLockerNum = locker.lockerNum;
        _isAssigning = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isAssigning = false);
        _showSnackBar('사물함 배정 중 오류가 발생했습니다: ${e.toString()}');
      }
    }
  }

  /// 사물함 닫기 화면으로 이동
  Future<void> _goToCloseLocker() async {
    if (_assignedLockerId == null) return;

    final lockerProvider = context.read<LockerProvider>();
    final bookProvider = context.read<BookProvider>();

    // 사물함 닫기
    setState(() => _isAssigning = true);

    try {
      final success = await lockerProvider.closeLocker(_assignedLockerId!);

      if (success) {
        // book_status를 'available'로 업데이트
        await bookProvider.updateBookStatus(widget.bookId, 'available');

        if (mounted) {
          _showSnackBar('교재가 성공적으로 등록되었습니다!');
          context.go(AppRoutes.home);
        }
      } else {
        _showSnackBar(lockerProvider.errorMessage ?? '사물함 닫기에 실패했습니다');
      }
    } catch (e) {
      _showSnackBar('사물함 닫기 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isAssigning = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사물함 배정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isAssigning
            ? const Center(child: CircularProgressIndicator())
            : _assignedLockerId != null
            ? _buildAssignedView()
            : _buildWaitingView(),
      ),
    );
  }

  /// 사물함 배정 완료 화면
  Widget _buildAssignedView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_open, size: 80, color: AppColors.success),
        const SizedBox(height: 24),
        Text(
          '사물함이 배정되었습니다!',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                '사물함 #$_assignedLockerNum',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.bookTitle,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, size: 20, color: AppColors.info),
                  const SizedBox(width: 8),
                  const Text(
                    '다음 단계',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('1. 배정된 사물함에 책을 넣어주세요'),
              const Text('2. 아래 "사물함 닫기" 버튼을 눌러주세요'),
              const Text('3. 사물함이 닫히면 판매가 시작됩니다'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isAssigning ? null : _goToCloseLocker,
            icon: const Icon(Icons.lock),
            label: _isAssigning ? const Text('처리 중...') : const Text('사물함 닫기'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.go(AppRoutes.home),
          child: const Text('나중에 하기'),
        ),
      ],
    );
  }

  /// 사물함 대기 화면
  Widget _buildWaitingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.schedule, size: 80, color: AppColors.warning),
        const SizedBox(height: 24),
        Text(
          '사용 가능한 사물함이 없습니다',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          '현재 모든 사물함이 사용 중입니다.\n사물함이 비는 대로 자동으로 배정됩니다.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info, size: 20, color: AppColors.info),
                  const SizedBox(width: 8),
                  const Text(
                    '안내',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('• 등록하신 책은 "내 책" 목록에서 확인하실 수 있습니다'),
              const Text('• 사물함 배정 후 "사물함 배정 받기" 버튼이 표시됩니다'),
              const Text('• 책을 넣고 사물함을 닫으면 판매가 시작됩니다'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('홈으로 가기'),
          ),
        ),
      ],
    );
  }
}
