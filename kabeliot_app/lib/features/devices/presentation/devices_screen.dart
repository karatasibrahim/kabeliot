import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/device_card_shell.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../domain/device_models.dart';
import '../providers/device_list_provider.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  String _filter = 'Tümü';
  String _search = '';

  static const _filters = ['Tümü', 'Çevrimiçi', 'Çevrimdışı'];

  List<FirestoreDevice> _applyFilter(List<FirestoreDevice> all) {
    return all.where((d) {
      final name = d.deviceName ?? d.id;
      final matchSearch = _search.isEmpty ||
          name.toLowerCase().contains(_search.toLowerCase()) ||
          d.id.toLowerCase().contains(_search.toLowerCase());
      final matchFilter = switch (_filter) {
        'Çevrimiçi' => d.isOnline,
        'Çevrimdışı' => !d.isOnline,
        _ => true,
      };
      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(deviceListProvider);

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
                style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Cihaz adı veya ID ara...',
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.textSecondary, size: 20.r),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded,
                              color: AppColors.textSecondary, size: 18.r),
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                      child: Text(
                        _filters[i],
                        style: AppTextStyles.labelSmall.copyWith(
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

            SizedBox(height: 16.h),

            // İçerik
            Expanded(
              child: listAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Hata: $e',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.error)),
                ),
                data: (all) {
                  final devices = _applyFilter(all);

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            Text('${devices.length} cihaz',
                                style: AppTextStyles.bodySmall),
                            const Spacer(),
                            Text(
                                '${devices.where((d) => d.isOnline).length} çevrimiçi',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.success)),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Expanded(
                        child: devices.isEmpty
                            ? _buildEmpty()
                            : ListView.separated(
                                padding: EdgeInsets.fromLTRB(
                                    20.w, 0, 20.w, 100.h),
                                itemCount: devices.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 10.h),
                                itemBuilder: (context, i) => _DeviceCard(
                                  device: devices[i],
                                  onTap: () => context.push(
                                    AppRoutes.deviceDetail,
                                    extra: _toDeviceModel(devices[i]),
                                  ),
                                )
                                    .animate()
                                    .fadeIn(
                                        duration: 300.ms,
                                        delay: Duration(
                                            milliseconds: i * 50))
                                    .slideY(
                                        begin: 0.05,
                                        end: 0,
                                        duration: 300.ms,
                                        delay: Duration(
                                            milliseconds: i * 50)),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FirestoreDevice → DeviceModel adapter (device_detail_screen için)
  DeviceModel _toDeviceModel(FirestoreDevice d) => DeviceModel(
        id: d.id,
        name: d.deviceName ?? d.id,
        type: 'Kabel Core',
        category: 'IoT',
        isOnline: d.isOnline,
        sensorCount: kMaxSensors,
        relayCount: kMaxRelays,
        tbDeviceId: d.tbDeviceId,
      );

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.developer_board_outlined,
              color: AppColors.textDisabled, size: 64.r),
          SizedBox(height: 16.h),
          Text('Cihaz bulunamadı',
              style: AppTextStyles.headingSmall
                  .copyWith(color: AppColors.textSecondary)),
          SizedBox(height: 8.h),
          Text('Arama veya filtreyi değiştirin',
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device, required this.onTap});
  final FirestoreDevice device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOnline = device.isOnline;
    final statusColor = isOnline ? AppColors.success : AppColors.error;
    final name = device.deviceName ?? device.id;

    return GestureDetector(
      onTap: onTap,
      child: DeviceCardShell(
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
              child: Icon(Icons.developer_board_rounded,
                  color: statusColor, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.headingSmall),
                  Text('Kabel Core', style: AppTextStyles.bodySmall),
                  Text(device.id, style: AppTextStyles.mono),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
                        decoration: BoxDecoration(
                            color: statusColor, shape: BoxShape.circle),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: statusColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6.h),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: AppColors.textDisabled, size: 12.r),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
