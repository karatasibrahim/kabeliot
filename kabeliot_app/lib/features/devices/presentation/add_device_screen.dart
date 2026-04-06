import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/kabel_button.dart';
import '../../../shared/widgets/kabel_text_field.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  int _step = 0;
  bool _isConnecting = false;
  bool _isSuccess = false;

  final _deviceNameController = TextEditingController();
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _deviceNameController.dispose();
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 1 && !_formKey.currentState!.validate()) return;
    if (_step == 1) {
      setState(() { _step = 2; _isConnecting = true; });
      // Simüle: bağlanma denemesi
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() { _isConnecting = false; _isSuccess = true; });
      });
      return;
    }
    setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Yeni Cihaz Ekle', style: AppTextStyles.headingSmall),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 20.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              _buildStepIndicator(),
              SizedBox(height: 32.h),
              Expanded(child: _buildCurrentStep()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Hazırlık', 'Ağ Bilgisi', 'Bağlanıyor'];
    return Row(
      children: steps.asMap().entries.map((e) {
        final done = e.key < _step;
        final active = e.key == _step;
        final color = done || active ? AppColors.primary : AppColors.border;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 3.h,
                  color: e.key == 0 ? Colors.transparent : (e.key <= _step ? AppColors.primary : AppColors.border),
                ),
              ),
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? AppColors.primary : (active ? AppColors.primaryGlow : AppColors.surface),
                      border: Border.all(color: color, width: 1.5),
                    ),
                    child: Center(
                      child: done
                          ? Icon(Icons.check_rounded, color: Colors.white, size: 14.r)
                          : Text('${e.key + 1}', style: AppTextStyles.labelSmall.copyWith(color: color)),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(steps[e.key], style: AppTextStyles.labelSmall.copyWith(color: active ? AppColors.primary : AppColors.textDisabled)),
                ],
              ),
              Expanded(
                child: Container(
                  height: 3.h,
                  color: e.key == steps.length - 1 ? Colors.transparent : (e.key < _step ? AppColors.primary : AppColors.border),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrentStep() {
    return switch (_step) {
      0 => _buildStep1(),
      1 => _buildStep2(),
      _ => _buildStep3(),
    };
  }

  Widget _buildStep1() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24.r),
          decoration: AppDecorations.cardElevated,
          child: Column(
            children: [
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGlow,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Icon(Icons.developer_board_rounded, color: AppColors.primary, size: 40.r),
              ),
              SizedBox(height: 20.h),
              Text('ESP32 Kartını Hazırlayın', style: AppTextStyles.headingMedium),
              SizedBox(height: 12.h),
              Text(
                'Cihazı ekleyebilmek için ESP32 kartınızın AP (Access Point) modunda olması gerekiyor.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              _buildStepItem(icon: Icons.power_settings_new_rounded, color: AppColors.success, text: '1. ESP32 kartını güce takın'),
              _buildStepItem(icon: Icons.wifi_tethering_rounded, color: AppColors.accent, text: '2. BOOT + EN butonlarına aynı anda basın'),
              _buildStepItem(icon: Icons.signal_wifi_4_bar_rounded, color: AppColors.primary, text: '3. "Kabel-Setup-XXXX" WiFi ağını bekleyin'),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        const Spacer(),
        KabelButton(label: 'Devam Et', onPressed: _nextStep, icon: Icons.arrow_forward_rounded),
      ],
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: AppDecorations.cardElevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ağ ve Cihaz Bilgileri', style: AppTextStyles.headingMedium),
                SizedBox(height: 8.h),
                Text('Bu bilgiler ESP32\'ye aktarılacak', style: AppTextStyles.bodySmall),
                SizedBox(height: 24.h),
                KabelTextField(
                  label: 'Cihaz Adı',
                  hint: 'Örn: Mutfak Sensörü',
                  controller: _deviceNameController,
                  prefixIcon: Icons.label_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.isEmpty) ? 'Cihaz adı gerekli' : null,
                ),
                SizedBox(height: 14.h),
                KabelTextField(
                  label: 'WiFi Ağ Adı (SSID)',
                  hint: 'Ev WiFi ağınızın adı',
                  controller: _ssidController,
                  prefixIcon: Icons.wifi_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.isEmpty) ? 'SSID gerekli' : null,
                ),
                SizedBox(height: 14.h),
                KabelTextField(
                  label: 'WiFi Şifresi',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  isObscure: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) => (v == null || v.isEmpty) ? 'Şifre gerekli' : null,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.accent, size: 14.r),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'Şifre yalnızca ESP32\'ye iletilir, sunucuda saklanmaz.',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const Spacer(),
          KabelButton(label: 'Cihazı Yapılandır', onPressed: _nextStep, icon: Icons.settings_rounded),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _isConnecting
              ? Column(
                  key: const ValueKey('connecting'),
                  children: [
                    SizedBox(
                      width: 80.r,
                      height: 80.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text('Cihaza Bağlanılıyor...', style: AppTextStyles.headingMedium),
                    SizedBox(height: 8.h),
                    Text('ESP32 ağ bilgilerini alıyor', style: AppTextStyles.bodyMedium),
                  ],
                )
              : _isSuccess
                  ? Column(
                      key: const ValueKey('success'),
                      children: [
                        Container(
                          width: 80.r,
                          height: 80.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.success.withValues(alpha: 0.15),
                            border: Border.all(color: AppColors.success, width: 2),
                          ),
                          child: Icon(Icons.check_rounded, color: AppColors.success, size: 44.r),
                        ).animate().scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 400.ms, curve: Curves.elasticOut),
                        SizedBox(height: 24.h),
                        Text('Cihaz Eklendi!', style: AppTextStyles.headingMedium.copyWith(color: AppColors.success))
                            .animate().fadeIn(duration: 400.ms, delay: 200.ms),
                        SizedBox(height: 8.h),
                        Text(
                          '"${_deviceNameController.text}" başarıyla yapılandırıldı',
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                        SizedBox(height: 12.h),
                        Text('MQTT konusu: kb/${_ssidController.text.toLowerCase().replaceAll(' ', '_')}/data', style: AppTextStyles.mono)
                            .animate().fadeIn(duration: 400.ms, delay: 400.ms),
                      ],
                    )
                  : const SizedBox.shrink(),
        ),
        if (_isSuccess) ...[
          SizedBox(height: 40.h),
          KabelButton(
            label: 'Cihazlara Dön',
            onPressed: () => Navigator.of(context).pop(),
            icon: Icons.arrow_back_rounded,
          ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
        ],
      ],
    );
  }

  Widget _buildStepItem({required IconData icon, required Color color, required String text}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16.r),
          ),
          SizedBox(width: 12.w),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}
