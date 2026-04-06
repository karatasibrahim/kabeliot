import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';

/// Ana uygulama shell'i — bottom navigation barı kalıcı olarak gösterir.
/// GoRouter StatefulShellRoute ile kullanılır.
class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (route: AppRoutes.home, icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Ana Sayfa'),
    (route: AppRoutes.devices, icon: Icons.developer_board_outlined, activeIcon: Icons.developer_board_rounded, label: 'Cihazlar'),
    (route: AppRoutes.notifications, icon: Icons.notifications_outlined, activeIcon: Icons.notifications_rounded, label: 'Bildirimler'),
    (route: AppRoutes.profile, icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryGlow,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _destinations.map((d) => NavigationDestination(
          icon: Icon(d.icon, color: AppColors.textSecondary),
          selectedIcon: Icon(d.activeIcon, color: AppColors.primary),
          label: d.label,
        )).toList(),
      ),
    );
  }
}
