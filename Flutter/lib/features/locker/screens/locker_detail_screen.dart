import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../app/routes/app_router.dart';
import '../../../data/providers/locker_provider.dart';

class LockerDetailScreen extends StatefulWidget {
  final String lockerId;
  final String bookTitle;
  final String transactionId;
  final String pinCode;

  const LockerDetailScreen({
    super.key,
    required this.lockerId,
    required this.bookTitle,
    required this.transactionId,
    required this.pinCode,
  });

  @override
  State<LockerDetailScreen> createState() => _LockerDetailScreenState();
}

class _LockerDetailScreenState extends State<LockerDetailScreen> {
  bool _isLockerOpen = true; // 사물함 배정 후 열린 상태로 시작
  bool _isLoading = false;

  /// 사물함 열기
  Future<void> _openLocker() async {
    setState(() => _isLoading = true);

    try {
      final lockerProvider = context.read<LockerProvider>();
      final success = await lockerProvider.openLocker(
        widget.lockerId,
        widget.pinCode,
      );

      if (success && mounted) {
        setState(() => _isLockerOpen = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 사물함이 열렸습니다!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ ${lockerProvider.errorMessage ?? "사물함 열기에 실패했습니다"}',
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 사물함 닫기
  Future<void> _closeLocker() async {
    setState(() => _isLoading = true);

    try {
      final lockerProvider = context.read<LockerProvider>();
      final success = await lockerProvider.closeLocker(widget.lockerId);

      if (success && mounted) {
        setState(() => _isLockerOpen = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔒 사물함이 닫혔습니다!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ ${lockerProvider.errorMessage ?? "사물함 닫기에 실패했습니다"}',
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 사물함 열기 확인 다이얼로그
  Future<void> _showOpenConfirmDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('사물함 열기'),
        content: const Text('사물함을 정말 여시겠습니까?\n\n주의: 사물함을 열 경우 다시 닫을 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('아니오'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('예'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _openLocker();
    }
  }

  /// 사물함 닫기 확인 다이얼로그
  Future<void> _showCloseConfirmDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('사물함 닫기'),
        content: const Text('사물함을 정말 닫으시겠습니까?\n\n주의: 사물함을 닫을 경우 다시 열 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('아니오'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('예'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _closeLocker();
    }
  }

  /// 사물함 토글 (열림 ↔ 닫힘)
  Future<void> _toggleLocker() async {
    if (_isLockerOpen) {
      await _showCloseConfirmDialog();
    } else {
      await _showOpenConfirmDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('사물함 ${widget.lockerId}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isLockerOpen ? Icons.lock_open : Icons.lock,
                        size: 48,
                        color: _isLockerOpen
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isLockerOpen ? '열림' : '닫힘',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _isLockerOpen
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'PIN 번호',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Text(
                      widget.pinCode,
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '사물함 번호',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        widget.lockerId,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '교재명',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        widget.bookTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '거래 번호',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        widget.transactionId,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '이용 안내',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.warning),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• 사물함은 24시간 동안 이용 가능합니다\n'
                    '• 시간 초과 시 자동으로 사물함이 회수됩니다\n'
                    '• PIN 번호는 타인과 공유하지 마세요\n'
                    '• 문제 발생 시 고객센터로 문의해주세요',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _toggleLocker,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_isLockerOpen ? Icons.lock : Icons.lock_open),
                label: Text(
                  _isLoading
                      ? '제어 중...'
                      : _isLockerOpen
                      ? '사물함 닫기'
                      : '사물함 열기',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLockerOpen
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  context.go(AppRoutes.transactions);
                },
                child: const Text('거래 화면으로 돌아가기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
