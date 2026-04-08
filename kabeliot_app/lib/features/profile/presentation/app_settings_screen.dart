import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_scaffold.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  Future<void> _clearCache(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    // Sensor ve relay config cache'ini temizle (sc_ ve rc_ prefix'li keyler)
    final keys = prefs.getKeys().where((k) => k.startsWith('sc_') || k.startsWith('rc_')).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${keys.length} önbellek kaydı temizlendi.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Uygulama Ayarları', style: AppTextStyles.headingSmall),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 20.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          children: [
            // Uygulama Bilgisi
            _buildSection('Uygulama Bilgisi', [
              _infoRow('Uygulama Adı', 'Kabel Core'),
              _divider(),
              _infoRow('Versiyon', '1.0.0'),
              _divider(),
              _infoRow('Yapı Tarihi', '2026.04.06'),
              _divider(),
              _infoRow('Platform', 'Flutter 3.38.5'),
              _divider(),
              _infoRow('Paket', 'com.kabel.core'),
            ]),
            SizedBox(height: 16.h),

            // Veri & Önbellek
            _buildSection('Veri & Önbellek', [
              _actionRow(
                icon: Icons.cleaning_services_rounded,
                color: AppColors.warning,
                label: 'Sensör/Röle Önbelleğini Temizle',
                subtitle: 'Yerel yapılandırma verilerini sıfırlar',
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.surfaceElevated,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r)),
                    title: Text('Önbelleği Temizle', style: AppTextStyles.headingSmall),
                    content: Text(
                      'Sensör ve röle yapılandırmaları sıfırlanacak. Bu işlem geri alınamaz.',
                      style: AppTextStyles.bodySmall,
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('İptal')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _clearCache(context);
                        },
                        child: Text('Temizle',
                            style: TextStyle(color: AppColors.warning)),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            SizedBox(height: 16.h),

            // Hakkında
            _buildSection('Hakkında', [
              _actionRow(
                icon: Icons.info_outline_rounded,
                color: AppColors.info,
                label: 'Kabel Teknoloji',
                subtitle: 'IoT cihaz yönetim platformu',
                onTap: () {},
                showChevron: false,
              ),
              _divider(),
              _actionRow(
                icon: Icons.shield_outlined,
                color: AppColors.accent,
                label: 'Gizlilik Politikası',
                subtitle: 'Veri işleme ve güvenlik',
                onTap: () {},
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textDisabled, letterSpacing: 1.2),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Text(label,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimary)),
            const Spacer(),
            Text(value, style: AppTextStyles.bodySmall),
          ],
        ),
      );

  Widget _actionRow({
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool showChevron = true,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(icon, color: color, size: 18.r),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textPrimary)),
                    Text(subtitle, style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
              if (showChevron)
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textDisabled, size: 18.r),
            ],
          ),
        ),
      );

  Widget _divider() =>
      Divider(height: 1, color: AppColors.divider, indent: 52.w);
}
