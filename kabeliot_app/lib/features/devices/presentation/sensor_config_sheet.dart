import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/device_models.dart';
import '../providers/sensor_config_provider.dart';

Future<void> showSensorConfigSheet(
  BuildContext context, {
  required WidgetRef ref,
  required DeviceModel device,
  required int index,
  required SensorConfig config,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SensorConfigSheet(device: device, index: index, config: config),
  );
}

class _SensorConfigSheet extends ConsumerStatefulWidget {
  const _SensorConfigSheet({required this.device, required this.index, required this.config});
  final DeviceModel device;
  final int index;
  final SensorConfig config;

  @override
  ConsumerState<_SensorConfigSheet> createState() => _SensorConfigSheetState();
}

class _SensorConfigSheetState extends ConsumerState<_SensorConfigSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;
  late SensorType _selectedType;
  late bool _notifyOnThreshold;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.config.name);
    _unitCtrl = TextEditingController(text: widget.config.unit);
    _minCtrl = TextEditingController(
        text: widget.config.thresholdMin?.toString() ?? '');
    _maxCtrl = TextEditingController(
        text: widget.config.thresholdMax?.toString() ?? '');
    _selectedType = widget.config.type;
    _notifyOnThreshold = widget.config.notifyOnThreshold;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _unitCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = widget.config.copyWith(
      name: _nameCtrl.text.trim().isEmpty ? widget.config.name : _nameCtrl.text.trim(),
      type: _selectedType,
      unit: _unitCtrl.text.trim().isEmpty ? _selectedType.defaultUnit : _unitCtrl.text.trim(),
      thresholdMin: double.tryParse(_minCtrl.text),
      thresholdMax: double.tryParse(_maxCtrl.text),
      notifyOnThreshold: _notifyOnThreshold,
      clearMin: _minCtrl.text.trim().isEmpty,
      clearMax: _maxCtrl.text.trim().isEmpty,
    );
    await ref
        .read(sensorConfigsProvider(widget.device.id, widget.device.sensorCount).notifier)
        .updateConfig(widget.index, updated);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  Text('Sensör Yapılandır', style: AppTextStyles.headingSmall),
                  const Spacer(),
                  TextButton(onPressed: Navigator.of(context).pop, child: const Text('İptal')),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                children: [
                  // Sensör adı
                  _FieldLabel('Sensör Adı'),
                  SizedBox(height: 6.h),
                  TextField(
                    controller: _nameCtrl,
                    style: AppTextStyles.bodyMedium.copyWith(color: cs.onSurface),
                    decoration: InputDecoration(hintText: 'örn: Sıcaklık Sensörü 1'),
                  ),
                  SizedBox(height: 20.h),

                  // Tip seçici
                  _FieldLabel('Sensör Tipi'),
                  SizedBox(height: 10.h),
                  _TypeGrid(
                    selected: _selectedType,
                    onSelect: (t) => setState(() {
                      _selectedType = t;
                      if (_unitCtrl.text.isEmpty || _unitCtrl.text == widget.config.type.defaultUnit) {
                        _unitCtrl.text = t.defaultUnit;
                      }
                    }),
                  ),
                  SizedBox(height: 20.h),

                  // Birim
                  _FieldLabel('Birim'),
                  SizedBox(height: 6.h),
                  TextField(
                    controller: _unitCtrl,
                    style: AppTextStyles.bodyMedium.copyWith(color: cs.onSurface),
                    decoration: InputDecoration(hintText: 'örn: °C, hPa, V'),
                  ),
                  SizedBox(height: 20.h),

                  // Eşik değerleri
                  _FieldLabel('Eşik Değerleri (opsiyonel)'),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          style: AppTextStyles.bodyMedium.copyWith(color: cs.onSurface),
                          decoration: InputDecoration(labelText: 'Min'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: TextField(
                          controller: _maxCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          style: AppTextStyles.bodyMedium.copyWith(color: cs.onSurface),
                          decoration: InputDecoration(labelText: 'Max'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Bildirim
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_rounded, color: AppColors.warning, size: 20.r),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Eşik Bildirimi', style: AppTextStyles.bodyMedium.copyWith(color: cs.onSurface, fontWeight: FontWeight.w500)),
                              Text('Değer eşiği aştığında bildirim gönder', style: AppTextStyles.labelSmall),
                            ],
                          ),
                        ),
                        Switch(
                          value: _notifyOnThreshold,
                          onChanged: (v) => setState(() => _notifyOnThreshold = v),
                          activeTrackColor: AppColors.warning,
                          activeThumbColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Kaydet
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      height: 52.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 16, offset: const Offset(0, 4))],
                      ),
                      child: Center(child: Text('Kaydet', style: AppTextStyles.labelLarge.copyWith(color: Colors.white))),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled, letterSpacing: 1.1),
      );
}

class _TypeGrid extends StatelessWidget {
  const _TypeGrid({required this.selected, required this.onSelect});
  final SensorType selected;
  final ValueChanged<SensorType> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: SensorType.values.map((t) {
        final isSelected = t == selected;
        return GestureDetector(
          onTap: () => onSelect(t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? t.color.withValues(alpha: 0.2) : AppColors.border.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: isSelected ? t.color : AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(t.icon, color: isSelected ? t.color : AppColors.textSecondary, size: 14.r),
                SizedBox(width: 6.w),
                Text(
                  t.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected ? t.color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
