import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/thingsboard/tb_auth_provider.dart';
import '../../../core/thingsboard/tb_settings_provider.dart';
import '../../../shared/widgets/gradient_scaffold.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _hostCtrl  = TextEditingController();
  final _portCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loaded = false;
  bool _testing = false;
  String? _testResult;
  bool _testSuccess = false;
  bool _obscurePass = true;

  void _loadSettings(TbSettings s) {
    if (_loaded) return;
    _loaded = true;
    _hostCtrl.text  = s.host;
    _portCtrl.text  = s.port.toString();
    _emailCtrl.text = s.email;
    _passCtrl.text  = s.password;
  }

  Future<void> _saveAndTest() async {
    final host     = _hostCtrl.text.trim();
    final port     = int.tryParse(_portCtrl.text.trim()) ?? tbDefaultPort;
    final email    = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    setState(() { _testing = true; _testResult = null; });

    await ref.read(tbSettingsNotifierProvider.notifier).save(
      host: host, port: port, email: email, password: password,
    );
    await ref.read(tbAuthProvider.notifier).reconnect();

    final token = ref.read(tbAuthProvider).valueOrNull;
    if (!mounted) return;
    setState(() {
      _testing = false;
      _testSuccess = token != null;
      _testResult = token != null
          ? 'Bağlantı başarılı! JWT alındı.'
          : 'Bağlantı başarısız. Bilgileri kontrol edin.';
    });
  }

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(tbSettingsNotifierProvider);
    final authAsync     = ref.watch(tbAuthProvider);

    settingsAsync.whenData(_loadSettings);

    final isConnected = authAsync.valueOrNull != null;
    final (statusColor, statusLabel) = isConnected
        ? (AppColors.success, 'Bağlı')
        : (AppColors.error, 'Bağlı Değil');

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('MQTT Sunucu Ayarları', style: AppTextStyles.headingSmall),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 20.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          children: [
            // ── ThingsBoard Bağlantısı ─────────────────────────────────
            _buildSectionWithBadge(
              'ThingsBoard Sunucu', statusColor, statusLabel,
              [
                _buildTextRow(label: 'Sunucu', controller: _hostCtrl, hint: 'smartio.kabelteknoloji.com'),
                _buildDivider(),
                _buildTextRow(label: 'Port', controller: _portCtrl, hint: '8080', keyboardType: TextInputType.number),
                _buildDivider(),
                _buildTextRow(label: 'E-posta', controller: _emailCtrl, hint: 'admin@example.com', keyboardType: TextInputType.emailAddress),
                _buildDivider(),
                _buildPassRow(),
              ],
            ),
            SizedBox(height: 8.h),

            // Test sonucu
            if (_testResult != null)
              Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: (_testSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: (_testSuccess ? AppColors.success : AppColors.error).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                      color: _testSuccess ? AppColors.success : AppColors.error,
                      size: 18.r,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _testSuccess ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Info ──────────────────────────────────────────────────
            _buildSection('Bilgi', [
              _buildInfoRow('MQTT Host', '${_hostCtrl.text.isNotEmpty ? _hostCtrl.text : tbDefaultHost}:1883'),
              _buildDivider(),
              _buildInfoRow('WebSocket', 'ws://host:${_portCtrl.text.isNotEmpty ? _portCtrl.text : tbDefaultPort}/api/ws'),
            ]),
            SizedBox(height: 24.h),

            // ── Bağlan & Test Et ──────────────────────────────────────
            GestureDetector(
              onTap: _testing ? null : _saveAndTest,
              child: Container(
                height: 52.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [BoxShadow(color: AppColors.primaryGlow, blurRadius: 20, offset: const Offset(0, 4))],
                ),
                child: Center(
                  child: _testing
                      ? SizedBox(width: 20.r, height: 20.r, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Kaydet & Bağlan', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
                ),
              ),
            ),
            SizedBox(height: 24.h),
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
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled, letterSpacing: 1.2),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSectionWithBadge(String title, Color badgeColor, String badgeLabel, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
          child: Row(
            children: [
              Text(title.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled, letterSpacing: 1.2)),
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextRow({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
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

  Widget _buildPassRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text('Şifre', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
          ),
          Expanded(
            child: TextField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              textAlign: TextAlign.end,
              style: AppTextStyles.mono.copyWith(fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: '••••••••',
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
          GestureDetector(
            onTap: () => setState(() => _obscurePass = !_obscurePass),
            child: Icon(
              _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 18.r,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
          const Spacer(),
          Text(value, style: AppTextStyles.mono.copyWith(fontSize: 11.sp, color: AppColors.textDisabled)),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, color: AppColors.divider, indent: 16.w);
}
