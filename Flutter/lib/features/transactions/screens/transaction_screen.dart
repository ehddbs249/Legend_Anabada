import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            .where((t) => t.transStatus == 'active' ||
                         t.transStatus == 'pending')
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

  const _TransactionCard({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = transaction.transStatus == 'active' ||
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
                    // Transaction 모델에 bookImageUrl 필드 없음 (TODO: Book API 조인 필요)
                    child: _buildBookIcon(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '교재 ID: ${transaction.bookId}', // bookTitle 필드 없음
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
                        '포인트 미정', // pointsTransferred 필드 없음
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
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
    // Transaction 모델에 lenderName, borrowerName 필드 없음
    // userId와 borrowerId만 있음
    if (transaction.borrowerId != null) {
      return '차용자 ID: ${transaction.borrowerId}';
    }
    return '대여자 ID: ${transaction.userId}';
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
                        value: _formatDateTime(transaction.transDate),
                      ),
                      _DetailRow(
                        label: '거래 상태',
                        value: transaction.transStatusDisplayName,
                      ),
                      _DetailRow(
                        label: '책 ID',
                        value: transaction.bookId, // bookTitle 필드 없음
                      ),
                      _DetailRow(
                        label: '대여자 ID',
                        value: transaction.userId,
                      ),
                      if (transaction.borrowerId != null)
                        _DetailRow(
                          label: '차용자 ID',
                          value: transaction.borrowerId!,
                        ),
                      // pointsTransferred, lockerId, notes 필드 없음
                      const SizedBox(height: 20),
                      if (transaction.transStatus == 'active' ||
                          transaction.transStatus == 'pending') ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: null, // lockerId 없음
                            child: const Text('사물함 접근 (미지원)'),
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