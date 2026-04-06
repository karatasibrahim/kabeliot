import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/device_card_shell.dart';
import '../../../shared/widgets/gradient_scaffold.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  String _filter = 'Tümü';
  String _search = '';

  static const _filters = ['Tümü', 'Çevrimiçi', 'Çevrimdışı', 'Sensör', 'Röle'];

  static const _allDevices = [
    _DeviceItem(name: 'PCB-Kontrol-001', type: 'Kontrol Kartı', category: 'Kontrol', id: 'KB-001-A2F3', isOnline: true, sensors: 3, relays: 2),
    _DeviceItem(name: 'Sensör-Node-02', type: 'Sensör Kartı', category: 'Sensör', id: 'KB-002-B1E9', isOnline: true, sensors: 5, relays: 0),
    _DeviceItem(name: 'Gateway-Ana', type: 'Gateway', category: 'Gateway', id: 'KB-003-C7D1', isOnline: false, sensors: 0, relays: 0),
    _DeviceItem(name: 'PCB-Motor-04', type: 'Motor Sürücü', category: 'Röle', id: 'KB-004-D4F8', isOnline: true, sensors: 1, relays: 4),
    _DeviceItem(name: 'Sensör-Node-05', type: 'Sensör Kartı', category: 'Sensör', id: 'KB-005-E2A1', isOnline: false, sensors: 4, relays: 0),
    _DeviceItem(name: 'Röle-Kontrol-06', type: 'Röle Modülü', category: 'Röle', id: 'KB-006-F9B3', isOnline: true, sensors: 0, relays: 8),
  ];

  List<_DeviceItem> get _filteredDevices {
    return _allDevices.where((d) {
      final matchSearch = _search.isEmpty || d.name.toLowerCase().contains(_search.toLowerCase()) || d.id.toLowerCase().contains(_search.toLowerCase());
      final matchFilter = switch (_filter) {
        'Çevrimiçi' => d.isOnline,
        'Çevrimdışı' => !d.isOnline,
        'Sensör' => d.category == 'Sensör',
        'Röle' => d.category == 'Röle',
        _ => true,
      };
      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final devices = _filteredDevices;

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text('Cihazlarım', style: AppTextStyles.headingMedium),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: AppColors.primary, size: 26.r),
            onPressed: () => context.push(AppRoutes.addDevice),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addDevice),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Cihaz Ekle'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Arama
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cihaz adı veya ID ara...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20.r),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 18.r),
                          onPressed: () => setState(() => _search = ''),
                        )
                      : null,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),

            SizedBox(height: 12.h),

            // Filtre chipler
            SizedBox(
              height: 36.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, i) {
                  final selected = _filter == _filters[i];
                  return GestureDetector(
                    onTap: () => setState(() => _filter = _filters[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(
                        _filters[i],
                        style: AppTextStyles.labelSmall.copyWith(
                          color: selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

            SizedBox(height: 16.h),

            // Cihaz sayısı
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Text('${devices.length} cihaz', style: AppTextStyles.bodySmall),
                  const Spacer(),
                  Text('${devices.where((d) => d.isOnline).length} çevrimiçi', style: AppTextStyles.bodySmall.copyWith(color: AppColors.success)),
                ],
              ),
            ),
            SizedBox(height: 8.h),

            // Liste
            Expanded(
              child: devices.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                      itemCount: devices.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (context, i) => _DeviceCard(device: devices[i])
                          .animate()
                          .fadeIn(duration: 300.ms, delay: Duration(milliseconds: i * 50))
                          .slideY(begin: 0.05, end: 0, duration: 300.ms, delay: Duration(milliseconds: i * 50)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.developer_board_outlined, color: AppColors.textDisabled, size: 64.r),
          SizedBox(height: 16.h),
          Text('Cihaz bulunamadı', style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary)),
          SizedBox(height: 8.h),
          Text('Arama veya filtreyi değiştirin', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _DeviceItem {
  const _DeviceItem({
    required this.name,
    required this.type,
    required this.category,
    required this.id,
    required this.isOnline,
    required this.sensors,
    required this.relays,
  });
  final String name;
  final String type;
  final String category;
  final String id;
  final bool isOnline;
  final int sensors;
  final int relays;
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device});
  final _DeviceItem device;

  @override
  Widget build(BuildContext context) {
    final statusColor = device.isOnline ? AppColors.success : AppColors.error;

    return DeviceCardShell(
      accentColor: statusColor,
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          Row(
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      device.isOnline ? 'Online' : 'Offline',
                      style: AppTextStyles.labelSmall.copyWith(color: statusColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (device.sensors > 0 || device.relays > 0) ...[
            SizedBox(height: 12.h),
            Divider(height: 1, color: AppColors.divider),
            SizedBox(height: 10.h),
            Row(
              children: [
                if (device.sensors > 0) ...[
                  Icon(Icons.sensors_rounded, color: AppColors.accent, size: 14.r),
                  SizedBox(width: 4.w),
                  Text('${device.sensors} Sensör', style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent)),
                  SizedBox(width: 16.w),
                ],
                if (device.relays > 0) ...[
                  Icon(Icons.toggle_on_rounded, color: AppColors.warning, size: 14.r),
                  SizedBox(width: 4.w),
                  Text('${device.relays} Röle', style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning)),
                ],
                const Spacer(),
                Text('MQTT: kb/${device.id.toLowerCase()}/#', style: AppTextStyles.monoSmall),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
