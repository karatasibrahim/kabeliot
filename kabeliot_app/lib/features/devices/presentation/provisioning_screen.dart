import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/kabel_button.dart';
import '../../../shared/widgets/kabel_text_field.dart';
import '../data/provisioning_service.dart';

const _kabelPrefix = 'KABEL';

class _ScannedAp {
  const _ScannedAp({required this.ssid, required this.level});
  final String ssid;
  final int level;
}

class ProvisioningScreen extends ConsumerStatefulWidget {
  const ProvisioningScreen({super.key});

  @override
  ConsumerState<ProvisioningScreen> createState() => _ProvisioningScreenState();
}

class _ProvisioningScreenState extends ConsumerState<ProvisioningScreen> {
  // Adım: 0=Tara, 1=WiFi Gir, 2=Sonuç
  int _step = 0;

  bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  // Adım 0 — tarama
  bool _isScanning = false;
  String? _scanError;
  List<_ScannedAp> _networks = [];
  final _manualSsidCtrl = TextEditingController(text: 'KABEL_');

  _ScannedAp? _selectedAp;

  // Adım 1 — WiFi bilgisi
  final _formKey      = GlobalKey<FormState>();
  final _ssidCtrl     = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Adım 2 — sonuç
  bool _isSending = false;
  bool _success   = false;
  String? _error;

