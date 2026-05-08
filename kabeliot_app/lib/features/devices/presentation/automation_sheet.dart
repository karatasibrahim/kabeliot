import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/device_models.dart';
import '../providers/automation_provider.dart';
import '../providers/sensor_config_provider.dart';

void showAddAutomationSheet(
  BuildContext context, {
  required WidgetRef ref,
  required String deviceId,
  AutomationRule? editRule,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AutomationSheet(
      deviceId: deviceId,
      editRule: editRule,
      parentRef: ref,
    ),
  );
}

class _AutomationSheet extends ConsumerStatefulWidget {
  const _AutomationSheet({
    required this.deviceId,
    required this.parentRef,
    this.editRule,
  });
  final String deviceId;
  final WidgetRef parentRef;
  final AutomationRule? editRule;

  @override
  ConsumerState<_AutomationSheet> createState() => _AutomationSheetState();
}

class _AutomationSheetState extends ConsumerState<_AutomationSheet> {
  late int _sensorIndex;
  late RuleOperator _operator;
  late double _threshold;
  late int _relayIndex;
  late bool _relayAction;

  final _thresholdCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final r = widget.editRule;
    _sensorIndex = r?.sensorIndex ?? 0;
    _operator    = r?.operator    ?? RuleOperator.gt;
    _threshold   = r?.threshold   ?? 0;
    _relayIndex  = r?.relayIndex  ?? 0;
    _relayAction = r?.relayAction ?? true;
    _thresholdCtrl.text = _threshold == 0 ? '' : _threshold.toString();
  }

  @override
  void dispose() {
    _thresholdCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final val = double.tryParse(_thresholdCtrl.text.replaceAll(',', '.'));
    if (val == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Geçerli bir eşik değeri girin.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final notifier = ref.read(automationRulesProvider(widget.deviceId).notifier);
    if (widget.editRule != null) {
      notifier.updateRule(
        widget.editRule!.copyWith(
          sensorIndex: _sensorIndex,
          operator: _operator,
          threshold: val,
          relayIndex: _relayIndex,
          relayAction: _relayAction,
        ),
      );
    } else {
      notifier.addRule(AutomationRule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sensorIndex: _sensorIndex,
        operator: _operator,
        threshold: val,
        relayIndex: _relayIndex,
        relayAction: _relayAction,
      ));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final configsAsync = ref.watch(sensorConfigsProvider(widget.deviceId, kMaxSensors));
    final sensorNames = configsAsync.valueOrNull
        ?.asMap()
        .entries
        .map((e) => 'Kanal ${e.key + 1}: ${e.value.name}')
        .toList() ??
        List.generate(kMaxSensors, (i) => 'Kanal ${i + 1}');

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              widget.editRule != null ? 'Kuralı Düzenle' : 'Otomasyon Kuralı Ekle',
              style: AppTextStyles.headingSmall,
            ),
            SizedBox(height: 20.h),

            // Sensör seçimi
            _Label('Sensör'),
            SizedBox(height: 6.h),
            _Dropdown<int>(
              value: _sensorIndex,
              items: List.generate(
                kMaxSensors,
                (i) => DropdownMenuItem(value: i, child: Text(sensorNames[i], style: AppTextStyles.bodySmall)),
              ),
              onChanged: (v) => setState(() => _sensorIndex = v!),
            ),
            SizedBox(height: 16.h),

            // Koşul + eşik
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('Koşul'),
                      SizedBox(height: 6.h),
                      _Dropdown<RuleOperator>(
                        value: _operator,
                        items: RuleOperator.values
                            .map((op) => DropdownMenuItem(
                                  value: op,
                                  child: Text('${op.symbol}  ${op.label}', style: AppTextStyles.bodySmall),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _operator = v!),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('Eşik Değeri'),
                      SizedBox(height: 6.h),
                      TextField(
                        controller: _thresholdCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        style: AppTextStyles.bodySmall.copyWith(color: cs.onSurface),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          hintText: '0.0',
                          hintStyle: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Röle seçimi
            _Label('Röle'),
            SizedBox(height: 6.h),
            _Dropdown<int>(
              value: _relayIndex,
              items: List.generate(
                kMaxRelays,
                (i) => DropdownMenuItem(
                    value: i,
                    child: Text('Röle ${i + 1}', style: AppTextStyles.bodySmall)),
              ),
              onChanged: (v) => setState(() => _relayIndex = v!),
            ),
            SizedBox(height: 16.h),

            // Röle aksiyonu
            _Label('Aksiyon'),
            SizedBox(height: 8.h),
            Row(
              children: [
                _ActionChip(
                  label: 'AÇ',
                  selected: _relayAction,
                  color: AppColors.success,
                  onTap: () => setState(() => _relayAction = true),
                ),
                SizedBox(width: 10.w),
                _ActionChip(
                  label: 'KAPAT',
                  selected: !_relayAction,
                  color: AppColors.error,
                  onTap: () => setState(() => _relayAction = false),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Kaydet
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  widget.editRule != null ? 'Güncelle' : 'Kural Ekle',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary));
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({required this.value, required this.items, required this.onChanged});
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10.r),
        color: cs.surface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          dropdownColor: cs.surface,
          style: AppTextStyles.bodySmall.copyWith(color: cs.onSurface),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: selected ? color : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
