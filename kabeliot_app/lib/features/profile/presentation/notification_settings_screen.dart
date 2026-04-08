import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/providers/notification_settings_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_scaffold.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Bildirim Ayarları', style: AppTextStyles.headingSmall),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 20.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Hata: $e')),
          data: (settings) => ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            children: [
              _buildSection('Cihaz Bildirimleri', [
                _ToggleRow(
                  icon: Icons.wifi_rounded,
                  color: AppColors.success,
                  label: 'Cihaz Çevrimiçi',
                  subtitle: 'Cihaz bağlandığında bildir',
                  value: settings.deviceOnline,
                  onChanged: (v) => ref
                      .read(notificationSettingsProvider.notifier)
                      .toggle(NotificationSettings.keyDeviceOnline, v),
                ),
                _divider(),
                _ToggleRow(
                  icon: Icons.wifi_off_rounded,
                  color: AppColors.error,
                  label: 'Cihaz Çevrimdışı',
                  subtitle: 'Bağlantı kesildiğinde bildir',
                  value: settings.deviceOffline,
                  onChanged: (v) => ref
                      .read(notificationSettingsProvider.notifier)
                      .toggle(NotificationSettings.keyDeviceOffline, v),
                ),
              ]),
              SizedBox(height: 16.h),
              _buildSection('Sensör & Röle', [
                _ToggleRow(
                  icon: Icons.sensors_rounded,
                  color: AppColors.warning,
                  label: 'Sensör Uyarıları',
                  subtitle: 'Eşik değeri aşıldığında bildir',
                  value: settings.sensorAlert,
                  onChanged: (v) => ref
                      .read(notificationSettingsProvider.notifier)
                      .toggle(NotificationSettings.keySensorAlert, v),
                ),
                _divider(),
                _ToggleRow(
                  icon: Icons.toggle_on_rounded,
                  color: AppColors.accent,
                  label: 'Röle Değişimleri',
                  subtitle: 'Röle durumu değiştiğinde bildir',
                  value: settings.relayChange,
                  onChanged: (v) => ref
                      .read(notificationSettingsProvider.notifier)
                      .toggle(NotificationSettings.keyRelayChange, v),
                ),
              ]),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.info, size: 16.r),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Bildirimler kaydedildi. Uygulama yeniden açılsada ayarlar korunur.',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  Widget _divider() => Divider(height: 1, color: AppColors.divider, indent: 52.w);
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                        .copyWith(color: Theme.of(context).colorScheme.onSurface)),
                Text(subtitle, style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryGlow,
            inactiveThumbColor: AppColors.textDisabled,
            inactiveTrackColor: AppColors.border,
          ),
        ],
      ),
    );
  }
}