  @override
  void dispose() {
    _manualSsidCtrl.dispose();
    _ssidCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ─── Adım 0: WiFi Tara ────────────────────────────────────────────────────

  void _connectManualIos() {
    final ssid = _manualSsidCtrl.text.trim();
    if (ssid.isEmpty) return;
    _selectAp(_ScannedAp(ssid: ssid, level: -60));
  }

  Future<void> _startScan() async {
    if (_isIos) { _connectManualIos(); return; }

    setState(() { _isScanning = true; _scanError = null; _networks = []; });

    final locStatus = await Permission.locationWhenInUse.request();
    if (!locStatus.isGranted) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _scanError = 'Konum izni gerekli. Ayarlar → Uygulama → Konum → İzin Ver';
      });
      return;
    }

    final canScan = await WiFiScan.instance.canStartScan(askPermissions: true);
    if (canScan != CanStartScan.yes) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _scanError = 'WiFi taraması başlatılamadı. Konum ve WiFi servislerinin açık olduğundan emin olun.';
      });
      return;
    }

    await WiFiScan.instance.startScan();

    final canGet = await WiFiScan.instance.canGetScannedResults(askPermissions: true);
    if (canGet != CanGetScannedResults.yes) {
      if (!mounted) return;
      setState(() { _isScanning = false; _scanError = 'Tarama sonuçları alınamadı.'; });
      return;
    }

    final results = await WiFiScan.instance.getScannedResults();
    final nets = results
        .where((ap) => ap.ssid.toUpperCase().startsWith(_kabelPrefix.toUpperCase()))
        .map((ap) => _ScannedAp(ssid: ap.ssid, level: ap.level))
        .toList()
      ..sort((a, b) => b.level.compareTo(a.level));

    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _networks = nets;
      if (nets.isEmpty) {
        _scanError = 'Yakında KABEL cihazı bulunamadı. Cihazın AP modunda olduğundan emin olun.';
      }
    });
  }

  // ─── Adım 0 → 1: Cihaz seç ───────────────────────────────────────────────

  void _selectAp(_ScannedAp ap) {
    setState(() {
      _selectedAp = ap;
      _error = null;
      _success = false;
      _step = 1;
    });
  }

  // ─── Adım 1 → 2: Gönder ──────────────────────────────────────────────────

  Future<void> _sendProvisioning() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isSending = true; _error = null; _step = 2; });

    try {
      await ProvisioningService.real.provision(ProvisioningRequest(
        wifiSsid: _ssidCtrl.text.trim(),
        wifiPassword: _passwordCtrl.text,
      ));
      if (!mounted) return;
      setState(() { _isSending = false; _success = true; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _isSending = false; _error = e.toString(); });
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('WiFi Provisioning', style: AppTextStyles.headingSmall),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 20.r),
          onPressed: () {
            if (_step > 0 && !_isSending && !_success) {
              setState(() { _step -= 1; _error = null; });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 8.h),
              _StepIndicator(currentStep: _step),
              SizedBox(height: 24.h),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(anim),
                      child: child,
                    ),
                  ),
                  child: switch (_step) {
                    0 => _Step0Scan(
                        key: const ValueKey(0),
                        isScanning: _isScanning,
                        scanError: _scanError,
                        networks: _networks,
                        isIos: _isIos,
                        manualSsidCtrl: _manualSsidCtrl,
                        onScan: _startScan,
                        onSelect: _selectAp,
                      ),
                    1 => _Step1WifiForm(
                        key: const ValueKey(1),
                        selectedSsid: _selectedAp?.ssid ?? '',
                        formKey: _formKey,
                        ssidCtrl: _ssidCtrl,
                        passwordCtrl: _passwordCtrl,
                        onSend: _sendProvisioning,
                      ),
                    _ => _Step2Result(
                        key: const ValueKey(2),
                        isSending: _isSending,
                        success: _success,
                        error: _error,
                        deviceSsid: _selectedAp?.ssid ?? '',
                        onDone: () => Navigator.of(context).pop(),
                        onRetry: () => setState(() { _step = 1; _error = null; _success = false; }),
                      ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Adım Göstergesi ─────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});
  final int currentStep;

  static const _labels = ['Cihaz Tara', 'WiFi Gir', 'Gönder'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length, (i) {
        final done   = i < currentStep;
        final active = i == currentStep;
        return Expanded(
          child: Row(
            children: [
              if (i > 0)
                Expanded(child: Container(height: 2.h, color: i <= currentStep ? AppColors.primary : AppColors.border)),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 26.r, height: 26.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? AppColors.primary : active ? AppColors.primaryGlow : AppColors.surface,
                      border: Border.all(color: done || active ? AppColors.primary : AppColors.border, width: 1.5),
                    ),
                    child: Center(
                      child: done
                          ? Icon(Icons.check_rounded, color: Colors.white, size: 13.r)
                          : Text('${i + 1}', style: AppTextStyles.labelSmall.copyWith(
                              color: active ? AppColors.primary : AppColors.textDisabled, fontSize: 10.sp)),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(_labels[i], style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 9.sp,
                    color: active || done ? AppColors.primary : AppColors.textDisabled,
                  )),
                ],
              ),
              if (i < _labels.length - 1)
                Expanded(child: Container(height: 2.h, color: i < currentStep ? AppColors.primary : AppColors.border)),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Adım 0: Tara + Listele ───────────────────────────────────────────────────

class _Step0Scan extends StatelessWidget {
  const _Step0Scan({
    super.key,
    required this.isScanning,
    required this.scanError,
    required this.networks,
    required this.isIos,
    required this.manualSsidCtrl,
    required this.onScan,
    required this.onSelect,
  });

  final bool isScanning;
  final String? scanError;
  final List<_ScannedAp> networks;
  final bool isIos;
  final TextEditingController manualSsidCtrl;
  final VoidCallback onScan;
  final void Function(_ScannedAp) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 60.r, height: 60.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Icon(Icons.wifi_find_rounded, color: AppColors.primary, size: 30.r),
              ),
              SizedBox(height: 14.h),
              Text('KABEL Cihazını Bul', style: AppTextStyles.headingSmall),
              SizedBox(height: 8.h),
              Text(
                isIos
                    ? 'Önce telefonunuzu KABEL cihazının WiFi ağına bağlayın,\nardından SSID\'yi girin.'
                    : 'Yakındaki KABEL cihazlarını tarayın.\nCihaz AP modunda "KABEL_XXXX" yayını yapıyor olmalı.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0),

        SizedBox(height: 12.h),

        if (isIos) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: manualSsidCtrl,
              style: AppTextStyles.mono.copyWith(fontSize: 14.sp),
              decoration: InputDecoration(
                labelText: 'KABEL Cihaz SSID',
                labelStyle: AppTextStyles.labelSmall,
                hintText: 'KABEL_XXXX',
                hintStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled),
                prefixIcon: Icon(Icons.wifi_rounded, color: AppColors.primary, size: 18.r),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],

        if (scanError != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: AppColors.error, size: 16.r),
                SizedBox(width: 8.w),
                Expanded(child: Text(scanError!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.error))),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],

        if (networks.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              'BULUNAN KABEL CİHAZLARI (${networks.length})',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled, letterSpacing: 1.1),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: networks.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, i) {
                final ap  = networks[i];
                final sig = _signalQuality(ap.level);
                return GestureDetector(
                  onTap: () => onSelect(ap),
                  child: Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_rounded, color: sig.color, size: 26.r),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ap.ssid, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                              Text('Sinyal: ${ap.level} dBm  •  ${sig.label}', style: AppTextStyles.labelSmall),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textDisabled, size: 14.r),
                      ],
                    ),
                  ).animate().fadeIn(duration: 250.ms, delay: Duration(milliseconds: i * 40)),
                );
              },
            ),
          ),
        ] else
          const Spacer(),

        KabelButton(
          label: isIos ? 'Devam Et' : isScanning ? 'Taranıyor...' : 'WiFi Ağlarını Tara',
          onPressed: isScanning ? null : onScan,
          icon: isIos ? Icons.arrow_forward_rounded : (isScanning ? null : Icons.radar_rounded),
          isLoading: isScanning,
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  static ({Color color, String label}) _signalQuality(int rssi) {
    if (rssi >= -50) return (color: AppColors.success, label: 'Mükemmel');
    if (rssi >= -65) return (color: AppColors.success, label: 'İyi');
    if (rssi >= -75) return (color: AppColors.warning, label: 'Orta');
    return (color: AppColors.error, label: 'Zayıf');
  }
}

