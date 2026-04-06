import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../../../shared/widgets/device_card_shell.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/kabel_logo.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GradientScaffold(
      appBar: _buildAppBar(context, ref),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_rounded),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          children: [
            // Karşılama
            Text(
              'Hoş Geldiniz,',
              style: AppTextStyles.bodyMedium,
            ),
            Text(
              'Kabel IoT Paneli',
              style: AppTextStyles.headingLarge,
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0, duration: 400.ms),
            SizedBox(height: 24.h),

            // İstatistik kartları
            Row(
              children: [
                _StatCard(label: 'Toplam Cihaz', value: '12', icon: Icons.developer_board_rounded, color: AppColors.primary),
                SizedBox(width: 12.w),
                _StatCard(label: 'Çevrimiçi', value: '9', icon: Icons.wifi_rounded, color: AppColors.success),
                SizedBox(width: 12.w),
                _StatCard(label: 'Çevrimdışı', value: '3', icon: Icons.wifi_off_rounded, color: AppColors.error),
              ],
            ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
            SizedBox(height: 28.h),

            // Cihaz listesi başlığı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cihazlarım', style: AppTextStyles.headingSmall),
                TextButton(
                  onPressed: () {},
                  child: Text('Tümünü Gör', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Cihaz listesi (shimmer mock)
            ..._mockDevices.asMap().entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _DeviceCard(device: entry.value)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 150 + entry.key * 80))
                    .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: Duration(milliseconds: 150 + entry.key * 80)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: const KabelLogo(size: LogoSize.small),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          onPressed: () => ref.read(authStateProvider.notifier).logout(),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}

// Mock veri
final _mockDevices = [
  _DeviceData(name: 'PCB-Kontrol-001', type: 'Kontrol Kartı', isOnline: true, id: 'KB-001-A2F3'),
  _DeviceData(name: 'Sensör-Node-02', type: 'Sensör Kartı', isOnline: true, id: 'KB-002-B1E9'),
  _DeviceData(name: 'Gateway-Ana', type: 'Gateway', isOnline: false, id: 'KB-003-C7D1'),
  _DeviceData(name: 'PCB-Motor-04', type: 'Motor Sürücü', isOnline: true, id: 'KB-004-D4F8'),
];

class _DeviceData {
  const _DeviceData({required this.name, required this.type, required this.isOnline, required this.id});
  final String name;
  final String type;
  final bool isOnline;
  final String id;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20.r),
            SizedBox(height: 8.h),
            Text(value, style: AppTextStyles.headingMedium.copyWith(color: color)),
            Text(label, style: AppTextStyles.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device});
  final _DeviceData device;

  @override
  Widget build(BuildContext context) {
    final statusColor = device.isOnline ? AppColors.success : AppColors.error;

    return DeviceCardShell(
      accentColor: statusColor,
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.developer_board_rounded, color: statusColor, size: 22.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name, style: AppTextStyles.headingSmall),
                SizedBox(height: 2.h),
                Text(device.type, style: AppTextStyles.bodySmall),
                SizedBox(height: 4.h),
                Text(device.id, style: AppTextStyles.mono),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.5), blurRadius: 6)],
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                device.isOnline ? 'Çevrimiçi' : 'Çevrimdışı',
                style: AppTextStyles.labelSmall.copyWith(color: statusColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
