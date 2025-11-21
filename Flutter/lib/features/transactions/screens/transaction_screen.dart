import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/locker_provider.dart';
import '../../../data/providers/book_provider.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/book.dart';

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
    _tabController = TabController(length: 3, vsync: this); // 등록, 진행 중, 완료

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
            Tab(text: '등록'),
            Tab(text: '진행 중'),
            Tab(text: '완료'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RegisteredBooksList(),
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
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
                value: transaction.borrowerName ?? transaction.borrowerId!,
              ),
            // 사물함 정보 표시
            if (transaction.hasLocker) ...[
              _DetailRow(label: '사물함 번호', value: '#${transaction.lockerNum}'),
            ],
            const SizedBox(height: 20),
            if (transaction.transStatus == 'active' ||
                transaction.transStatus == 'pending') ...[
              // 사물함 접근 버튼 (구매자만 표시)
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final currentUserId = authProvider.currentUser?.id ?? '';
                  final canAccess = transaction.canAccessLocker(currentUserId);

                  if (canAccess) {
                    return SizedBox(
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    );
                  } else {
                    // 판매자나 사물함 미배정 시 버튼 숨김
                    return const SizedBox.shrink();
                  }
                },
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
    );
  }

  /// 날짜 시간 포맷
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 사물함 제어 다이얼로그 (열기/닫기)
  void _showLockerAccessDialog(
    BuildContext context,
    Transaction transaction,
  ) async {
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
                const Spacer(),
                IconButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() => isLoading = true);

                            try {
                              final lockerProvider = context
                                  .read<LockerProvider>();
                              final success = isLockerOpen
                                  ? await lockerProvider.closeLockerByNumber(
                                      transaction.lockerNum!,
                                    )
                                  : await lockerProvider.openLockerByNumber(
                                      transaction.lockerNum!,
                                    );

                              if (success && dialogContext.mounted) {
                                setState(() => isLockerOpen = !isLockerOpen);

                                // 사물함이 열렸다면 거래 완료 처리
                                if (!isLockerOpen) {
                                  // 이전 상태가 닫힘이었고 지금 열린 경우
                                  final transactionProvider = context
                                      .read<TransactionProvider>();
                                  final authProvider = context
                                      .read<AuthProvider>();
                                  await transactionProvider.completeTransaction(
                                    transaction.id,
                                  );

                                  // 거래 목록 새로고침
                                  if (authProvider.currentUser != null) {
                                    final userId = authProvider.currentUser!.id;
                                    await Future.wait([
                                      transactionProvider
                                          .fetchMyLendingTransactions(userId),
                                      transactionProvider
                                          .fetchMyBorrowingTransactions(userId),
                                      transactionProvider
                                          .fetchActiveTransactions(userId),
                                    ]);
                                  }

                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          '✅ 사물함이 열렸습니다! 거래가 완료되었습니다.',
                                        ),
                                        backgroundColor: AppColors.success,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('🔒 사물함이 닫혔습니다!'),
                                      backgroundColor: AppColors.success,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
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

/// 등록된 책 목록 (거래 없음 + 사물함 미배정)
class _RegisteredBooksList extends StatelessWidget {
  const _RegisteredBooksList();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bookProvider = context.watch<BookProvider>();

    // 사용자 ID 확인
    if (authProvider.currentUser == null) {
      return const Center(child: Text('로그인이 필요합니다.'));
    }

    // 내 책 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (bookProvider.myBooks.isEmpty && !bookProvider.isLoading) {
        bookProvider.fetchMyBooks(authProvider.currentUser!.id);
      }
    });

    // 로딩 중
    if (bookProvider.isLoading && bookProvider.myBooks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // pending 상태 책만 필터링
    final pendingBooks = bookProvider.myBooks
        .where((book) => book.bookStatus == 'pending')
        .toList();

    // 등록된 책이 없을 때
    if (pendingBooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '등록 대기 중인 교재가 없습니다',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '교재를 등록하고 사물함에 배정하세요',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/register'),
              icon: const Icon(Icons.add),
              label: const Text('교재 등록하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    // 등록된 책 목록 표시
    return RefreshIndicator(
      onRefresh: () async {
        await bookProvider.fetchMyBooks(authProvider.currentUser!.id);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingBooks.length,
        itemBuilder: (context, index) {
          final book = pendingBooks[index];
          return _RegisteredBookCard(book: book);
        },
      ),
    );
  }
}

/// 등록된 책 카드
class _RegisteredBookCard extends StatelessWidget {
  final Book book;

  const _RegisteredBookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          // 사물함 배정 상태 확인
          final lockerId = await context
              .read<BookProvider>()
              .getAssignedLockerId(book.id);

          if (!context.mounted) return;

          if (lockerId == null) {
            // 사물함 미배정 → 사물함 배정 다이얼로그
            _showLockerAssignmentDialog(context, book);
          } else {
            // 사물함 배정됨 → 사물함 제어 다이얼로그
            _showLockerControlDialog(context, book, lockerId);
          }
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
                child: book.imgUrl != null
                    ? CachedNetworkImage(
                        imageUrl: book.imgUrl!,
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
                      book.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 저자
                    Text(
                      book.author,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 가격 및 상태
                    FutureBuilder<String?>(
                      future: context.read<BookProvider>().getAssignedLockerId(
                        book.id,
                      ),
                      builder: (context, snapshot) {
                        final hasLocker = snapshot.data != null;
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: hasLocker
                                    ? AppColors.info.withValues(alpha: 0.1)
                                    : AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                hasLocker ? '사물함 배정됨' : '배정 대기',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: hasLocker
                                          ? AppColors.info
                                          : AppColors.warning,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${numberFormat.format(book.pointPrice)}P',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 우측 화살표 아이콘
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  /// 사물함 배정 다이얼로그
  void _showLockerAssignmentDialog(BuildContext context, Book book) async {
    final lockerProvider = context.read<LockerProvider>();

    bool isAssigning = true;
    String? assignedLockerId;
    int? assignedLockerNum;
    String? errorMessage;

    // 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          // 초기 배정 시도 (한번만 실행)
          if (isAssigning && assignedLockerId == null && errorMessage == null) {
            Future.microtask(() async {
              try {
                // 사용 가능한 사물함 조회
                await lockerProvider.fetchAvailableLockers();
                final availableLockers = lockerProvider.availableLockers;

                if (availableLockers.isEmpty) {
                  // 사물함이 없으면 대기 상태
                  if (dialogContext.mounted) {
                    setState(() {
                      isAssigning = false;
                      errorMessage = 'no_lockers';
                    });
                  }
                  return;
                }

                // 첫 번째 사용 가능한 사물함 배정
                final locker = availableLockers.first;
                await lockerProvider.assignBookToLocker(locker.id, book.id);

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

                if (dialogContext.mounted) {
                  setState(() {
                    assignedLockerId = locker.id;
                    assignedLockerNum = locker.lockerNum;
                    isAssigning = false;
                  });
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  setState(() {
                    isAssigning = false;
                    errorMessage = e.toString();
                  });
                }
              }
            });
          }

          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  assignedLockerId != null ? Icons.lock_open : Icons.schedule,
                  color: assignedLockerId != null
                      ? AppColors.success
                      : AppColors.warning,
                ),
                const SizedBox(width: 12),
                const Text('사물함 배정'),
                const Spacer(),
                IconButton(
                  onPressed: isAssigning
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),

                // 로딩 중
                if (isAssigning)
                  const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('사물함 배정 중...'),
                    ],
                  )
                // 배정 완료
                else if (assignedLockerId != null)
                  Column(
                    children: [
                      Icon(Icons.lock_open, size: 64, color: AppColors.success),
                      const SizedBox(height: 12),
                      Text(
                        '사물함이 배정되었습니다!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '사물함 #$assignedLockerNum',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
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
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: AppColors.info,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '다음 단계',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text('1. 배정된 사물함에 책을 넣어주세요'),
                            Text('2. 아래 "사물함 제어" 버튼을 눌러주세요'),
                            Text('3. 사물함을 닫으면 판매가 시작됩니다'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _showLockerControlDialog(
                              context,
                              book,
                              assignedLockerId!,
                            );
                          },
                          icon: const Icon(Icons.lock),
                          label: const Text('사물함 제어'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  )
                // 사물함 없음 / 오류
                else
                  Column(
                    children: [
                      Icon(Icons.schedule, size: 64, color: AppColors.warning),
                      const SizedBox(height: 12),
                      Text(
                        errorMessage == 'no_lockers'
                            ? '사용 가능한 사물함이 없습니다'
                            : '사물함 배정 실패',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage == 'no_lockers'
                            ? '현재 모든 사물함이 사용 중입니다.\n사물함이 비는 대로 자동으로 배정됩니다.'
                            : errorMessage ?? '알 수 없는 오류',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
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
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: AppColors.info,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '안내',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text('• 등록하신 책은 여기서 확인하실 수 있습니다'),
                            Text('• 사물함 배정 후 자동으로 표시됩니다'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 사물함 제어 다이얼로그
  void _showLockerControlDialog(
    BuildContext context,
    Book book,
    String lockerId,
  ) async {
    // 사물함 정보 조회
    final lockerProvider = context.read<LockerProvider>();
    final locker = await lockerProvider.getLocker(lockerId);

    if (locker == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('사물함 정보를 가져올 수 없습니다'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;

    bool isLoading = true;
    bool isLockerOpen = false;

    // 현재 사물함 상태 조회
    if (locker.lockerNum != null) {
      final states = await lockerProvider.getPhysicalLockerStates();
      if (states != null) {
        isLockerOpen = states[locker.lockerNum] ?? false;
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
                const Spacer(),
                IconButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  '사물함 #${locker.lockerNum ?? "?"}',
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() => isLoading = true);

                            try {
                              final bookProvider = context.read<BookProvider>();
                              final success = isLockerOpen
                                  ? await lockerProvider.closeLocker(lockerId)
                                  : await lockerProvider.openLocker(
                                      lockerId,
                                      '',
                                    );

                              if (success && dialogContext.mounted) {
                                setState(() => isLockerOpen = !isLockerOpen);

                                // 닫는 경우 book_status를 available로 업데이트
                                if (!isLockerOpen) {
                                  await bookProvider.updateBookStatus(
                                    book.id,
                                    'available',
                                  );

                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('교재가 성공적으로 등록되었습니다!'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✅ 사물함이 열렸습니다!'),
                                      backgroundColor: AppColors.success,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
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
                          isLockerOpen
                              ? '책을 넣고 사물함을 닫으면 판매가 시작됩니다'
                              : '버튼을 눌러 사물함을 열어주세요',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
