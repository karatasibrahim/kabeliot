import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../domain/device_models.dart';
import '../providers/sensor_config_provider.dart';
import '../providers/live_data_provider.dart';
import 'sensor_config_sheet.dart';
import 'sensor_chart_sheet.dart';

class DeviceDetailScreen extends ConsumerWidget {
  const DeviceDetailScreen({super.key, required this.device});
  final DeviceModel device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = device.isOnline ? AppColors.success : AppColors.error;

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(device.name, style: AppTextStyles.headingSmall),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 20.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 6.r, height: 6.r, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                SizedBox(width: 5.w),
                Text(device.isOnline ? 'Çevrimiçi' : 'Çevrimdışı',
                    style: AppTextStyles.labelSmall.copyWith(color: statusColor)),
              ],
            ),
          ),
        ],
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          children: [
            // Cihaz bilgi kartı
            _DeviceInfoCard(device: device).animate().fadeIn(duration: 300.ms),
            SizedBox(height: 24.h),

            // Sensörler
            if (device.sensorCount > 0) ...[
              _SectionHeader(
                title: 'Sensörler',
                icon: Icons.sensors_rounded,
                color: AppColors.accent,
                count: device.sensorCount,
              ),
              SizedBox(height: 12.h),
              _SensorGrid(device: device),
              SizedBox(height: 24.h),
            ],

            // Röleler
            if (device.relayCount > 0) ...[
              _SectionHeader(
                title: 'Röleler',
                icon: Icons.toggle_on_rounded,
                color: AppColors.warning,
                count: device.relayCount,
              ),
              SizedBox(height: 12.h),
              _RelayList(device: device),
              SizedBox(height: 24.h),
            ],

            if (device.sensorCount == 0 && device.relayCount == 0)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40.r),
                  child: Column(
                    children: [
                      Icon(Icons.cable_rounded, color: AppColors.textDisabled, size: 56.r),
                      SizedBox(height: 12.h),
                      Text('Bu cihazda I/O yok', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeviceInfoCard extends StatelessWidget {
  const _DeviceInfoCard({required this.device});
  final DeviceModel device;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Cihaz ID', value: device.id, mono: true),
          _InfoRow(label: 'Tür', value: device.type),
          _InfoRow(label: 'IP Adresi', value: device.ipAddress, mono: true),
          _InfoRow(label: 'Firmware', value: device.firmware, mono: true),
          _InfoRow(label: 'MQTT Topic', value: device.mqttTopic, mono: true, isLast: true),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.mono = false, this.isLast = false});
  final String label;
  final String value;
  final bool mono;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const Spacer(),
              Text(value,
                  style: mono
                      ? AppTextStyles.mono.copyWith(fontSize: 12.sp)
                      : AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        )),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon, required this.color, required this.count});
  final String title;
  final IconData icon;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32.r, height: 32.r,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8.r)),
          child: Icon(icon, color: color, size: 16.r),
        ),
        SizedBox(width: 10.w),
        Text(title, style: AppTextStyles.headingSmall),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10.r)),
          child: Text('$count', style: AppTextStyles.labelSmall.copyWith(color: color)),
        ),
      ],
    );
  }
}

// ─── Sensör Grid ─────────────────────────────────────────────────────────────

class _SensorGrid extends ConsumerWidget {
  const _SensorGrid({required this.device});
  final DeviceModel device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(sensorConfigsProvider(device.id, device.sensorCount));

    return configAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Hata: $e'),
      data: (configs) => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: device.sensorCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemBuilder: (context, i) => _SensorCard(
          device: device,
          index: i,
          config: configs[i],
        ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: i * 60)),
      ),
    );
  }
}

class _SensorCard extends ConsumerWidget {
  const _SensorCard({required this.device, required this.index, required this.config});
  final DeviceModel device;
  final int index;
  final SensorConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveData = ref.watch(liveSensorDataProvider(device.id, index));
    final currentVal = liveData.isEmpty ? 0.0 : liveData.last;
    final color = config.type.color;

    final isAboveMax = config.thresholdMax != null && currentVal > config.thresholdMax!;
    final isBelowMin = config.thresholdMin != null && currentVal < config.thresholdMin!;
    final isAlert = isAboveMax || isBelowMin;
    final cardColor = isAlert ? AppColors.error : color;

    return GestureDetector(
      onTap: () => showSensorChartSheet(context, device: device, index: index, config: config),
      onLongPress: () => showSensorConfigSheet(context, ref: ref, device: device, index: index, config: config),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: isAlert ? AppColors.error.withValues(alpha: 0.6) : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(config.type.icon, color: cardColor, size: 16.r),
                const Spacer(),
                GestureDetector(
                  onTap: () => showSensorConfigSheet(context, ref: ref, device: device, index: index, config: config),
                  child: Icon(Icons.edit_rounded, color: AppColors.textDisabled, size: 14.r),
                ),
              ],
            ),
            const Spacer(),
            // Mini sparkline — son 10 nokta
            SizedBox(
              height: 18.h,
              child: _MiniSparkline(data: liveData.length > 10 ? liveData.sublist(liveData.length - 10) : liveData, color: cardColor),
            ),
            SizedBox(height: 4.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(config.name, style: AppTextStyles.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Text(
                  '${currentVal.toStringAsFixed(1)} ${config.unit}',
                  style: AppTextStyles.mono.copyWith(color: cardColor, fontSize: 11.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSparkline extends StatelessWidget {
  const _MiniSparkline({required this.data, required this.color});
  final List<double> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) return const SizedBox();
    return CustomPaint(
      painter: _SparklinePainter(data: data, color: color),
      child: const SizedBox.expand(),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.data, required this.color});
  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = (max - min).abs();
    final safeRange = range < 0.001 ? 1.0 : range;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - ((data[i] - min) / safeRange) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.data != data;
}

// ─── Röle Listesi ─────────────────────────────────────────────────────────────

class _RelayList extends ConsumerWidget {
  const _RelayList({required this.device});
  final DeviceModel device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relays = ref.watch(relayStatesProvider(device.id, device.relayCount));

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(device.relayCount, (i) {
          final relay = relays[i];
          final isLast = i == device.relayCount - 1;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 36.r, height: 36.r,
                      decoration: BoxDecoration(
                        color: relay.isOn
                            ? AppColors.warning.withValues(alpha: 0.15)
                            : AppColors.border.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                      child: Icon(
                        relay.isOn ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                        color: relay.isOn ? AppColors.warning : AppColors.textDisabled,
                        size: 22.r,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(relay.name, style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          )),
                          Text('Kanal ${i + 1}', style: AppTextStyles.labelSmall),
                        ],
                      ),
                    ),
                    Switch(
                      value: relay.isOn,
                      onChanged: (_) => ref.read(relayStatesProvider(device.id, device.relayCount).notifier).toggle(i),
                      activeTrackColor: AppColors.warning,
                      activeThumbColor: Colors.white,
                      inactiveThumbColor: AppColors.textDisabled,
                      inactiveTrackColor: AppColors.border,
                    ),
                  ],
                ),
              ),
              if (!isLast) Divider(height: 1, color: AppColors.divider, indent: 16.w),
            ],
          );
        }).animate(interval: 50.ms).fadeIn(duration: 250.ms),
      ),
    );
  }
}
