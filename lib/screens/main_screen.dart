import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../app/routes/app_router.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_animations.dart';
import '../core/widgets/premium_button.dart';

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: AppAnimations.elasticOut,
      ),
    );

    _fabRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.25,
    ).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: AppAnimations.emphasized,
      ),
    );

    // FAB 애니메이션 시작
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fabAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }
  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/home':
        return 0;
      case '/search':
        return 1;
      case '/transactions':
        return 3;
      case '/profile':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _buildPremiumBottomNavBar(context, selectedIndex),
      floatingActionButton: selectedIndex == 0
          ? AnimatedBuilder(
              animation: _fabScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabScaleAnimation.value,
                  child: Transform.rotate(
                    angle: _fabRotationAnimation.value * 2 * 3.14159,
                    child: PremiumFAB(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.go(AppRoutes.register);
                      },
                      icon: const Icon(Icons.add_rounded),
                      tooltip: '교재 등록',
                    ),
                  ),
                );
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildPremiumBottomNavBar(BuildContext context, int selectedIndex) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: AppSpacing.bottomNavHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                0,
                selectedIndex,
                Icons.home_outlined,
                Icons.home_rounded,
                AppStrings.home,
                () => context.go(AppRoutes.home),
              ),
              _buildNavItem(
                context,
                1,
                selectedIndex,
                Icons.search_outlined,
                Icons.search_rounded,
                AppStrings.search,
                () => context.go(AppRoutes.search),
              ),
              _buildNavItem(
                context,
                2,
                selectedIndex,
                Icons.add_circle_outline_rounded,
                Icons.add_circle_rounded,
                AppStrings.register,
                () => context.go(AppRoutes.register),
              ),
              _buildNavItem(
                context,
                3,
                selectedIndex,
                Icons.receipt_long_outlined,
                Icons.receipt_long_rounded,
                AppStrings.transaction,
                () => context.go(AppRoutes.transactions),
              ),
              _buildNavItem(
                context,
                4,
                selectedIndex,
                Icons.person_outline_rounded,
                Icons.person_rounded,
                AppStrings.profile,
                () => context.go(AppRoutes.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    int selectedIndex,
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
    VoidCallback onTap,
  ) {
    final isSelected = index == selectedIndex;
    final color = isSelected ? AppColors.primary : AppColors.textTertiary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: AppAnimations.fast,
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                  ),
                  child: Icon(
                    isSelected ? activeIcon : inactiveIcon,
                    size: AppSpacing.iconSizeMedium,
                    color: color,
                  ),
                ),
                const SizedBox(height: 1),
                AnimatedDefaultTextStyle(
                  duration: AppAnimations.fast,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: color,
                        fontSize: 9,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        height: 1.0,
                      ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}