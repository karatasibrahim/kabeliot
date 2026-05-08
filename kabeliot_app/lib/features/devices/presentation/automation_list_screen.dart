import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/device_models.dart';
import '../providers/automation_provider.dart';
import 'automation_form_screen.dart';

class AutomationListScreen extends ConsumerWidget {
  const AutomationListScreen({super.key, required this.deviceId, required this.deviceName});

  final String deviceId;
  final String deviceName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules    = ref.watch(automationRulesProvider(deviceId));
    final notifier = ref.read(automationRulesProvider(deviceId).notifier);

    // Tüm kurallar için çakışma kontrolü
    final allConflicts = <String, List<ConflictWarning>>{};
    for (final rule in rules) {
      final others = rules.where((r) => r.id != rule.id).toList();
      final warnings = detectConflicts(
        others,
        rule.relayIndex,
        rule.relayAction,
        rule.sensorIndex,
        rule.operator,
        rule.threshold,
        excludeId: rule.id,
      ).where((w) => w.level != ConflictLevel.missingPair).toList();
      if (warnings.isNotEmpty) allConflicts[rule.id] = warnings;
    }

    final hasAnyConflict = allConflicts.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Otomasyonlar', style: AppTextStyles.headingSmall),
            Text(deviceName,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 20.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AutomationFormScreen(deviceId: deviceId),
        )),
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add_rounded, size: 20.r),
        label: Text('Kural Ekle', style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
      ),
      body: rules.isEmpty
          ? _EmptyState(
              onAdd: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AutomationFormScreen(deviceId: deviceId),
              )),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
              children: [
                // Genel çakışma uyarı başlığı
                if (hasAnyConflict) ...[
                  _GlobalConflictBanner(conflictCount: allConflicts.length),
                  SizedBox(height: 12.h),
                ],

                ...rules.asMap().entries.map((entry) {
                  final i    = entry.key;
                  final rule = entry.value;
                  final conflicts = allConflicts[rule.id] ?? [];

                  return _RuleCard(
                    rule: rule,
                    conflicts: conflicts,
                    onToggle: () => notifier.toggleEnabled(rule.id),
                    onEdit: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AutomationFormScreen(
                        deviceId: deviceId,
                        editRule: rule,
                      ),
                    )),
                    onDelete: () => _confirmDelete(context, rule, notifier),
                  ).animate().fadeIn(duration: 220.ms, delay: Duration(milliseconds: i * 50));
                }),
              ],
            ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AutomationRule rule,
    AutomationRules notifier,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Kuralı Sil', style: AppTextStyles.headingSmall),
        content: Text(
          'Bu otomasyon kuralını silmek istiyor musunuz?',
          style: AppTextStyles.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('İptal',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              notifier.deleteRule(rule.id);
              Navigator.of(ctx).pop();
            },
            child: Text('Sil',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Kural Kartı ─────────────────────────────────────────────────────────────

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.rule,
    required this.conflicts,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final AutomationRule rule;
  final List<ConflictWarning> conflicts;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final actionColor = rule.relayAction ? AppColors.success : AppColors.error;
    final hasConflict = conflicts.isNotEmpty;
    final hasHard = conflicts.any((c) => c.level == ConflictLevel.hard);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: rule.isEnabled ? 1.0 : 0.6,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasHard
                ? AppColors.error.withValues(alpha: 0.5)
                : hasConflict
                    ? AppColors.warning.withValues(alpha: 0.5)
                    : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            // Ana içerik
            Padding(
              padding: EdgeInsets.all(14.r),
              child: Row(
                children: [
                  // İkon
                  Container(
                    width: 40.r, height: 40.r,
                    decoration: BoxDecoration(
                      color: (hasHard
                              ? AppColors.error
                              : hasConflict
                                  ? AppColors.warning
                                  : AppColors.accent)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      hasHard
                          ? Icons.error_rounded
                          : hasConflict
                              ? Icons.warning_amber_rounded
                              : Icons.auto_awesome_rounded,
                      color: hasHard
                          ? AppColors.error
                          : hasConflict
                              ? AppColors.warning
                              : AppColors.accent,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Kural açıklaması
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodySmall.copyWith(color: cs.onSurface),
                            children: [
                              TextSpan(text: 'Sensör ${rule.sensorIndex + 1} '),
                              TextSpan(
                                text: rule.operator.symbol,
                                style: AppTextStyles.mono.copyWith(
                                    color: AppColors.primary, fontSize: 13.sp),
                              ),
                              TextSpan(text: ' ${rule.threshold}  →  Röle ${rule.relayIndex + 1} '),
                              TextSpan(
                                text: rule.relayAction ? 'AÇ' : 'KAPAT',
                                style: AppTextStyles.labelSmall.copyWith(
                                    color: actionColor, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Sensör ${rule.sensorIndex + 1} ${rule.operator.label} '
                          '${rule.threshold} ise Röle ${rule.relayIndex + 1} '
                          '${rule.relayAction ? "aç" : "kapat"}',
                          style: AppTextStyles.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // Aksiyon butonları
                  GestureDetector(
                    onTap: onEdit,
                    child: Icon(Icons.edit_rounded, size: 17.r, color: AppColors.textDisabled),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(Icons.delete_outline_rounded,
                        size: 17.r, color: AppColors.error.withValues(alpha: 0.7)),
                  ),
                  SizedBox(width: 6.w),
                  Switch(
                    value: rule.isEnabled,
                    onChanged: (_) => onToggle(),
                    activeTrackColor: AppColors.accent,
                    activeThumbColor: Colors.white,
                    inactiveThumbColor: AppColors.textDisabled,
                    inactiveTrackColor: AppColors.border,
                  ),
                ],
              ),
            ),

            // Çakışma uyarıları (kart altında)
            if (conflicts.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: (hasHard ? AppColors.error : AppColors.warning)
                      .withValues(alpha: 0.07),
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(14.r)),
                ),
                padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: conflicts.map((c) => Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          c.level == ConflictLevel.hard
                              ? Icons.error_outline_rounded
                              : Icons.warning_amber_rounded,
                          size: 14.r,
                          color: c.level == ConflictLevel.hard
                              ? AppColors.error
                              : AppColors.warning,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            c.message,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: c.level == ConflictLevel.hard
                                  ? AppColors.error
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Yardımcı widget'lar ──────────────────────────────────────────────────────

class _GlobalConflictBanner extends StatelessWidget {
  const _GlobalConflictBanner({required this.conflictCount});
  final int conflictCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              '$conflictCount kural çakışması tespit edildi. '
              'Çakışan kurallar aynı rölede zıt komutlar verebilir.',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_outlined,
                size: 56.r, color: AppColors.textDisabled),
            SizedBox(height: 16.h),
            Text('Henüz otomasyon kuralı yok',
                style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary)),
            SizedBox(height: 8.h),
            Text(
              'Sensör değerine göre röleleri\notomatik olarak kontrol et.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              icon: Icon(Icons.add_rounded, size: 18.r),
              label: Text('İlk Kuralı Ekle', style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
