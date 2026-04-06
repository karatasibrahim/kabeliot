import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/device_card_shell.dart';
import '../../../shared/widgets/gradient_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GradientScaffold(
      appBar: _buildAppBar(context),
      child: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async => Future.delayed(const Duration(seconds: 1)),
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            children: [
              _buildHeader(),
              SizedBox(height: 20.h),
              _buildSummaryGrid(),
              SizedBox(height: 24.h),
              _buildQuickActions(context),
              SizedBox(height: 24.h),
              _buildRecentActivity(),
              SizedBox(height: 24.h),
              _buildDevicePreview(context),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGlow,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Icon(Icons.developer_board_rounded, color: AppColors.primary, size: 18.r),
          ),
          SizedBox(width: 10.w),
          Text('Kabel IoT', style: AppTextStyles.headingSmall),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 24.r),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () => context.go(AppRoutes.notifications),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Günaydın' : hour < 18 ? 'İyi günler' : 'İyi akşamlar';
    final now = DateTime.now();
    final dateStr = '${now.day} ${_monthName(now.month)} ${now.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting, style: AppTextStyles.bodyMedium),
        Text('Kontrol Paneliniz', style: AppTextStyles.headingLarge),
        SizedBox(height: 4.h),
        Row(
          children: [
            Icon(Icons.circle, color: AppColors.success, size: 8.r),
            SizedBox(width: 6.w),
            Text('MQTT Bağlı  •  $dateStr', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled)),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0, duration: 400.ms);
  }

  Widget _buildSummaryGrid() {
    final items = [
      _SummaryItem(label: 'Toplam Cihaz', value: '12', icon: Icons.developer_board_rounded, color: AppColors.primary),
      _SummaryItem(label: 'Sensörler', value: '8', icon: Icons.sensors_rounded, color: AppColors.accent),
      _SummaryItem(label: 'Röle Çıkışı', value: '6', icon: Icons.toggle_on_rounded, color: AppColors.warning),
      _SummaryItem(label: 'Çevrimiçi', value: '9', icon: Icons.wifi_rounded, color: AppColors.success),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.45,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.asMap().entries.map((e) =>
        _SummaryCard(item: e.value)
            .animate()
            .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 100 + e.key * 60))
            .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 400.ms, delay: Duration(milliseconds: 100 + e.key * 60)),
      ).toList(),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hızlı İşlemler', style: AppTextStyles.headingSmall),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _QuickActionChip(
                icon: Icons.add_rounded,
                label: 'Cihaz Ekle',
                color: AppColors.primary,
                onTap: () => context.push(AppRoutes.addDevice),
              ),
              SizedBox(width: 10.w),
              _QuickActionChip(
                icon: Icons.refresh_rounded,
                label: 'Yenile',
                color: AppColors.accent,
                onTap: () {},
              ),
              SizedBox(width: 10.w),
              _QuickActionChip(
                icon: Icons.cloud_outlined,
                label: 'MQTT Bağlan',
                color: AppColors.success,
                onTap: () {},
              ),
              SizedBox(width: 10.w),
              _QuickActionChip(
                icon: Icons.bar_chart_rounded,
                label: 'Grafik Görünüm',
                color: AppColors.warning,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildRecentActivity() {
    final activities = [
      _ActivityItem(icon: Icons.wifi_rounded, color: AppColors.success, text: 'PCB-Kontrol-001 çevrimiçi oldu', time: '2 dk önce'),
      _ActivityItem(icon: Icons.thermostat_rounded, color: AppColors.warning, text: 'Sensör-Node-02: Sıcaklık 42°C aştı', time: '15 dk önce'),
      _ActivityItem(icon: Icons.wifi_off_rounded, color: AppColors.error, text: 'Gateway-Ana bağlantısı kesildi', time: '1 sa önce'),
      _ActivityItem(icon: Icons.toggle_on_rounded, color: AppColors.accent, text: 'Röle-01 manuel olarak açıldı', time: '2 sa önce'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Son Aktivite', style: AppTextStyles.headingSmall),
        SizedBox(height: 12.h),
        Container(
          decoration: AppDecorations.card,
          child: Column(
            children: activities.asMap().entries.map((e) {
              final isLast = e.key == activities.length - 1;
              return Column(
                children: [
                  _ActivityTile(item: e.value),
                  if (!isLast) Divider(height: 1, color: AppColors.divider, indent: 52.w),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Widget _buildDevicePreview(BuildContext context) {
    final devices = [
      _DevicePreviewItem(name: 'PCB-Kontrol-001', type: 'Kontrol Kartı', id: 'KB-001-A2F3', isOnline: true),
      _DevicePreviewItem(name: 'Sensör-Node-02', type: 'Sensör Kartı', id: 'KB-002-B1E9', isOnline: true),
      _DevicePreviewItem(name: 'Gateway-Ana', type: 'Gateway', id: 'KB-003-C7D1', isOnline: false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Cihazlarım', style: AppTextStyles.headingSmall),
            TextButton(
              onPressed: () => context.go(AppRoutes.devices),
              child: Text('Tümünü Gör →', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ...devices.asMap().entries.map((e) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _DevicePreviewCard(device: e.value)
              .animate()
              .fadeIn(duration: 350.ms, delay: Duration(milliseconds: 500 + e.key * 60))
              .slideX(begin: 0.05, end: 0, duration: 350.ms, delay: Duration(milliseconds: 500 + e.key * 60)),
        )),
      ],
    );
  }

  String _monthName(int month) {
    const months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return months[month - 1];
  }
}

// --- Veri modelleri (mock) ---
class _SummaryItem {
  const _SummaryItem({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _ActivityItem {
  const _ActivityItem({required this.icon, required this.color, required this.text, required this.time});
  final IconData icon;
  final Color color;
  final String text;
  final String time;
}

class _DevicePreviewItem {
  const _DevicePreviewItem({required this.name, required this.type, required this.id, required this.isOnline});
  final String name;
  final String type;
  final String id;
  final bool isOnline;
}

// --- Widget bileşenleri ---
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.item});
  final _SummaryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: item.color.withValues(alpha: 0.25), width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [item.color.withValues(alpha: 0.06), Colors.transparent],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(item.icon, color: item.color, size: 16.r),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textDisabled, size: 10.r),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.value, style: AppTextStyles.headingLarge.copyWith(color: item.color)),
              Text(item.label, style: AppTextStyles.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16.r),
            SizedBox(width: 6.w),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});
  final _ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 18.r),
          ),
          SizedBox(width: 12.w),
          Expanded(child: Text(item.text, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary))),
          SizedBox(width: 8.w),
          Text(item.time, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

class _DevicePreviewCard extends StatelessWidget {
  const _DevicePreviewCard({required this.device});
  final _DevicePreviewItem device;

  @override
  Widget build(BuildContext context) {
    final statusColor = device.isOnline ? AppColors.success : AppColors.error;
    return DeviceCardShell(
      accentColor: statusColor,
      padding: EdgeInsets.all(14.r),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.developer_board_rounded, color: statusColor, size: 20.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name, style: AppTextStyles.headingSmall),
                Text(device.type, style: AppTextStyles.bodySmall),
                Text(device.id, style: AppTextStyles.mono),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              device.isOnline ? 'Online' : 'Offline',
              style: AppTextStyles.labelSmall.copyWith(color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}
