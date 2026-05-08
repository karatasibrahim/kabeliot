import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/device_models.dart';
import '../providers/automation_provider.dart';
import '../providers/sensor_config_provider.dart';

// ─── Çakışma tespiti ──────────────────────────────────────────────────────────

enum ConflictLevel { hard, soft, missingPair }

class ConflictWarning {
  const ConflictWarning(this.level, this.message);
  final ConflictLevel level;
  final String message;
}

bool _conditionsCanOverlap(AutomationRule a, AutomationRule b) {
  final op1 = a.operator; final t1 = a.threshold;
  final op2 = b.operator; final t2 = b.threshold;

  bool gtLike(RuleOperator o) => o == RuleOperator.gt || o == RuleOperator.gte;
  bool ltLike(RuleOperator o) => o == RuleOperator.lt || o == RuleOperator.lte;

  if (op1 == RuleOperator.eq) return b.evaluate(t1);
  if (op2 == RuleOperator.eq) return a.evaluate(t2);
  if (gtLike(op1) && gtLike(op2)) return true;
  if (ltLike(op1) && ltLike(op2)) return true;
  if (gtLike(op1) && ltLike(op2)) return t1 < t2;
  if (ltLike(op1) && gtLike(op2)) return t2 < t1;
  return true;
}

List<ConflictWarning> detectConflicts(
  List<AutomationRule> existing,
  int relayIndex,
  bool relayAction,
  int sensorIndex,
  RuleOperator operator,
  double threshold, {
  String? excludeId,
}) {
  final warnings = <ConflictWarning>[];

  final draft = AutomationRule(
    id: excludeId ?? '__draft__',
    sensorIndex: sensorIndex,
    operator: operator,
    threshold: threshold,
    relayIndex: relayIndex,
    relayAction: relayAction,
  );

  for (final r in existing) {
    if (r.id == excludeId) continue;
    if (r.relayIndex != relayIndex) continue;

    if (r.relayAction != relayAction) {
      // Zıt aksiyon — aynı röle
      if (r.sensorIndex == sensorIndex && _conditionsCanOverlap(r, draft)) {
        warnings.add(ConflictWarning(
          ConflictLevel.hard,
          'KESİN ÇAKIŞMA: "Sensör ${r.sensorIndex + 1} ${r.operator.symbol} ${r.threshold} '
          '→ Röle ${r.relayIndex + 1} ${r.relayAction ? "AÇ" : "KAPAT"}" '
          'kuralıyla aynı anda tetiklenebilir. Aynı röleye zıt komut gönderilir.',
        ));
      } else {
        warnings.add(ConflictWarning(
          ConflictLevel.soft,
          'POTANSİYEL ÇAKIŞMA: "Sensör ${r.sensorIndex + 1} ${r.operator.symbol} ${r.threshold} '
          '→ Röle ${r.relayIndex + 1} ${r.relayAction ? "AÇ" : "KAPAT"}" '
          'kuralı aynı rölede zıt komut veriyor. Sensörler eş zamanlı tetiklenirse çakışır.',
        ));
      }
    }
  }

  // Eksik çift uyarısı — bu röle için sadece tek yönlü kural varsa
  final sameRelayRules = existing.where(
    (r) => r.relayIndex == relayIndex && r.id != excludeId,
  ).toList();
  final hasOpposite = sameRelayRules.any((r) => r.relayAction != relayAction);
  final hasSame     = sameRelayRules.any((r) => r.relayAction == relayAction);
  if (!hasOpposite && !hasSame) {
    // İlk kural bu röle için
    warnings.add(ConflictWarning(
      ConflictLevel.missingPair,
      'Bu röle için yalnızca ${relayAction ? "AÇ" : "KAPAT"} kuralı ekliyor'
      'sunuz. Karşıt bir kural olmadığında röle ${relayAction ? "sürekli açık" : "sürekli kapalı"} '
      'kalabilir.',
    ));
  } else if (!hasOpposite) {
    warnings.add(ConflictWarning(
      ConflictLevel.missingPair,
      'Röle ${relayIndex + 1} için yalnızca ${relayAction ? "AÇ" : "KAPAT"} kuralı var. '
      'Karşıt bir kural yoksa röle ${relayAction ? "sürekli açık" : "sürekli kapalı"} kalabilir.',
    ));
  }

  return warnings;
}

