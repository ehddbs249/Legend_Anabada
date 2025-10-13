import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/book_provider.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../app/routes/app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await Future.wait([
        bookProvider.fetchMyBooks(authProvider.currentUser!.id),
        transactionProvider.fetchMyBorrowingTransactions(authProvider.currentUser!.id),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _ProfileHeader(),
            const SizedBox(height: 24),
            _PointsCard(),
            const SizedBox(height: 16),
            _MenuSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final initial = user.name.isNotEmpty ? user.name[0] : '?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              initial,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (user.department.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.department,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.secondary,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: user.role.isNotEmpty
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.role.isNotEmpty ? '${user.role} 인증 완료' : '미인증',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: user.role.isNotEmpty ? AppColors.success : AppColors.warning,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: UserPointBalance 테이블에서 포인트 정보 가져오기
    // 현재는 임시 데이터 표시
    const currentPoints = 0;
    const earnedPoints = 0;
    const spentPoints = 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '보유 포인트',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currentPoints.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        )} P',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _PointsStatItem(
                icon: Icons.arrow_upward,
                label: '획득 포인트',
                value: '${earnedPoints.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    )} P',
                color: Colors.green.shade300,
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white24,
              ),
              _PointsStatItem(
                icon: Icons.arrow_downward,
                label: '사용 포인트',
                value: '${spentPoints.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    )} P',
                color: Colors.red.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PointsStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _PointsStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    final myBooksCount = bookProvider.myBooks.length;
    final borrowedBooksCount = transactionProvider.myBorrowingTransactions.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '내 활동',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          PremiumCard(
            elevation: 2,
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.book_outlined,
                  title: '등록한 교재',
                  subtitle: '$myBooksCount권',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: '구매한 교재',
                  subtitle: '$borrowedBooksCount권',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.history,
                  title: '거래 내역',
                  subtitle: '최근 30일',
                  onTap: () {
                    // TODO: 거래 내역 페이지로 이동
                  },
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.favorite_outline,
                  title: '관심 교재',
                  subtitle: '0권', // TODO: 관심 교재 기능 구현
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '기타',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          PremiumCard(
            elevation: 2,
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  title: '알림 설정',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.help_outline,
                  title: '도움말',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.info_outline,
                  title: '앱 정보',
                  subtitle: '버전 1.0.0',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.logout,
                  title: '로그아웃',
                  textColor: AppColors.error,
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                // 로그아웃 실행
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.signOut();

                // 로그인 화면으로 이동
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
              child: const Text(
                '로그아웃',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? textColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? AppColors.textPrimary,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: textColor,
            ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
}
