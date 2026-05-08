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
import '../providers/automation_provider.dart';
import 'automation_list_screen.dart';

class DeviceDetailScreen extends ConsumerWidget {
  const DeviceDetailScreen({super.key, required this.device});
  final DeviceModel device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = device.isOnline ? AppColors.success : AppColors.error;
    final relays = ref.watch(relayStatesProvider(device.tbDeviceId ?? device.id, kMaxRelays));
    final activeRelayCount = relays.where((r) => r.isEnabled).length;

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
            _DeviceInfoCard(device: device).animate().fadeIn(duration: 300.ms),
            SizedBox(height: 24.h),

            // Sensörler — her zaman 6 slot, aktif sayısı TB datasından
            _SensorSection(device: device),
            SizedBox(height: 24.h),

            // Röleler — her zaman 8 slot, aktif sayısı provider'dan
            _SectionHeader(
              title: 'Röleler',
              icon: Icons.toggle_on_rounded,
              color: AppColors.warning,
              active: activeRelayCount,
              max: kMaxRelays,
            ),
            SizedBox(height: 12.h),
            _RelayList(device: device),
            SizedBox(height: 24.h),

            // Otomasyonlar
            _AutomationSection(device: device),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

// ─── Cihaz Bilgi Kartı ───────────────────────────────────────────────────────

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
          _InfoRow(label: 'Cihaz ID', value: device.tbDeviceId ?? device.id, mono: true),
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
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: mono
                      ? AppTextStyles.mono.copyWith(fontSize: 12.sp)
                      : AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

// ─── Bölüm Başlığı ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    required this.active,
    required this.max,
  });
  final String title;
  final IconData icon;
  final Color color;
  final int active;
  final int max;

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
        // aktif / max
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10.r)),
          child: Text('$active / $max', style: AppTextStyles.labelSmall.copyWith(color: color)),
        ),
      ],
    );
  }
}

// ─── Sensör Grid (6 slot) ────────────────────────────────────────────────────

/// Sensör bölümü — header + 6 slot grid.
/// Aktif sayısı TB'den gelen veriye göre hesaplanır.
class _SensorSection extends ConsumerWidget {
  const _SensorSection({required this.device});
  final DeviceModel device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceId = device.tbDeviceId ?? device.id;
    final configAsync = ref.watch(sensorConfigsProvider(deviceId, kMaxSensors));

    // Her slot için live data izle — data gelen slotları say
    final activeSensorCount = List.generate(kMaxSensors, (i) {
      final liveData = ref.watch(liveSensorDataProvider(deviceId, i));
      final isBaseActive = i < device.sensorCount;
      return isBaseActive || liveData.isNotEmpty;
    }).where((v) => v).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Sensörler',
          icon: Icons.sensors_rounded,
          color: AppColors.accent,
          active: activeSensorCount,
          max: kMaxSensors,
        ),
        SizedBox(height: 12.h),
        configAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Hata: $e'),
          data: (configs) => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kMaxSensors,
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
              isActive: i < device.sensorCount,
            ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: i * 55)),
          ),
        ),
      ],
    );
  }
}

class _SensorCard extends ConsumerWidget {
  const _SensorCard({
    required this.device,
    required this.index,
    required this.config,
    required this.isActive,
  });
  final DeviceModel device;
  final int index;
  final SensorConfig config;
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Her zaman subscribe et — veri gelip gelmediğini TB'den öğreneceğiz
    final liveData = ref.watch(liveSensorDataProvider(device.tbDeviceId ?? device.id, index));
    final hasData = liveData.isNotEmpty;
    final currentVal = hasData ? liveData.last : 0.0;
    // TB'den veri geliyor  →  aktif göster;  gelmiyor  →  pasif slot
    final effectiveActive = isActive || hasData;
    final color = effectiveActive ? config.type.color : AppColors.textDisabled;

    final isAboveMax = effectiveActive && config.thresholdMax != null && currentVal > config.thresholdMax!;
    final isBelowMin = effectiveActive && config.thresholdMin != null && currentVal < config.thresholdMin!;
    final isAlert = isAboveMax || isBelowMin;
    final cardColor = isAlert ? AppColors.error : color;

    return GestureDetector(
      onTap: effectiveActive
          ? () => showSensorChartSheet(context, device: device, index: index, config: config)
          : () => showSensorConfigSheet(context, ref: ref, device: device, index: index, config: config),
      onLongPress: () => showSensorConfigSheet(context, ref: ref, device: device, index: index, config: config),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: effectiveActive
                ? (isAlert ? AppColors.error.withValues(alpha: 0.6) : AppColors.border)
                : AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        child: effectiveActive ? _ActiveSensorContent(
          config: config,
          liveData: liveData,
          currentVal: currentVal,
          cardColor: cardColor,
          onEdit: () => showSensorConfigSheet(context, ref: ref, device: device, index: index, config: config),
        ) : _InactiveSensorContent(
          index: index,
          onConfigure: () => showSensorConfigSheet(context, ref: ref, device: device, index: index, config: config),
        ),
      ),
    );
  }
}

class _ActiveSensorContent extends StatelessWidget {
  const _ActiveSensorContent({
    required this.config,
    required this.liveData,
    required this.currentVal,
    required this.cardColor,
    required this.onEdit,
  });
  final SensorConfig config;
  final List<double> liveData;
  final double currentVal;
  final Color cardColor;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(config.type.icon, color: cardColor, size: 16.r),
            const Spacer(),
            GestureDetector(
              onTap: onEdit,
              child: Icon(Icons.edit_rounded, color: AppColors.textDisabled, size: 14.r),
            ),
          ],
        ),
        const Spacer(),
        SizedBox(
          height: 18.h,
          child: _MiniSparkline(
            data: liveData.length > 10 ? liveData.sublist(liveData.length - 10) : liveData,
            color: cardColor,
          ),
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
    );
  }
}