// ─── Form Ekranı ──────────────────────────────────────────────────────────────

class AutomationFormScreen extends ConsumerStatefulWidget {
  const AutomationFormScreen({
    super.key,
    required this.deviceId,
    this.editRule,
  });

  final String deviceId;
  final AutomationRule? editRule;

  @override
  ConsumerState<AutomationFormScreen> createState() => _AutomationFormScreenState();
}

class _AutomationFormScreenState extends ConsumerState<AutomationFormScreen> {
  late int _sensorIndex;
  late RuleOperator _operator;
  late int _relayIndex;
  late bool _relayAction;

  final _thresholdCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final r = widget.editRule;
    _sensorIndex = r?.sensorIndex ?? 0;
    _operator    = r?.operator    ?? RuleOperator.gt;
    _relayIndex  = r?.relayIndex  ?? 0;
    _relayAction = r?.relayAction ?? true;
    _thresholdCtrl.text = r != null ? r.threshold.toString() : '';
  }

  @override
  void dispose() {
    _thresholdCtrl.dispose();
    super.dispose();
  }

  double? get _threshold =>
      double.tryParse(_thresholdCtrl.text.replaceAll(',', '.'));

  List<ConflictWarning> get _conflicts {
    final t = _threshold;
    if (t == null) return [];
    final rules = ref.read(automationRulesProvider(widget.deviceId));
    return detectConflicts(
      rules,
      _relayIndex,
      _relayAction,
      _sensorIndex,
      _operator,
      t,
      excludeId: widget.editRule?.id,
    );
  }

  void _save() {
    final t = _threshold;
    if (t == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Geçerli bir eşik değeri girin.'),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    final notifier = ref.read(automationRulesProvider(widget.deviceId).notifier);

    if (widget.editRule != null) {
      notifier.updateRule(widget.editRule!.copyWith(
        sensorIndex: _sensorIndex,
        operator: _operator,
        threshold: t,
        relayIndex: _relayIndex,
        relayAction: _relayAction,
      ));
    } else {
      notifier.addRule(AutomationRule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sensorIndex: _sensorIndex,
        operator: _operator,
        threshold: t,
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
            .map((e) => '${e.value.name} (Kanal ${e.key + 1})')
            .toList() ??
        List.generate(kMaxSensors, (i) => 'Kanal ${i + 1}');

    final conflicts = _threshold != null ? _conflicts : <ConflictWarning>[];
    final hasHard = conflicts.any((c) => c.level == ConflictLevel.hard);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.editRule != null ? 'Kuralı Düzenle' : 'Yeni Kural',
          style: AppTextStyles.headingSmall,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 20.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Çakışma uyarıları
            if (conflicts.isNotEmpty) ...[
              ...conflicts.map((w) => _ConflictBanner(warning: w)),
              SizedBox(height: 20.h),
            ],

            // Önizleme
            if (_threshold != null) ...[
              _RulePreview(
                sensorIndex: _sensorIndex,
                operator: _operator,
                threshold: _threshold!,
                relayIndex: _relayIndex,
                relayAction: _relayAction,
              ),
              SizedBox(height: 24.h),
            ],

            // ── KOŞUL ──────────────────────────────────────────────────
            _SectionTitle(icon: Icons.sensors_rounded, title: 'Koşul'),
            SizedBox(height: 12.h),

            _Label('Sensör'),
            SizedBox(height: 6.h),
            _StyledDropdown<int>(
              value: _sensorIndex,
              items: List.generate(kMaxSensors, (i) => DropdownMenuItem(
                value: i,
                child: Text(sensorNames[i], style: AppTextStyles.bodySmall),
              )),
              onChanged: (v) => setState(() => _sensorIndex = v!),
            ),
            SizedBox(height: 16.h),

            _Label('Karşılaştırma Operatörü'),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: RuleOperator.values.map((op) => ChoiceChip(
                label: Text('${op.symbol}  ${op.label}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _operator == op ? Colors.white : cs.onSurface,
                    )),
                selected: _operator == op,
                selectedColor: AppColors.primary,
                backgroundColor: cs.surface,
                side: BorderSide(
                  color: _operator == op ? AppColors.primary : AppColors.border,
                ),
                onSelected: (_) => setState(() => _operator = op),
              )).toList(),
            ),
            SizedBox(height: 16.h),

            _Label('Eşik Değeri'),
            SizedBox(height: 6.h),
            TextField(
              controller: _thresholdCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              style: AppTextStyles.bodyMedium.copyWith(color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Örn: 30.0',
                hintStyle: AppTextStyles.bodySmall,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 28.h),

            // ── SONUÇ ──────────────────────────────────────────────────
            _SectionTitle(icon: Icons.toggle_on_rounded, title: 'Sonuç'),
            SizedBox(height: 12.h),

            _Label('Röle'),
            SizedBox(height: 6.h),
            _StyledDropdown<int>(
              value: _relayIndex,
              items: List.generate(kMaxRelays, (i) => DropdownMenuItem(
                value: i,
                child: Text('Röle ${i + 1}', style: AppTextStyles.bodySmall),
              )),
              onChanged: (v) => setState(() => _relayIndex = v!),
            ),
            SizedBox(height: 16.h),

            _Label('Aksiyon'),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'AÇ',
                    icon: Icons.power_rounded,
                    selected: _relayAction,
                    color: AppColors.success,
                    onTap: () => setState(() => _relayAction = true),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ActionButton(
                    label: 'KAPAT',
                    icon: Icons.power_off_rounded,
                    selected: !_relayAction,
                    color: AppColors.error,
                    onTap: () => setState(() => _relayAction = false),
                  ),
                ),
              ],
            ),
            SizedBox(height: 36.h),

            // Kaydet
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasHard ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.border,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: Text(
                  hasHard
                      ? 'Çakışma nedeniyle kaydedilemez'
                      : widget.editRule != null ? 'Güncelle' : 'Kuralı Kaydet',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: hasHard ? AppColors.textDisabled : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

// ─── Yardımcı widget'lar ──────────────────────────────────────────────────────

class _ConflictBanner extends StatelessWidget {
  const _ConflictBanner({required this.warning});
  final ConflictWarning warning;

  @override
  Widget build(BuildContext context) {
    final isHard = warning.level == ConflictLevel.hard;
    final isMissing = warning.level == ConflictLevel.missingPair;
    final color = isHard
        ? AppColors.error
        : isMissing
            ? AppColors.warning
            : const Color(0xFFF59E0B);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isHard ? Icons.error_rounded : Icons.warning_amber_rounded,
            color: color,
            size: 18.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(warning.message,
                style: AppTextStyles.labelSmall.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}

class _RulePreview extends StatelessWidget {
  const _RulePreview({
    required this.sensorIndex,
    required this.operator,
    required this.threshold,
    required this.relayIndex,
    required this.relayAction,
  });

  final int sensorIndex;
  final RuleOperator operator;
  final double threshold;
  final int relayIndex;
  final bool relayAction;

  @override
  Widget build(BuildContext context) {
    final color = relayAction ? AppColors.success : AppColors.error;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: color, size: 18.r),
          SizedBox(width: 10.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                children: [
                  TextSpan(text: 'Sensör ${sensorIndex + 1} '),
                  TextSpan(
                    text: operator.symbol,
                    style: AppTextStyles.mono.copyWith(
                        color: AppColors.primary, fontSize: 13.sp),
                  ),
                  TextSpan(text: ' $threshold  →  Röle ${relayIndex + 1} '),
                  TextSpan(
                    text: relayAction ? 'AÇ' : 'KAPAT',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: color, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: AppColors.primary),
        SizedBox(width: 6.w),
        Text(title,
            style: AppTextStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
        SizedBox(width: 8.w),
        Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary));
}

class _StyledDropdown<T> extends StatelessWidget {
  const _StyledDropdown(
      {required this.value, required this.items, required this.onChanged});
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
        borderRadius: BorderRadius.circular(12.r),
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? color : AppColors.textDisabled, size: 18.r),
            SizedBox(width: 6.w),
            Text(label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: selected ? color : AppColors.textDisabled,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }
}
