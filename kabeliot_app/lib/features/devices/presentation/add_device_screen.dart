import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import '../../../core/firebase/company_repository.dart';
import '../../../core/firebase/device_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/thingsboard/tb_api_client.dart';
import '../../../core/thingsboard/tb_auth_provider.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/kabel_button.dart';
import '../../../shared/widgets/kabel_text_field.dart';

// KABEL ESP32 AP SSID prefix — KABEL_ veya KABEL- ile başlayan ağlar listelenir
const _kabelPrefix = 'KABEL';

/// wifi_scan'dan bağımsız basit AP bilgisi
class _KabelApInfo {
  const _KabelApInfo({required this.ssid, required this.level});
  final String ssid;
  final int level; // dBm (RSSI)
}

class AddDeviceScreen extends ConsumerStatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  ConsumerState<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends ConsumerState<AddDeviceScreen> {
  // Adım: 0=Tara, 1=Cihaz Seç, 2=Kaydet
  int _step = 0;

  bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  // Adım 0 — WiFi tarama
  bool _isScanning = false;
  String? _scanError;
  List<_KabelApInfo> _kabelNetworks = [];

  // iOS manuel SSID girişi
  final _manualSsidCtrl = TextEditingController(text: 'KABEL_');

  // Seçilen AP
  _KabelApInfo? _selectedAp;

  // Adım 2 — Cihaz adı + kaydetme
  final _formKey = GlobalKey<FormState>();
  final _deviceNameCtrl = TextEditingController();
  bool _isSaving = false;
  bool _saveSuccess = false;
  String? _saveError;

  @override
  void dispose() {
    _manualSsidCtrl.dispose();
    _deviceNameCtrl.dispose();
    super.dispose();
  }

  /// SSID'den Firestore doc ID'si: tire → alt çizgi (KABEL-XX → KABEL_XX)
  String _deviceIdFromSsid(String ssid) => ssid.replaceAll('-', '_');

  // ─── Adım 0: WiFi Tara ───────────────────────────────────────────────────

  void _connectManualIos() {
    final ssid = _manualSsidCtrl.text.trim();
    if (ssid.isEmpty) return;
    _selectDevice(_KabelApInfo(ssid: ssid, level: -60));
  }