class _InactiveSensorContent extends StatelessWidget {
  const _InactiveSensorContent({required this.index, required this.onConfigure});
  final int index;
  final VoidCallback onConfigure;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_circle_outline_rounded, color: AppColors.textDisabled, size: 22.r),
        SizedBox(height: 6.h),
        Text(
          'Kanal ${index + 1}',
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled),
          textAlign: TextAlign.center,
        ),
        Text(
          'Yapılandır',
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontSize: 10.sp),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Sparkline ───────────────────────────────────────────────────────────────

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

// ─── Röle Listesi (8 slot) ───────────────────────────────────────────────────

class _RelayList extends ConsumerWidget {
  const _RelayList({required this.device});
  final DeviceModel device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relays = ref.watch(relayStatesProvider(device.tbDeviceId ?? device.id, kMaxRelays));
    final notifier = ref.read(relayStatesProvider(device.tbDeviceId ?? device.id, kMaxRelays).notifier);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(kMaxRelays, (i) {
          final relay = relays[i];
          final isLast = i == kMaxRelays - 1;

          return Column(
            children: [
              _RelayRow(
                index: i,
                relay: relay,
                onToggle: () async {
                  final err = await notifier.toggle(i);
                  if (err != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(err),
                        backgroundColor: AppColors.error,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                onEnable: () => notifier.setEnabled(i, true),
                onDisable: () => notifier.setEnabled(i, false),
                onRename: (name) => notifier.rename(i, name),
              ).animate(delay: Duration(milliseconds: i * 40)).fadeIn(duration: 220.ms),
              if (!isLast) Divider(height: 1, color: AppColors.divider, indent: 16.w),
            ],
          );
        }),
      ),
    );
  }
}

class _RelayRow extends StatelessWidget {
  const _RelayRow({
    required this.index,
    required this.relay,
    required this.onToggle,
    required this.onEnable,
    required this.onDisable,
    required this.onRename,
  });
  final int index;
  final RelayConfig relay;
  final VoidCallback onToggle;
  final VoidCallback onEnable;
  final VoidCallback onDisable;
  final ValueChanged<String> onRename;

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: relay.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Röle ${index + 1} Adı', style: AppTextStyles.headingSmall),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'örn: Su Pompası, Fan, Işık...',
            hintStyle: AppTextStyles.bodySmall,
          ),
          onSubmitted: (v) {
            onRename(v);
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('İptal', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              onRename(controller.text);
              Navigator.of(ctx).pop();
            },
            child: Text('Kaydet', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = relay.isEnabled;
    final iconColor = isEnabled && relay.isOn ? AppColors.warning : AppColors.textDisabled;

    return GestureDetector(
      onLongPress: isEnabled ? () => _showRenameDialog(context) : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.55,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              // İkon
              Container(
                width: 36.r, height: 36.r,
                decoration: BoxDecoration(
                  color: isEnabled && relay.isOn
                      ? AppColors.warning.withValues(alpha: 0.15)
                      : AppColors.border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(
                  relay.isOn ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                  color: iconColor,
                  size: 22.r,
                ),
              ),
              SizedBox(width: 14.w),

              // İsim + kanal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            relay.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isEnabled
                                  ? Theme.of(context).colorScheme.onSurface
                                  : AppColors.textDisabled,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isEnabled) ...[
                          SizedBox(width: 4.w),
                          GestureDetector(
                            onTap: () => _showRenameDialog(context),
                            child: Icon(Icons.edit_rounded, size: 13.r, color: AppColors.textDisabled),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      isEnabled ? 'Kanal ${index + 1}' : 'Pasif — etkinleştirmek için dokun',
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),

              // Sağ taraf: aktifse Switch, değilse Etkinleştir butonu
              if (isEnabled) ...[
                GestureDetector(
                  onLongPress: () => _confirmDisable(context),
                  child: Switch(
                    value: relay.isOn,
                    onChanged: (_) => onToggle(),
                    activeTrackColor: AppColors.warning,
                    activeThumbColor: Colors.white,
                    inactiveThumbColor: AppColors.textDisabled,
                    inactiveTrackColor: AppColors.border,
                  ),
                ),
              ] else
                GestureDetector(
                  onTap: onEnable,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'Ekle',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDisable(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Kanalı Pasife Al', style: AppTextStyles.headingSmall),
        content: Text(
          '"${relay.name}" kanalını pasife almak istiyor musunuz?',
          style: AppTextStyles.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('İptal', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              onDisable();
              Navigator.of(ctx).pop();
            },
            child: Text('Pasife Al', style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Otomasyon Bölümü ────────────────────────────────────────────────────────

class _AutomationSection extends ConsumerWidget {
  const _AutomationSection({required this.device});
  final DeviceModel device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceId = device.tbDeviceId ?? device.id;
    final rules = ref.watch(automationRulesProvider(deviceId));
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AutomationListScreen(
          deviceId: deviceId,
          deviceName: device.name,
        ),
      )),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40.r, height: 40.r,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 20.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Otomasyonlar', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                  SizedBox(height: 2.h),
                  Text(
                    rules.isEmpty
                        ? 'Henüz kural yok'
                        : '${rules.length} kural tanımlı',
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ),
            ),
            if (rules.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '${rules.length}',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent),
                ),
              ),
              SizedBox(width: 8.w),
            ],
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Text('Yönet', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
