import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/mqtt/mqtt_providers.dart';
import '../../../core/mqtt/mqtt_service.dart';
import '../../../core/mqtt/mqtt_settings_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_scaffold.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // MQTT
  final _mqttHostController = TextEditingController();
  final _mqttPortController = TextEditingController();
  final _mqttUserController = TextEditingController();
  final _mqttPassController = TextEditingController();
  bool _mqttTls = false;
  bool _settingsLoaded = false;

  // Bildirimler
  bool _notifDeviceOnline = true;
  bool _notifDeviceOffline = true;
  bool _notifSensorAlert = true;
  bool _notifRelayChange = false;

  void _loadSettings(MqttSettingsData s) {
    if (_settingsLoaded) return;
    _settingsLoaded = true;
    _mqttHostController.text = s.host;
    _mqttPortController.text = s.port.toString();
    _mqttUserController.text = s.user;
    _mqttPassController.text = s.password;
  }

  Future<void> _save() async {
    await ref.read(mqttSettingsProvider.notifier).save(
      host: _mqttHostController.text.trim(),
      port: int.tryParse(_mqttPortController.text.trim()) ?? 1883,
      user: _mqttUserController.text.trim(),
      password: _mqttPassController.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20.r),
            SizedBox(width: 8.w),
            const Text('MQTT ayarları kaydedildi, yeniden bağlanılıyor…'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mqttHostController.dispose();
    _mqttPortController.dispose();
    _mqttUserController.dispose();
    _mqttPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mqttSettingsAsync = ref.watch(mqttSettingsProvider);
    final mqttStatus = ref.watch(mqttConnectionProvider);

    mqttSettingsAsync.whenData(_loadSettings);

    final (statusColor, statusLabel) = switch (mqttStatus) {
      MqttConnectionStatus.connected => (AppColors.success, 'Bağlı'),
      MqttConnectionStatus.connecting => (AppColors.warning, 'Bağlanıyor'),
      MqttConnectionStatus.disconnected => (AppColors.error, 'Bağlı Değil'),
      MqttConnectionStatus.error => (AppColors.error, 'Hata'),
    };

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Ayarlar', style: AppTextStyles.headingSmall),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 20.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          children: [
            // --- MQTT ---
            _buildSectionWithBadge('MQTT Sunucu', statusColor, statusLabel, [
              _buildTextRow(label: 'Sunucu Adresi', controller: _mqttHostController, hint: 'örn: mqtt.broker.io'),
              _buildDivider(),
              _buildTextRow(label: 'Port', controller: _mqttPortController, hint: '1883', keyboardType: TextInputType.number),
              _buildDivider(),
              _buildTextRow(label: 'Kullanıcı', controller: _mqttUserController, hint: 'boş bırakılabilir'),
              _buildDivider(),
              _buildTextRow(label: 'Şifre', controller: _mqttPassController, hint: 'boş bırakılabilir', obscure: true),
              _buildDivider(),
              _buildToggleRow(
                icon: Icons.lock_outline,
                color: AppColors.success,
                label: 'TLS/SSL',
                subtitle: 'Güvenli bağlantı kullan',
                value: _mqttTls,
                onChanged: (v) => setState(() => _mqttTls = v),
              ),
            ]),
            SizedBox(height: 16.h),

            // --- Bildirimler ---
            _buildSection('Bildirimler', [
              _buildToggleRow(
                icon: Icons.wifi_rounded,
                color: AppColors.success,
                label: 'Cihaz Çevrimiçi',
                subtitle: 'Cihaz bağlandığında bildir',
                value: _notifDeviceOnline,
                onChanged: (v) => setState(() => _notifDeviceOnline = v),
              ),
              _buildDivider(),
              _buildToggleRow(
                icon: Icons.wifi_off_rounded,
                color: AppColors.error,
                label: 'Cihaz Çevrimdışı',
                subtitle: 'Cihaz bağlantısı kesildiğinde bildir',
                value: _notifDeviceOffline,
                onChanged: (v) => setState(() => _notifDeviceOffline = v),
              ),
              _buildDivider(),
              _buildToggleRow(
                icon: Icons.sensors_rounded,
                color: AppColors.warning,
                label: 'Sensör Uyarıları',
                subtitle: 'Eşik değeri aşıldığında bildir',
                value: _notifSensorAlert,
                onChanged: (v) => setState(() => _notifSensorAlert = v),
              ),
              _buildDivider(),
              _buildToggleRow(
                icon: Icons.toggle_on_rounded,
                color: AppColors.accent,
                label: 'Röle Değişimleri',
                subtitle: 'Röle durumu değiştiğinde bildir',
                value: _notifRelayChange,
                onChanged: (v) => setState(() => _notifRelayChange = v),
              ),
            ]),
            SizedBox(height: 16.h),

            // --- Uygulama Bilgisi ---
            _buildSection('Uygulama', [
              _buildInfoRow(label: 'Versiyon', value: '1.0.0'),
              _buildDivider(),
              _buildInfoRow(label: 'Yapı', value: '2026.04.06'),
              _buildDivider(),
              _buildInfoRow(label: 'Flutter SDK', value: '3.38.5'),
            ]),
            SizedBox(height: 24.h),

            // Kaydet butonu
            GestureDetector(
              onTap: _save,
              child: Container(
                height: 52.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 20, offset: const Offset(0, 4))],
                ),
                child: Center(child: Text('Kaydet', style: AppTextStyles.labelLarge.copyWith(color: Colors.white))),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled, letterSpacing: 1.2),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSectionWithBadge(String title, Color badgeColor, String badgeLabel, List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
          child: Row(
            children: [
              Text(
                title.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled, letterSpacing: 1.2),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6.r, height: 6.r, decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle)),
                    SizedBox(width: 4.w),
                    Text(badgeLabel, style: AppTextStyles.labelSmall.copyWith(color: badgeColor)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(9.r)),
            child: Icon(icon, color: color, size: 18.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
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

  Widget _buildTextRow({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscure = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          SizedBox(
            width: 110.w,
            child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscure,
              textAlign: TextAlign.end,
              style: AppTextStyles.mono.copyWith(fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.labelSmall,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          const Spacer(),
          Text(value, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, color: AppColors.divider, indent: 52.w);
}