  Future<void> _startScan() async {
    if (_isIos) {
      _connectManualIos();
      return;
    }

    setState(() {
      _isScanning = true;
      _scanError = null;
      _kabelNetworks = [];
    });

    final locStatus = await Permission.locationWhenInUse.request();
    if (!locStatus.isGranted) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _scanError =
            'Konum izni gerekli. WiFi taraması yapılamıyor.\nAyarlar → Uygulama → Konum → İzin Ver';
      });
      return;
    }

    final canScan = await WiFiScan.instance.canStartScan(askPermissions: true);
    if (canScan != CanStartScan.yes) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _scanError =
            'WiFi taraması başlatılamadı.\nKonum ve WiFi servislerinin açık olduğundan emin olun.';
      });
      return;
    }

    await WiFiScan.instance.startScan();

    final canGet =
        await WiFiScan.instance.canGetScannedResults(askPermissions: true);
    if (canGet != CanGetScannedResults.yes) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _scanError = 'Tarama sonuçları alınamadı.';
      });
      return;
    }

    final results = await WiFiScan.instance.getScannedResults();
    final kabelNets = results
        .where((ap) =>
            ap.ssid.toUpperCase().startsWith(_kabelPrefix.toUpperCase()))
        .map((ap) => _KabelApInfo(ssid: ap.ssid, level: ap.level))
        .toList()
      ..sort((a, b) => b.level.compareTo(a.level));

    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _kabelNetworks = kabelNets;
      if (kabelNets.isEmpty) {
        _scanError =
            'Yakında KABEL cihazı bulunamadı. Cihazın açık olduğundan emin olun.';
      } else {
        _step = 1;
      }
    });
  }

  // ─── Adım 1 → 2: Cihaz seç ──────────────────────────────────────────────

  void _selectDevice(_KabelApInfo ap) {
    _deviceNameCtrl.text = _deviceIdFromSsid(ap.ssid);
    setState(() {
      _selectedAp = ap;
      _saveSuccess = false;
      _saveError = null;
      _step = 2;
    });
  }

  // ─── Adım 2: Firestore'a kaydet ─────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final session = ref.read(authStateProvider);
    if (session == null) {
      setState(() => _saveError = 'Oturum bulunamadı. Lütfen tekrar giriş yapın.');
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      final deviceId   = _deviceIdFromSsid(_selectedAp!.ssid);
      final deviceName = _deviceNameCtrl.text.trim();

      // ── 1. Firestore'a kaydet ──────────────────────────────────────────
      await DeviceRepository().addDevice(
        session.companyId,
        deviceId,
        deviceName,
      );

      // ── 2. ThingsBoard — customer altına cihaz ekle ────────────────────
      // Her kayıt işleminde taze JWT al (token expire olmuş olabilir)
      await ref.read(tbAuthProvider.notifier).reconnect();
      final tbToken = await ref.read(tbAuthProvider.future);
      final tbClient = TbApiClient(baseUrl: tbBaseUrl, jwtToken: tbToken!);

      final companyEmail = await CompanyRepository().getCompanyEmail(session.companyId);
      if (companyEmail == null) {
        throw Exception('Firestore\'da şirkete ait e-posta adresi bulunamadı.');
      }

      // Customer bul
      final customerId = await tbClient.getCustomerIdByEmail(companyEmail);
      if (customerId == null) {
        throw Exception(
          'ThingsBoard\'da "$companyEmail" e-postasına sahip customer bulunamadı.\n'
          'ThingsBoard → Customers bölümünde e-posta adresini kontrol edin.',
        );
      }

      // Cihaz oluştur → device ID
      final tbDevice    = await tbClient.createDevice(deviceName, customerId: customerId);
      final tbDeviceId  = tbDevice.id;

      // Cihaz MQTT token
      final creds          = await tbClient.getDeviceCredentials(tbDeviceId);
      final tbAccessToken  = creds.credentialsId;

      // Customer JWT token
      String? tbCustomerToken;
      final userId = await tbClient.getCustomerUserId(customerId);
      if (userId != null) {
        tbCustomerToken = await tbClient.getUserToken(userId);
      }

      // ── 3. Firestore'u TB bilgileriyle güncelle ─────────────────────────
      await DeviceRepository().addDevice(
        session.companyId,
        deviceId,
        deviceName,
        tbDeviceId: tbDeviceId,
        tbAccessToken: tbAccessToken,
        tbCustomerToken: tbCustomerToken,
      );

      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveSuccess = true;
      });
    } on DeviceAlreadyExistsException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24.r),
              SizedBox(width: 10.w),
              const Text('Cihaz Zaten Kayıtlı'),
            ],
          ),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Tamam', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError = e.toString();
      });
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Yeni Cihaz Ekle', style: AppTextStyles.headingSmall),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 20.r),
          onPressed: () {
            if (_step > 0 && !_isSaving && !_saveSuccess) {
              setState(() => _step -= 1);
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
                      position: Tween(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: switch (_step) {
                    0 => _Step0Scan(
                        key: const ValueKey(0),
                        isScanning: _isScanning,
                        error: _scanError,
                        isIos: _isIos,
                        manualSsidCtrl: _manualSsidCtrl,
                        onScan: _startScan,
                      ),
                    1 => _Step1Select(
                        key: const ValueKey(1),
                        networks: _kabelNetworks,
                        onSelect: _selectDevice,
                      ),
                    _ => _Step2Save(
                        key: const ValueKey(2),
                        formKey: _formKey,
                        selectedAp: _selectedAp,
                        deviceNameCtrl: _deviceNameCtrl,
                        isSaving: _isSaving,
                        saveSuccess: _saveSuccess,
                        saveError: _saveError,
                        onSave: _save,
                        onDone: () => Navigator.of(context).pop(),
                        onRetry: () => setState(() {
                          _saveError = null;
                          _saveSuccess = false;
                        }),
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

  static const _labels = ['WiFi Tara', 'Cihaz Seç', 'Kaydet'];

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
                Expanded(
                  child: Container(
                    height: 2.h,
                    color: i <= currentStep ? AppColors.primary : AppColors.border,
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 26.r,
                    height: 26.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? AppColors.primary
                          : active
                              ? AppColors.primaryGlow
                              : AppColors.surface,
                      border: Border.all(
                        color: done || active ? AppColors.primary : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: done
                          ? Icon(Icons.check_rounded,
                              color: Colors.white, size: 13.r)
                          : Text(
                              '${i + 1}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: active
                                    ? AppColors.primary
                                    : AppColors.textDisabled,
                                fontSize: 10.sp,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _labels[i],
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 9.sp,
                      color: active || done
                          ? AppColors.primary
                          : AppColors.textDisabled,
                    ),
                  ),
                ],
              ),
              if (i < _labels.length - 1)
                Expanded(
                  child: Container(
                    height: 2.h,
                    color: i < currentStep ? AppColors.primary : AppColors.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Adım 0: WiFi Tara ───────────────────────────────────────────────────────

class _Step0Scan extends StatelessWidget {
  const _Step0Scan({
    super.key,
    required this.isScanning,
    required this.error,
    required this.isIos,
    required this.manualSsidCtrl,
    required this.onScan,
  });

  final bool isScanning;
  final String? error;
  final bool isIos;
  final TextEditingController manualSsidCtrl;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoCard(
          icon: Icons.wifi_find_rounded,
          iconColor: AppColors.primary,
          title: 'KABEL Cihazı Bul',
          body: isIos
              ? 'iOS\'ta otomatik tarama desteklenmez.\n\n'
                'Cihazın SSID\'sini aşağıya girin\n'
                '(örn: KABEL_A846749FFC68)'
              : 'Yakındaki KABEL cihazlarını taramak için butona basın.\n\n'
                '• Cihazın güce takılı olduğundan emin olun\n'
                '• Konum servisi açık olmalı',
        ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0),

        SizedBox(height: 16.h),

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
                hintStyle: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textDisabled),
                prefixIcon:
                    Icon(Icons.wifi_rounded, color: AppColors.primary, size: 18.r),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],

        if (error != null) _ErrorBanner(message: error!),

        const Spacer(),

        KabelButton(
          label: isIos
              ? 'Ekle'
              : isScanning
                  ? 'Taranıyor...'
                  : 'WiFi Ağlarını Tara',
          onPressed: isScanning ? null : onScan,
          icon: isIos ? Icons.add_rounded : (isScanning ? null : Icons.radar_rounded),
          isLoading: isScanning,
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

// ─── Adım 1: Cihaz Seç ───────────────────────────────────────────────────────

class _Step1Select extends StatelessWidget {
  const _Step1Select({
    super.key,
    required this.networks,
    required this.onSelect,
  });

  final List<_KabelApInfo> networks;
  final void Function(_KabelApInfo) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoCard(
          icon: Icons.developer_board_rounded,
          iconColor: AppColors.accent,
          title: 'Cihaz Seçin',
          body: 'Eklemek istediğiniz KABEL cihazına dokunun.\nCihaz anında sisteme kaydedilecektir.',
        ).animate().fadeIn(duration: 300.ms),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Text(
            'BULUNAN KABEL CİHAZLARI (${networks.length})',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textDisabled,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Expanded(
          child: _NetworkList(networks: networks, onSelect: onSelect),
        ),
      ],
    );
  }
}

// ─── Adım 2: Ad Gir + Kaydet ─────────────────────────────────────────────────

class _Step2Save extends StatelessWidget {
  const _Step2Save({
    super.key,
    required this.formKey,
    required this.selectedAp,
    required this.deviceNameCtrl,
    required this.isSaving,
    required this.saveSuccess,
    required this.saveError,
    required this.onSave,
    required this.onDone,
    required this.onRetry,
  });

  final GlobalKey<FormState> formKey;
  final _KabelApInfo? selectedAp;
  final TextEditingController deviceNameCtrl;
  final bool isSaving;
  final bool saveSuccess;
  final String? saveError;
  final VoidCallback onSave;
  final VoidCallback onDone;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isSaving) {
      return const _LoadingView(
        message: 'Kaydediliyor...',
        subtitle: 'Cihaz sisteme ekleniyor.',
      );
    }

    if (saveSuccess) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88.r,
            height: 88.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.success, width: 2),
            ),
            child:
                Icon(Icons.check_rounded, color: AppColors.success, size: 48.r),
          )
              .animate()
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),
          SizedBox(height: 28.h),
          Text(
            'Cihaz Eklendi!',
            style:
                AppTextStyles.headingMedium.copyWith(color: AppColors.success),
          ).animate().fadeIn(delay: 200.ms),
          SizedBox(height: 8.h),
          Text(
            '"${deviceNameCtrl.text}" sisteme kaydedildi.',
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
                Icon(Icons.wifi_rounded, color: AppColors.primary, size: 16.r),
                SizedBox(width: 8.w),
                Text(
                  selectedAp?.ssid ?? '',
                  style: AppTextStyles.mono.copyWith(fontSize: 12.sp),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 350.ms),
          const Spacer(),
          KabelButton(
            label: 'Cihazlara Dön',
            onPressed: onDone,
            icon: Icons.arrow_back_rounded,
          ).animate().fadeIn(delay: 500.ms),
          SizedBox(height: 8.h),
        ],
      );
    }

    // Form
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seçilen cihaz bilgisi
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.developer_board_rounded,
                    color: AppColors.primary, size: 22.r),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedAp?.ssid ?? '',
                        style: AppTextStyles.mono.copyWith(fontSize: 13.sp),
                      ),
                      Text(
                        'Sinyal: ${selectedAp?.level ?? 0} dBm',
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          SizedBox(height: 20.h),

          Text(
            'CİHAZ ADI',
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textDisabled, letterSpacing: 1.1),
          ),
          SizedBox(height: 8.h),
          KabelTextField(
            label: 'Cihaz Adı',
            hint: 'örn: Üretim Hattı PCB-1',
            controller: deviceNameCtrl,
            prefixIcon: Icons.label_outline,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Cihaz adı gerekli' : null,
          ),

          if (saveError != null) ...[
            SizedBox(height: 12.h),
            _ErrorBanner(message: saveError!),
          ],

          const Spacer(),

          KabelButton(
            label: 'Sisteme Kaydet',
            onPressed: onSave,
            icon: Icons.cloud_upload_rounded,
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

// ─── Yardımcı Widgetlar ───────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.12),
              border:
                  Border.all(color: iconColor.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Icon(icon, color: iconColor, size: 30.r),
          ),
          SizedBox(height: 14.h),
          Text(title, style: AppTextStyles.headingSmall),
          SizedBox(height: 8.h),
          Text(body,
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _NetworkList extends StatelessWidget {
  const _NetworkList({required this.networks, required this.onSelect});
  final List<_KabelApInfo> networks;
  final void Function(_KabelApInfo) onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
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
                      Text(
                        ap.ssid,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Sinyal: ${ap.level} dBm  •  ${sig.label}',
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: AppColors.textDisabled, size: 14.r),
              ],
            ),
          ).animate().fadeIn(
                duration: 250.ms,
                delay: Duration(milliseconds: i * 40),
              ),
        );
      },
    );
  }

  static ({Color color, String label}) _signalQuality(int rssi) {
    if (rssi >= -50) return (color: AppColors.success, label: 'Mükemmel');
    if (rssi >= -65) return (color: AppColors.success, label: 'İyi');
    if (rssi >= -75) return (color: AppColors.warning, label: 'Orta');
    return (color: AppColors.error, label: 'Zayıf');
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.message, required this.subtitle});
  final String message;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 72.r,
            height: 72.r,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          SizedBox(height: 24.h),
          Text(message, style: AppTextStyles.headingSmall),
          SizedBox(height: 8.h),
          Text(subtitle,
              style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
