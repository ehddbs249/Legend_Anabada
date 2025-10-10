import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/auth_provider.dart';
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
    _tabController = TabController(length: 3, vsync: this);

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
            Tab(text: '취소'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TransactionList(filterType: 'active'),
          _TransactionList(filterType: 'completed'),
          _TransactionList(filterType: 'cancelled'),
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (transactionProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
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
                        transactionProvider.fetchMyBorrowingTransactions(userId),
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

        List<Transaction> transactions = _getFilteredTransactions(transactionProvider);

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
            .where((t) => t.status == TransactionStatus.active ||
                         t.status == TransactionStatus.pending)
            .toList();
      case 'completed':
        return allTransactions
            .where((t) => t.status == TransactionStatus.completed)
            .toList();
      case 'cancelled':
        return allTransactions
            .where((t) => t.status == TransactionStatus.cancelled)
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

  const _TransactionCard({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = transaction.status == TransactionStatus.active ||
                     transaction.status == TransactionStatus.pending;
    final transactionColor = _getTransactionColor(transaction.status);

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
                  _StatusBadge(status: transaction.status),
                  Text(
                    _formatDate(transaction.createdAt),
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
                    child: transaction.bookImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              transaction.bookImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildBookIcon(),
                            ),
                          )
                        : _buildBookIcon(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.bookTitle ?? '교재명',
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
                        '${transaction.pointsTransferred} P',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: transactionColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      if (isActive && transaction.remainingDays >= 0)
                        Text(
                          '${transaction.remainingDays}일 남음',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: transaction.remainingDays <= 1
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (isActive && transaction.lockerId != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
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
                          '사물함 ${transaction.lockerId}에서 수령 가능합니다',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go('/locker/${transaction.lockerId}');
                        },
                        child: const Text('접근'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 책 아이콘 위젯
  Widget _buildBookIcon() {
    return Icon(
      Icons.menu_book,
      size: 32,
      color: Colors.grey[400],
    );
  }

  /// 거래 상대방 표시
  String _getTransactionPartner() {
    return transaction.lenderName ?? transaction.borrowerName ?? '사용자';
  }

  /// 상태 아이콘
  IconData _getStatusIcon() {
    switch (transaction.status) {
      case TransactionStatus.pending:
        return Icons.schedule;
      case TransactionStatus.active:
        return Icons.sync;
      case TransactionStatus.completed:
        return Icons.check_circle_outline;
      case TransactionStatus.cancelled:
        return Icons.cancel_outlined;
      case TransactionStatus.overdue:
        return Icons.warning_outlined;
    }
  }

  /// 상태 설명
  String _getStatusDescription() {
    switch (transaction.status) {
      case TransactionStatus.pending:
        return '승인 대기중';
      case TransactionStatus.active:
        return '거래 진행중';
      case TransactionStatus.completed:
        return '거래 완료';
      case TransactionStatus.cancelled:
        return '거래 취소';
      case TransactionStatus.overdue:
        return '연체';
    }
  }

  /// 날짜 포맷
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  /// 거래 상태별 색상
  Color _getTransactionColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return AppColors.warning;
      case TransactionStatus.active:
        return AppColors.info;
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.cancelled:
        return AppColors.textSecondary;
      case TransactionStatus.overdue:
        return AppColors.error;
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
              Text(
                '거래 상세',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      _DetailRow(label: '거래 번호', value: transaction.id),
                      _DetailRow(
                        label: '거래 일시',
                        value: _formatDateTime(transaction.createdAt),
                      ),
                      _DetailRow(
                        label: '거래 상태',
                        value: transaction.status.displayName,
                      ),
                      _DetailRow(
                        label: '교재명',
                        value: transaction.bookTitle ?? '교재명',
                      ),
                      _DetailRow(
                        label: '거래 상대',
                        value: transaction.lenderName ?? transaction.borrowerName ?? '사용자',
                      ),
                      _DetailRow(
                        label: '거래 포인트',
                        value: '${transaction.pointsTransferred} P',
                      ),
                      if (transaction.lockerId != null)
                        _DetailRow(
                          label: '사물함 번호',
                          value: transaction.lockerId.toString(),
                        ),
                      if (transaction.notes != null)
                        _DetailRow(
                          label: '참고사항',
                          value: transaction.notes!,
                        ),
                      const SizedBox(height: 20),
                      if (transaction.status == TransactionStatus.active ||
                          transaction.status == TransactionStatus.pending) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: transaction.lockerId != null
                                ? () {
                                    Navigator.pop(context);
                                    context.go('/locker/${transaction.lockerId}');
                                  }
                                : null,
                            child: const Text('사물함 접근'),
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

  /// 거래 취소 확인 다이얼로그
  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('거래 취소'),
        content: const Text('정말로 이 거래를 취소하시겠습니까?\n취소된 거래는 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('아니오'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              // TODO: 거래 취소 로직 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('거래 취소 기능은 준비 중입니다')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final text = status.displayName;

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

  Color _getStatusColor() {
    switch (status) {
      case TransactionStatus.pending:
        return AppColors.warning;
      case TransactionStatus.active:
        return AppColors.info;
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.cancelled:
        return AppColors.textSecondary;
      case TransactionStatus.overdue:
        return AppColors.error;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}