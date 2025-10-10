import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/providers/locker_provider.dart';
import '../../../data/providers/auth_provider.dart';

class LockerScreen extends StatefulWidget {
  const LockerScreen({super.key});

  @override
  State<LockerScreen> createState() => _LockerScreenState();
}

class _LockerScreenState extends State<LockerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LockerProvider>().fetchLockers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('사물함 관리'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '내 사물함'),
              Tab(text: '사물함 현황'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MyLockerTab(),
            _LockerStatusTab(),
          ],
        ),
      ),
    );
  }
}

class _MyLockerTab extends StatelessWidget {
  const _MyLockerTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActiveLockerCard(),
          const SizedBox(height: 24),
          Text(
            '사용 내역',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (index) => _LockerHistoryCard(index: index)),
        ],
      ),
    );
  }
}

class _ActiveLockerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '현재 사용 중인 사물함',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A-3',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '사용 중',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            _InfoRow(label: '교재명', value: '자료구조와 알고리즘'),
            _InfoRow(label: '거래 상대', value: '김철수'),
            _InfoRow(label: '사용 시작', value: '2024.03.15 14:30'),
            _InfoRow(label: '만료 시간', value: '2024.03.16 14:30'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showPassword(context),
              icon: const Icon(Icons.lock_outline),
              label: const Text('PIN 번호 확인'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('사물함 비밀번호'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '1234',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '이 비밀번호는 24시간 후 자동으로 만료됩니다',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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

class _LockerHistoryCard extends StatelessWidget {
  final int index;

  const _LockerHistoryCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight.withValues(alpha:0.2),
          child: Text(
            'A-${index + 1}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                ),
          ),
        ),
        title: Text('교재명 ${index + 1}'),
        subtitle: Text('2024.03.${10 - index} ~ 2024.03.${11 - index}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '완료',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.success,
                ),
          ),
        ),
      ),
    );
  }
}

class _LockerStatusTab extends StatelessWidget {
  const _LockerStatusTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '사물함 이용 안내',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '사물함은 2x2 구조로 총 4개가 운영되고 있습니다',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '사물함 현황',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _LockerGrid(),
          const SizedBox(height: 24),
          _LegendSection(),
        ],
      ),
    );
  }
}

class _LockerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<LockerProvider, AuthProvider>(
      builder: (context, lockerProvider, authProvider, child) {
        if (lockerProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final lockers = lockerProvider.lockers;

        if (lockers.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  '사물함 정보를 불러올 수 없습니다',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        // 기본 위치로 2x2 그리드 생성 (추후 확장 가능)
        final lockerGrid = lockerProvider.getLockerGrid('메인');

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 4, // 2x2 그리드
            itemBuilder: (context, index) {
              final row = index ~/ 2;
              final col = index % 2;
              final locker = lockerGrid[row][col];

              return _LockerItem(
                locker: locker,
                onTap: locker != null && locker.isAvailable
                    ? () => _onLockerTap(context, locker)
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  void _onLockerTap(BuildContext context, locker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('사물함 ${locker.displayName}'),
        content: Text('이 사물함을 예약하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 사물함 예약 로직 구현
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${locker.displayName} 사물함 예약 기능은 준비 중입니다'),
                ),
              );
            },
            child: const Text('예약'),
          ),
        ],
      ),
    );
  }
}

class _LockerItem extends StatelessWidget {
  final dynamic locker; // Locker 모델 또는 null
  final VoidCallback? onTap;

  const _LockerItem({
    required this.locker,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (locker == null) {
      // 빈 사물함 슬롯
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.divider,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              color: AppColors.textTertiary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              '없음',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ],
        ),
      );
    }

    final color = _getStatusColor();
    final icon = _getStatusIcon();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              locker.displayName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              locker.status.displayName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (locker == null) return AppColors.textTertiary;

    switch (locker.status.toString()) {
      case 'LockerStatus.available':
        return AppColors.success;
      case 'LockerStatus.occupied':
        return AppColors.textSecondary;
      case 'LockerStatus.maintenance':
        return AppColors.warning;
      case 'LockerStatus.broken':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    if (locker == null) return Icons.lock_outline;

    switch (locker.status.toString()) {
      case 'LockerStatus.available':
        return Icons.lock_open;
      case 'LockerStatus.occupied':
        return Icons.lock;
      case 'LockerStatus.maintenance':
        return Icons.build;
      case 'LockerStatus.broken':
        return Icons.error_outline;
      default:
        return Icons.lock;
    }
  }
}

class _LegendSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '범례',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _LegendItem(
              color: AppColors.success,
              label: '이용 가능',
            ),
            const SizedBox(width: 24),
            _LegendItem(
              color: AppColors.textSecondary,
              label: '사용 중',
            ),
            const SizedBox(width: 24),
            _LegendItem(
              color: AppColors.primary,
              label: '내 사물함',
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}