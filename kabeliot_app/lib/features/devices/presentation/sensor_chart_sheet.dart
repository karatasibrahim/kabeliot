import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/device_models.dart';
import '../providers/live_data_provider.dart';

Future<void> showSensorChartSheet(
  BuildContext context, {
  required DeviceModel device,
  required int index,
  required SensorConfig config,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SensorChartSheet(device: device, index: index, config: config),
  );
}

class _SensorChartSheet extends ConsumerWidget {
  const _SensorChartSheet({required this.device, required this.index, required this.config});
  final DeviceModel device;
  final int index;
  final SensorConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(liveSensorDataProvider(device.id, index));
    final cs = Theme.of(context).colorScheme;
    final color = config.type.color;
    final currentVal = data.isEmpty ? 0.0 : data.last;

    final isAboveMax = config.thresholdMax != null && currentVal > config.thresholdMax!;
    final isBelowMin = config.thresholdMin != null && currentVal < config.thresholdMin!;
    final isAlert = isAboveMax || isBelowMin;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    width: 36.r, height: 36.r,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                    child: Icon(config.type.icon, color: color, size: 18.r),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(config.name, style: AppTextStyles.headingSmall),
                        Text('Sensör ${index + 1} — ${device.name}', style: AppTextStyles.labelSmall),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${currentVal.toStringAsFixed(2)} ${config.unit}',
                        style: AppTextStyles.mono.copyWith(
                          color: isAlert ? AppColors.error : color,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (isAlert)
                        Text('EŞIK AŞILDI', style: AppTextStyles.labelSmall.copyWith(color: AppColors.error)),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.divider),

            // İstatistikler
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: _StatsRow(data: data, config: config, color: color),
            ),

            // Grafik
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.w, 8.h, 20.w, 16.h),
                child: _LiveChart(data: data, config: config, color: color),
              ),
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data, required this.config, required this.color});
  final List<double> data;
  final SensorConfig config;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final avg = data.reduce((a, b) => a + b) / data.length;

    return Row(
      children: [
        _StatChip(label: 'Min', value: '${minVal.toStringAsFixed(1)} ${config.unit}', color: AppColors.info),
        SizedBox(width: 8.w),
        _StatChip(label: 'Ort', value: '${avg.toStringAsFixed(1)} ${config.unit}', color: color),
        SizedBox(width: 8.w),
        _StatChip(label: 'Max', value: '${maxVal.toStringAsFixed(1)} ${config.unit}', color: AppColors.warning),
        if (config.thresholdMin != null || config.thresholdMax != null) ...[
          SizedBox(width: 8.w),
          _StatChip(
            label: 'Eşik',
            value: '${config.thresholdMin ?? "—"} / ${config.thresholdMax ?? "—"}',
            color: AppColors.error,
          ),
        ],
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: color, fontSize: 9.sp)),
            SizedBox(height: 2.h),
            Text(value, style: AppTextStyles.mono.copyWith(color: color, fontSize: 10.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _LiveChart extends StatelessWidget {
  const _LiveChart({required this.data, required this.config, required this.color});
  final List<double> data;
  final SensorConfig config;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) return const Center(child: CircularProgressIndicator());

    final minY = data.reduce((a, b) => a < b ? a : b);
    final maxY = data.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY).abs() * 0.15 + 0.5;
    final chartMin = minY - padding;
    final chartMax = maxY + padding;

    final spots = data.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return LineChart(
      LineChartData(
        minY: chartMin,
        maxY: chartMax,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.border.withValues(alpha: 0.5),
            strokeWidth: 0.8,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 46.w,
              getTitlesWidget: (val, _) => Text(
                val.toStringAsFixed(1),
                style: AppTextStyles.mono.copyWith(fontSize: 9.sp, color: AppColors.textDisabled),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              getTitlesWidget: (val, _) {
                final sec = (data.length - 1 - val.toInt());
                return Text(
                  sec == 0 ? 'şimdi' : '-${sec}s',
                  style: AppTextStyles.mono.copyWith(fontSize: 9.sp, color: AppColors.textDisabled),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (config.thresholdMax != null)
              HorizontalLine(
                y: config.thresholdMax!,
                color: AppColors.error.withValues(alpha: 0.7),
                strokeWidth: 1.2,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.error, fontSize: 9.sp),
                  labelResolver: (_) => 'Max ${config.thresholdMax} ${config.unit}',
                ),
              ),
            if (config.thresholdMin != null)
              HorizontalLine(
                y: config.thresholdMin!,
                color: AppColors.warning.withValues(alpha: 0.7),
                strokeWidth: 1.2,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.bottomRight,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning, fontSize: 9.sp),
                  labelResolver: (_) => 'Min ${config.thresholdMin} ${config.unit}',
                ),
              ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Theme.of(context).colorScheme.surface,
            getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
              '${s.y.toStringAsFixed(2)} ${config.unit}',
              AppTextStyles.mono.copyWith(color: color, fontSize: 11.sp),
            )).toList(),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 150),
    );
  }
}
