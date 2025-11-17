import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/locker_provider.dart';
import '../../../data/models/transaction.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    ); // 3 -> 2로 변경 (취소 탭 제거)

    // 거래 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactionData();
    });
  }

  /// 거래 데이터 로드
  Future<void> _loadTransactionData() async {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final transactionProvider = context.read<TransactionProvider>();

    if (authProvider.currentUser != null) {
      final userId = authProvider.currentUser!.id;
      await Future.wait([
        transactionProvider.fetchMyLendingTransactions(userId),
        transactionProvider.fetchMyBorrowingTransactions(userId),
        transactionProvider.fetchActiveTransactions(userId),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.transactionHistory),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '진행 중'),
            Tab(text: '완료'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TransactionList(filterType: 'active'),
          _TransactionList(filterType: 'completed'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _TransactionList extends StatelessWidget {
  final String filterType;

  const _TransactionList({required this.filterType});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        if (transactionProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (transactionProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  transactionProvider.errorMessage!,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    transactionProvider.clearError();
                    // 데이터 재로드 로직
                    final authProvider = context.read<AuthProvider>();
                    if (authProvider.currentUser != null) {
                      final userId = authProvider.currentUser!.id;
                      await Future.wait([
                        transactionProvider.fetchMyLendingTransactions(userId),
                        transactionProvider.fetchMyBorrowingTransactions(
                          userId,
                        ),
                        transactionProvider.fetchActiveTransactions(userId),
                      ]);
                    }
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        List<Transaction> transactions = _getFilteredTransactions(
          transactionProvider,
        );

        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmptyMessage(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            final authProvider = context.read<AuthProvider>();
            final transactionProvider = context.read<TransactionProvider>();

            if (authProvider.currentUser != null) {
              final userId = authProvider.currentUser!.id;
              await Future.wait([
                transactionProvider.fetchMyLendingTransactions(userId),
                transactionProvider.fetchMyBorrowingTransactions(userId),
                transactionProvider.fetchActiveTransactions(userId),
              ]);
            }
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _TransactionCard(
                transaction: transaction,
                onTap: () => _showTransactionDetail(context, transaction),
              );
            },
          ),
        );
      },
    );
  }

  /// 필터에 따른 거래 목록 반환
  List<Transaction> _getFilteredTransactions(TransactionProvider provider) {
    final allTransactions = [
      ...provider.myLendingTransactions,
      ...provider.myBorrowingTransactions,
    ];

    switch (filterType) {
      case 'active':
        return allTransactions
            .where(
              (t) => t.transStatus == 'active' || t.transStatus == 'pending',
            )
            .toList();
      case 'completed':
        return allTransactions
            .where((t) => t.transStatus == 'completed')
            .toList();
      case 'cancelled':
        return allTransactions
            .where((t) => t.transStatus == 'cancelled')
            .toList();
      default:
        return allTransactions;
    }
  }

  /// 빈 상태 메시지 반환
  String _getEmptyMessage() {
    switch (filterType) {
      case 'active':
        return '진행 중인 거래가 없습니다';
      case 'completed':
        return '완료된 거래가 없습니다';
      case 'cancelled':
        return '취소된 거래가 없습니다';
      default:
        return '거래 내역이 없습니다';
    }
  }

  /// 거래 상세 다이얼로그 표시
  void _showTransactionDetail(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TransactionDetailSheet(transaction: transaction),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const _TransactionCard({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive =
        transaction.transStatus == 'active' ||
        transaction.transStatus == 'pending';
    final transactionColor = _getTransactionColor(transaction.transStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusBadge(status: transaction.transStatus),
                  Text(
                    _formatDate(transaction.transDate),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildBookImage(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.bookTitle ??
                              '교재 ID: ${transaction.bookId}',
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTransactionPartner(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _getStatusIcon(),
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getStatusDescription(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${transaction.pointPrice} P',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: transactionColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // remainingDays 필드 없음
                      if (isActive)
                        Text(
                          transaction.transStatusDisplayName,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ],
              ),
              // Transaction 모델에 lockerId 필드 없음 (TODO: Reservation/Locker API 조인 필요)
              // if (isActive && transaction.lockerId != null) ...[
              //   const SizedBox(height: 12),
              //   Container(...),
              // ],
            ],
          ),
        ),
      ),
    );
  }

  /// 책 이미지 위젯
  Widget _buildBookImage() {
    if (transaction.bookImgUrl != null && transaction.bookImgUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          transaction.bookImgUrl!,
          width: 60,
          height: 75,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.menu_book, size: 32, color: Colors.grey[400]);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
        ),
      );
    } else {
      return Icon(Icons.menu_book, size: 32, color: Colors.grey[400]);
    }
  }

  /// 거래 상대방 표시
  String _getTransactionPartner() {
    if (transaction.borrowerId != null) {
      return '구매자: ${transaction.borrowerName ?? transaction.borrowerId}';
    }
    return '판매자: ${transaction.sellerName ?? transaction.userId}';
  }

  /// 상태 아이콘
  IconData _getStatusIcon() {
    switch (transaction.transStatus) {
      case 'pending':
        return Icons.schedule;
      case 'active':
        return Icons.sync;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'overdue':
        return Icons.warning_outlined;
      default:
        return Icons.help_outline;
    }
  }

  /// 상태 설명
  String _getStatusDescription() {
    return transaction.transStatusDisplayName;
  }

  /// 날짜 포맷
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  /// 거래 상태별 색상
  Color _getTransactionColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'active':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.textSecondary;
      case 'overdue':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

