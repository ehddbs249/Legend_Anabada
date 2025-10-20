import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/point_provider.dart';

/// 포인트 내역 화면
/// 사용자의 포인트 획득/사용 내역을 표시합니다.
class PointHistoryScreen extends StatefulWidget {
  const PointHistoryScreen({super.key});

  @override
  State<PointHistoryScreen> createState() => _PointHistoryScreenState();
}

class _PointHistoryScreenState extends State<PointHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('yyyy.MM.dd HH:mm');
  final NumberFormat _numberFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 포인트 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final pointProvider = context.read<PointProvider>();

      if (authProvider.currentUser != null) {
        pointProvider.fetchBalance(authProvider.currentUser!.id);
        pointProvider.fetchTransactions(authProvider.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('포인트 내역'),
      ),
      body: Consumer<PointProvider>(
        builder: (context, provider, child) {
          // 로딩 중
          if (provider.isLoading && provider.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // 포인트 잔액 카드
              _buildBalanceCard(provider),

              // 탭바
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '전체'),
                  Tab(text: '획득'),
                  Tab(text: '사용'),
                ],
              ),

              // 탭 뷰
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTransactionList(provider.transactions),
                    _buildTransactionList(
                      provider.transactions
                          .where((t) => t.pointChange > 0)
                          .toList(),
                    ),
                    _buildTransactionList(
                      provider.transactions
                          .where((t) => t.pointChange < 0)
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 포인트 잔액 카드
  Widget _buildBalanceCard(PointProvider provider) {
    final balance = provider.currentBalance;
    final totalPoints = balance?.pointTotal ?? 0;
    final earnedPoints = provider.totalEarned;
    final spentPoints = provider.totalSpent;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 현재 포인트
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '보유 포인트',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_numberFormat.format(totalPoints)} P',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),

          // 획득/사용 포인트
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.arrow_upward,
                label: '획득',
                value: _numberFormat.format(earnedPoints),
                color: Colors.green.shade300,
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white24,
              ),
              _buildStatItem(
                icon: Icons.arrow_downward,
                label: '사용',
                value: _numberFormat.format(spentPoints),
                color: Colors.red.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 통계 항목
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          '$value P',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  /// 거래 내역 리스트
  Widget _buildTransactionList(List transactions) {
    if (transactions.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.history,
        title: '거래 내역이 없습니다',
        description: '교재를 등록하거나 거래하면\n포인트 내역이 여기에 표시됩니다.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final authProvider = context.read<AuthProvider>();
        final pointProvider = context.read<PointProvider>();
        if (authProvider.currentUser != null) {
          await pointProvider.fetchTransactions(authProvider.currentUser!.id);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildTransactionCard(transaction);
        },
      ),
    );
  }

  /// 거래 내역 카드
  Widget _buildTransactionCard(dynamic transaction) {
    final isPositive = transaction.pointChange > 0;
    final amount = transaction.pointChange.abs();

    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isPositive ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
              color: isPositive ? AppColors.success : AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.transTypeDisplayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dateFormat.format(transaction.transDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),

          // 금액
          Text(
            '${isPositive ? '+' : '-'}${_numberFormat.format(amount)} P',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isPositive ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