// ─── Adım 1: WiFi Bilgisi ────────────────────────────────────────────────────

class _Step1WifiForm extends StatelessWidget {
  const _Step1WifiForm({
    super.key,
    required this.selectedSsid,
    required this.formKey,
    required this.ssidCtrl,
    required this.passwordCtrl,
    required this.onSend,
  });

  final String selectedSsid;
  final GlobalKey<FormState> formKey;
  final TextEditingController ssidCtrl;
  final TextEditingController passwordCtrl;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.developer_board_rounded, color: AppColors.primary, size: 22.r),
                SizedBox(width: 10.w),
                Text(selectedSsid, style: AppTextStyles.mono.copyWith(fontSize: 13.sp)),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          SizedBox(height: 12.h),

          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 16.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Telefonunuz şu an "$selectedSsid" ağına bağlı olmalı.',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),

          SizedBox(height: 20.h),

          Text(
            'ESP32\'YE GÖNDERİLECEK AĞ BİLGİLERİ',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled, letterSpacing: 1.1),
          ),
          SizedBox(height: 8.h),

          KabelTextField(
            label: 'WiFi Ağ Adı (SSID)',
            hint: 'İnternete bağlanılacak ağ',
            controller: ssidCtrl,
            prefixIcon: Icons.wifi_rounded,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'SSID gerekli' : null,
          ),
          SizedBox(height: 12.h),
          KabelTextField(
            label: 'WiFi Şifresi',
            controller: passwordCtrl,
            prefixIcon: Icons.lock_outline,
            isObscure: true,
            validator: (v) => (v == null || v.isEmpty) ? 'Şifre gerekli' : null,
          ),

          const Spacer(),

          KabelButton(
            label: 'ESP32\'ye Gönder',
            onPressed: onSend,
            icon: Icons.send_rounded,
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

// ─── Adım 2: Sonuç ───────────────────────────────────────────────────────────

class _Step2Result extends StatelessWidget {
  const _Step2Result({
    super.key,
    required this.isSending,
    required this.success,
    required this.error,
    required this.deviceSsid,
    required this.onDone,
    required this.onRetry,
  });

  final bool isSending;
  final bool success;
  final String? error;
  final String deviceSsid;
  final VoidCallback onDone;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isSending) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 72.r, height: 72.r,
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            SizedBox(height: 24.h),
            Text('Gönderiliyor...', style: AppTextStyles.headingSmall),
            SizedBox(height: 8.h),
            Text(
              'ESP32 WiFi bilgilerini alıyor ve yeniden başlatılıyor.\nBağlantı kesilirse bu normaldir.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r, height: 72.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.error, width: 1.5),
              ),
              child: Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 36.r),
            ),
            SizedBox(height: 20.h),
            Text('Hata', style: AppTextStyles.headingSmall.copyWith(color: AppColors.error)),
            SizedBox(height: 10.h),
            Text(error!, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Bağlantı kesilmesi normaldir — ESP32 ağa geçiyor olabilir.\nCihaz listesini 1-2 dakika sonra yenileyin.',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24.h),
            KabelButton(label: 'Tekrar Dene', onPressed: onRetry, icon: Icons.refresh_rounded),
            SizedBox(height: 8.h),
            TextButton(onPressed: onDone, child: const Text('Geri Dön')),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88.r, height: 88.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.withValues(alpha: 0.12),
            border: Border.all(color: AppColors.success, width: 2),
          ),
          child: Icon(Icons.check_rounded, color: AppColors.success, size: 48.r),
        ).animate().scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 400.ms, curve: Curves.elasticOut),
        SizedBox(height: 28.h),
        Text('Provisioning Tamamlandı!',
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.success))
            .animate().fadeIn(delay: 200.ms),
        SizedBox(height: 8.h),
        Text(
          'ESP32 internete bağlanıyor.\nBir dakika içinde cihaz listesinde aktif görünecek.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.developer_board_rounded, color: AppColors.primary, size: 16.r),
              SizedBox(width: 8.w),
              Text(deviceSsid, style: AppTextStyles.mono.copyWith(fontSize: 12.sp)),
            ],
          ),
        ).animate().fadeIn(delay: 350.ms),
        const Spacer(),
        KabelButton(label: 'Cihazlara Dön', onPressed: onDone, icon: Icons.arrow_back_rounded)
            .animate().fadeIn(delay: 500.ms),
        SizedBox(height: 8.h),
      ],
    );
  }
}
