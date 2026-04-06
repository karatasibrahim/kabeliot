import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../../../shared/widgets/gradient_scaffold.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text('Profilim', style: AppTextStyles.headingMedium),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          children: [
            _buildUserCard().animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
            SizedBox(height: 24.h),
            _buildSection('Hesap', [
              _MenuItem(icon: Icons.person_outline_rounded, color: AppColors.primary, label: 'Hesap Bilgileri', onTap: () {}),
              _MenuItem(icon: Icons.security_rounded, color: AppColors.accent, label: 'Güvenlik & Şifre', onTap: () {}),
            ]).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            SizedBox(height: 16.h),
            _buildSection('Cihaz Yönetimi', [
              _MenuItem(icon: Icons.cloud_outlined, color: AppColors.success, label: 'MQTT Sunucu Ayarları', trailing: _buildTag('mqtt.kabel.io'), onTap: () => context.push(AppRoutes.settings)),
              _MenuItem(icon: Icons.wifi_rounded, color: AppColors.accent, label: 'WiFi Provisioning', onTap: () => context.push(AppRoutes.addDevice)),
              _MenuItem(icon: Icons.developer_board_outlined, color: AppColors.warning, label: 'Cihazlarım', trailing: _buildBadge('12'), onTap: () => context.go(AppRoutes.devices)),
            ]).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            SizedBox(height: 16.h),
            _buildSection('Tercihler', [
              _MenuItem(icon: Icons.notifications_outlined, color: AppColors.warning, label: 'Bildirim Ayarları', onTap: () => context.push(AppRoutes.settings)),
              _MenuItem(icon: Icons.settings_outlined, color: AppColors.textSecondary, label: 'Uygulama Ayarları', onTap: () => context.push(AppRoutes.settings)),
              _MenuItem(icon: Icons.info_outline_rounded, color: AppColors.info, label: 'Hakkında', trailing: Text('v1.0.0', style: AppTextStyles.labelSmall), onTap: () {}),
            ]).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            SizedBox(height: 16.h),
            _buildLogoutButton(context, ref).animate().fadeIn(duration: 400.ms, delay: 400.ms),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.accent.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
            ),
            child: Center(
              child: Text('İK', style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('İbrahim Karataş', style: AppTextStyles.headingSmall),
                SizedBox(height: 2.h),
                Text('ibrahimkaratas@kabel.com', style: AppTextStyles.bodySmall),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Text('Yönetici', style: AppTextStyles.labelSmall.copyWith(color: AppColors.success)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: AppColors.primary, size: 20.r),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
          child: Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled, letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  _MenuItemTile(item: e.value),
                  if (!isLast) Divider(height: 1, color: AppColors.divider, indent: 52.w),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceElevated,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            title: Text('Çıkış Yap', style: AppTextStyles.headingSmall),
            content: Text('Oturumunuzu kapatmak istiyor musunuz?', style: AppTextStyles.bodyMedium),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(authStateProvider.notifier).logout();
                },
                child: Text('Çıkış Yap', style: AppTextStyles.labelLarge.copyWith(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 20.r),
            SizedBox(width: 8.w),
            Text('Çıkış Yap', style: AppTextStyles.labelLarge.copyWith(color: AppColors.error)),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) => Text(text, style: AppTextStyles.monoSmall);
  Widget _buildBadge(String text) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8.r)),
    child: Text(text, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
  );
}

class _MenuItem {
  const _MenuItem({required this.icon, required this.color, required this.label, required this.onTap, this.trailing});
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({required this.item});
  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: Icon(item.icon, color: item.color, size: 18.r),
            ),
            SizedBox(width: 14.w),
            Expanded(child: Text(item.label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary))),
            if (item.trailing != null) ...[item.trailing!, SizedBox(width: 8.w)],
            Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled, size: 18.r),
          ],
        ),
      ),
    );
  }
}