/// 거래 상세 정보 시트
class _TransactionDetailSheet extends StatelessWidget {
  final Transaction transaction;

  const _TransactionDetailSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('거래 상세', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      _DetailRow(label: '거래 번호', value: transaction.id),
                      _DetailRow(
                        label: '거래 일시',
                        value: _formatDateTime(transaction.transDate),
                      ),
                      _DetailRow(
                        label: '거래 상태',
                        value: transaction.transStatusDisplayName,
                      ),
                      _DetailRow(
                        label: '책 제목',
                        value: transaction.bookTitle ?? transaction.bookId,
                      ),
                      _DetailRow(
                        label: '판매자',
                        value: transaction.sellerName ?? transaction.userId,
                      ),
                      if (transaction.borrowerId != null)
                        _DetailRow(
                          label: '구매자',
                          value:
                              transaction.borrowerName ??
                              transaction.borrowerId!,
                        ),
                      // 사물함 정보 표시
                      if (transaction.hasLocker) ...[
                        _DetailRow(
                          label: '사물함 번호',
                          value: '#${transaction.lockerNum}',
                        ),
                      ],
                      const SizedBox(height: 20),
                      if (transaction.transStatus == 'active' ||
                          transaction.transStatus == 'pending') ...[
                        // 사물함 접근 버튼
                        if (transaction.canAccessLocker)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showLockerAccessDialog(context, transaction);
                              },
                              icon: const Icon(Icons.lock_open),
                              label: const Text('사물함 접근'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: null,
                              child: const Text('사물함 미배정'),
                            ),
                          ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              _showCancelDialog(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                            ),
                            child: const Text('거래 취소'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 날짜 시간 포맷
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 사물함 제어 다이얼로그 (열기/닫기)
  void _showLockerAccessDialog(BuildContext context, Transaction transaction) async {
    bool isLoading = true;
    bool isLockerOpen = false;

    // 현재 사물함 상태 조회
    if (transaction.lockerNum != null) {
      final lockerProvider = context.read<LockerProvider>();
      final states = await lockerProvider.getPhysicalLockerStates();
      if (states != null) {
        isLockerOpen = states[transaction.lockerNum] ?? false;
      }
      isLoading = false;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  isLockerOpen ? Icons.lock_open : Icons.lock,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                const Text('사물함 제어'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '사물함 #${transaction.lockerNum ?? "?"}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Icon(
                  isLockerOpen ? Icons.lock_open : Icons.lock,
                  size: 64,
                  color: isLockerOpen ? AppColors.success : AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  isLockerOpen ? '열림' : '닫힘',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isLockerOpen ? AppColors.success : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '버튼을 눌러 사물함을 열거나 닫을 수 있습니다',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.pop(dialogContext);
                      },
                child: const Text('닫기'),
              ),
              ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);

                        try {
                          final lockerProvider = context.read<LockerProvider>();
                          final success = isLockerOpen
                              ? await lockerProvider.closeLocker(
                                  transaction.lockerId!,
                                )
                              : await lockerProvider.openLocker(
                                  transaction.lockerId!,
                                  '', // 접근 코드 불필요
                                );

                          if (success && dialogContext.mounted) {
                            setState(() => isLockerOpen = !isLockerOpen);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isLockerOpen
                                      ? '✅ 사물함이 열렸습니다!'
                                      : '🔒 사물함이 닫혔습니다!',
                                ),
                                backgroundColor: AppColors.success,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else if (dialogContext.mounted) {
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
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('❌ 오류: ${e.toString()}'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        } finally {
                          if (dialogContext.mounted) {
                            setState(() => isLoading = false);
                          }
                        }
                      },
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(isLockerOpen ? Icons.lock : Icons.lock_open),
                label: Text(
                  isLoading
                      ? '제어 중...'
                      : isLockerOpen
                      ? '사물함 닫기'
                      : '사물함 열기',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLockerOpen
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 거래 취소 확인 다이얼로그
  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('거래 취소'),
        content: const Text('정말로 이 거래를 취소하시겠습니까?\n취소된 거래는 되돌릴 수 없습니다.'),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();

                    // 거래 취소 실행
                    final transactionProvider =
                        Provider.of<TransactionProvider>(
                          context,
                          listen: false,
                        );
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );

                    final success = await transactionProvider.cancelTransaction(
                      transaction.id,
                    );

                    if (success) {
                      // 성공: 데이터 새로고침
                      if (authProvider.currentUser != null) {
                        final userId = authProvider.currentUser!.id;
                        await Future.wait([
                          transactionProvider.fetchMyLendingTransactions(
                            userId,
                          ),
                          transactionProvider.fetchMyBorrowingTransactions(
                            userId,
                          ),
                          transactionProvider.fetchActiveTransactions(userId),
                        ]);
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('거래가 취소되었습니다. 포인트가 반환되었습니다.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              transactionProvider.errorMessage ??
                                  '거래 취소 중 오류가 발생했습니다',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('거래 취소'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('아니오'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final text = _getStatusDisplayName();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getStatusDisplayName() {
    switch (status) {
      case 'pending':
        return '대기 중';
      case 'active':
        return '진행 중';
      case 'completed':
        return '완료';
      case 'cancelled':
        return '취소됨';
      case 'overdue':
        return '연체';
      default:
        return '알 수 없음';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'active':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.textSecondary;
      case 'overdue':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
