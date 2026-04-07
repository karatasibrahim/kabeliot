import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/kabel_button.dart';
import '../../../shared/widgets/kabel_text_field.dart';
import '../data/provisioning_service.dart';

// KABEL ESP32 AP SSID prefix — firmware ile eşleşmeli
const _kabelPrefix = 'KABEL-';
// ESP32 AP modundaki fabrika WiFi şifresi
const _esp32ApPassword = 'kabel2024!';
// MQTT sunucu varsayılanları
const _defaultMqttHost = 'mqtt.kabelteknoloji.com';
const _defaultMqttPort = 1883;

/// wifi_scan'dan bağımsız basit AP bilgisi — mock ve gerçek için ortak model
class _KabelApInfo {
  const _KabelApInfo({required this.ssid, required this.level});
  final String ssid;
  final int level; // dBm (RSSI)
}

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  // Adım: 0=Tara, 1=Cihaz Seç, 2=Konfig Gir, 3=Provision Sonucu
  int _step = 0;

  // Adım 0 — WiFi tarama
  bool _isScanning = false;
  String? _scanError;
  List<_KabelApInfo> _kabelNetworks = [];

  // Seçilen AP
  _KabelApInfo? _selectedAp;

  // Adım 2 — ESP32'den çekilen cihaz bilgisi
  Esp32DeviceInfo? _deviceInfo;
  bool _fetchingInfo = false;
  String? _infoError;

  // Form
  final _formKey = GlobalKey<FormState>();
  final _deviceNameCtrl = TextEditingController();
  final _factorySsidCtrl = TextEditingController();
  final _factoryPassCtrl = TextEditingController();
  final _mqttHostCtrl = TextEditingController(text: _defaultMqttHost);
  final _mqttPortCtrl = TextEditingController(text: '$_defaultMqttPort');
  final _mqttUserCtrl = TextEditingController();
  final _mqttPassCtrl = TextEditingController();
  bool _showMqttAdvanced = false;

  // Adım 3 — Provision
  bool _isProvisioning = false;
  bool _provisionSuccess = false;
  String? _provisionError;

  // Demo/test modu — gerçek cihaz olmadan test
  bool _mockMode = false;

  @override
  void dispose() {
    _deviceNameCtrl.dispose();
    _factorySsidCtrl.dispose();
    _factoryPassCtrl.dispose();
    _mqttHostCtrl.dispose();
    _mqttPortCtrl.dispose();
    _mqttUserCtrl.dispose();
    _mqttPassCtrl.dispose();
    super.dispose();
  }

  // ─── Adım 0: WiFi Tara ───────────────────────────────────────────────────

  Future<void> _startScan() async {
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
        _scanError = 'Konum izni gerekli. WiFi taraması yapılamıyor.\nAyarlar → Uygulama → Konum → İzin Ver';
      });
      return;
    }

    final canScan = await WiFiScan.instance.canStartScan(askPermissions: true);
    if (canScan != CanStartScan.yes) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _scanError = 'WiFi taraması başlatılamadı.\nKonum ve WiFi servislerinin açık olduğundan emin olun.';
      });
      return;
    }

    await WiFiScan.instance.startScan();

    final canGet = await WiFiScan.instance.canGetScannedResults(askPermissions: true);
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
        .where((ap) => ap.ssid.toUpperCase().startsWith(_kabelPrefix.toUpperCase()))
        .map((ap) => _KabelApInfo(ssid: ap.ssid, level: ap.level))
        .toList()
      ..sort((a, b) => b.level.compareTo(a.level));

    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _kabelNetworks = kabelNets;
      if (kabelNets.isEmpty) {
        _scanError = 'Yakında KABEL cihazı bulunamadı. Cihazın AP modunda olduğundan emin olun.';
      } else {
        _step = 1; // Sonuçlar varsa otomatik sonraki adıma geç
      }
    });
  }

  // ─── Adım 1 → 2: Seç + /info çek ────────────────────────────────────────

  Future<void> _selectAndConnect(_KabelApInfo ap) async {
    setState(() {
      _selectedAp = ap;
      _fetchingInfo = true;
      _infoError = null;
      _step = 2;
    });

    // Gerçek uygulamada kullanıcı Ayarlar→WiFi'den bağlanır
    // veya WifiConfiguration API kullanılır (Android 10+ kısıtlı).
    // 2 sn bekleme: kullanıcının bağlantı kurması için.
    await Future.delayed(const Duration(seconds: 2));

    try {
      final service = _mockMode ? ProvisioningService.mock : ProvisioningService.real;
      final info = await service.fetchDeviceInfo();
      if (!mounted) return;

      // Cihaz adı önerisi
      final suffix = ap.ssid.length > _kabelPrefix.length
          ? ap.ssid.substring(_kabelPrefix.length)
          : ap.ssid;
      _deviceNameCtrl.text = 'KABEL-$suffix';

      setState(() {
        _deviceInfo = info;
        _fetchingInfo = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _fetchingInfo = false;
        _infoError = e.toString();
      });
    }
  }

  // ─── Adım 2 → 3: Provision ──────────────────────────────────────────────

  Future<void> _provision() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _step = 3;
      _isProvisioning = true;
      _provisionError = null;
      _provisionSuccess = false;
    });

    try {
      final service = _mockMode ? ProvisioningService.mock : ProvisioningService.real;
      await service.provision(ProvisioningRequest(
        deviceName: _deviceNameCtrl.text.trim(),
        wifiSsid: _factorySsidCtrl.text.trim(),
        wifiPassword: _factoryPassCtrl.text,
        mqttHost: _mqttHostCtrl.text.trim(),
        mqttPort: int.tryParse(_mqttPortCtrl.text.trim()) ?? _defaultMqttPort,
        mqttUser: _mqttUserCtrl.text.trim(),
        mqttPassword: _mqttPassCtrl.text,
      ));

      if (!mounted) return;
      setState(() {
        _isProvisioning = false;
        _provisionSuccess = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProvisioning = false;
        _provisionError = e.toString();
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
            if (_step > 0 && !_isProvisioning && !_provisionSuccess) {
              setState(() => _step = _step > 2 ? 2 : _step - 1);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          Tooltip(
            message: _mockMode ? 'Demo Mod (Aktif)' : 'Demo Mod',
            child: IconButton(
              icon: Icon(
                Icons.science_rounded,
                color: _mockMode ? AppColors.warning : AppColors.textDisabled,
                size: 20.r,
              ),
              onPressed: () => setState(() => _mockMode = !_mockMode),
            ),
          ),
          SizedBox(width: 8.w),
        ],
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
                        mockMode: _mockMode,
                        onScan: _startScan,
                        onMockSelect: () => _selectAndConnect(
                          const _KabelApInfo(ssid: 'KABEL-DEMO-A2F3', level: -52),
                        ),
                      ),
                    1 => _Step1Select(
                        key: const ValueKey(1),
                        networks: _kabelNetworks,
                        onSelect: _selectAndConnect,
                      ),
                    2 => _Step2Config(
                        key: const ValueKey(2),
                        formKey: _formKey,
                        selectedAp: _selectedAp,
                        deviceInfo: _deviceInfo,
                        fetchingInfo: _fetchingInfo,
                        infoError: _infoError,
                        deviceNameCtrl: _deviceNameCtrl,
                        factorySsidCtrl: _factorySsidCtrl,
                        factoryPassCtrl: _factoryPassCtrl,
                        mqttHostCtrl: _mqttHostCtrl,
                        mqttPortCtrl: _mqttPortCtrl,
                        mqttUserCtrl: _mqttUserCtrl,
                        mqttPassCtrl: _mqttPassCtrl,
                        showMqttAdvanced: _showMqttAdvanced,
                        onToggleAdvanced: () =>
                            setState(() => _showMqttAdvanced = !_showMqttAdvanced),
                        onProvision: _provision,
                        onRetry: _selectedAp != null
                            ? () => _selectAndConnect(_selectedAp!)
                            : null,
                      ),
                    _ => _Step3Result(
                        key: const ValueKey(3),
                        isProvisioning: _isProvisioning,
                        success: _provisionSuccess,
                        error: _provisionError,
                        deviceName: _deviceNameCtrl.text,
                        mqttHost: _mqttHostCtrl.text,
                        onDone: () => Navigator.of(context).pop(),
                        onRetry: () => setState(() {
                          _step = 2;
                          _provisionError = null;
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

  static const _labels = ['WiFi Tara', 'Cihaz Seç', 'Yapılandır', 'Tamamla'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length, (i) {
        final done = i < currentStep;
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
                          ? Icon(Icons.check_rounded, color: Colors.white, size: 13.r)
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
    required this.mockMode,
    required this.onScan,
    required this.onMockSelect,
  });

  final bool isScanning;
  final String? error;
  final bool mockMode;
  final VoidCallback onScan;
  final VoidCallback onMockSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoCard(
          icon: Icons.wifi_find_rounded,
          iconColor: AppColors.primary,
          title: 'KABEL Cihazı Ara',
          body: mockMode
              ? 'Demo mod aktif.\nGerçek WiFi taraması yapılmaz — simüle edilmiş cihazla test edebilirsiniz.'
              : 'ESP32 kartı AP modunda "KABEL-XXXX" adında WiFi yayınlar.\n\n'
                  '• Kartı güce takın\n'
                  '• BOOT + EN tuşlarına aynı anda 3 sn basın\n'
                  '• LED hızlı yanıp sönünce hazır',
        ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0),

        SizedBox(height: 16.h),

        if (error != null) _ErrorBanner(message: error!),

        const Spacer(),

        if (mockMode)
          KabelButton(
            label: 'Demo Cihazla Test Et',
            onPressed: onMockSelect,
            icon: Icons.science_rounded,
          )
        else
          KabelButton(
            label: isScanning ? 'Taranıyor...' : 'WiFi Ağlarını Tara',
            onPressed: isScanning ? null : onScan,
            icon: isScanning ? null : Icons.radar_rounded,
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
  final Future<void> Function(_KabelApInfo) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoCard(
          icon: Icons.developer_board_rounded,
          iconColor: AppColors.accent,
          title: 'Cihaz Seçin',
          body: 'Listeden eklemek istediğiniz KABEL cihazını seçin.\n'
              'Telefon otomatik olarak o cihaza bağlanacak.\n'
              'AP şifresi: $_esp32ApPassword',
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

// ─── Adım 2: Yapılandırma ────────────────────────────────────────────────────

class _Step2Config extends StatelessWidget {
  const _Step2Config({
    super.key,
    required this.formKey,
    required this.selectedAp,
    required this.deviceInfo,
    required this.fetchingInfo,
    required this.infoError,
    required this.deviceNameCtrl,
    required this.factorySsidCtrl,
    required this.factoryPassCtrl,
    required this.mqttHostCtrl,
    required this.mqttPortCtrl,
    required this.mqttUserCtrl,
    required this.mqttPassCtrl,
    required this.showMqttAdvanced,
    required this.onToggleAdvanced,
    required this.onProvision,
    required this.onRetry,
  });

  final GlobalKey<FormState> formKey;
  final _KabelApInfo? selectedAp;
  final Esp32DeviceInfo? deviceInfo;
  final bool fetchingInfo;
  final String? infoError;
  final TextEditingController deviceNameCtrl;
  final TextEditingController factorySsidCtrl;
  final TextEditingController factoryPassCtrl;
  final TextEditingController mqttHostCtrl;
  final TextEditingController mqttPortCtrl;
  final TextEditingController mqttUserCtrl;
  final TextEditingController mqttPassCtrl;
  final bool showMqttAdvanced;
  final VoidCallback onToggleAdvanced;
  final VoidCallback onProvision;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (fetchingInfo) {
      return _LoadingView(
        message: 'ESP32\'ye Bağlanılıyor...',
        subtitle: 'Cihaz bilgileri alınıyor\n(${selectedAp?.ssid ?? ''})',
      );
    }

    if (infoError != null) {
      return _ErrorView(
        message: infoError!,
        hint: 'Telefonun "${selectedAp?.ssid ?? 'KABEL'}" WiFi\'ne bağlı olduğundan emin olun.\n'
            'Ayarlar → WiFi → ${selectedAp?.ssid ?? 'KABEL-XXXX'} → Bağlan',
        onRetry: onRetry,
      );
    }

    return Form(
      key: formKey,
      child: ListView(
        children: [
          if (deviceInfo != null) ...[
            _DeviceInfoSummary(info: deviceInfo!),
            SizedBox(height: 16.h),
          ],

          _SectionLabel('Cihaz Adı'),
          SizedBox(height: 8.h),
          KabelTextField(
            label: 'Cihaz Adı',
            hint: 'örn: PCB-Kontrol-01',
            controller: deviceNameCtrl,
            prefixIcon: Icons.label_outline,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Cihaz adı gerekli' : null,
          ),
          SizedBox(height: 20.h),

          _SectionLabel('Fabrika / İşletme WiFi Ağı'),
          SizedBox(height: 4.h),
          Text(
            'ESP32\'nin bağlanacağı asıl ağın bilgileri',
            style: AppTextStyles.labelSmall,
          ),
          SizedBox(height: 10.h),
          KabelTextField(
            label: 'WiFi Ağ Adı (SSID)',
            hint: 'Fabrika WiFi ağı',
            controller: factorySsidCtrl,
            prefixIcon: Icons.wifi_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'SSID gerekli' : null,
          ),
          SizedBox(height: 12.h),
          KabelTextField(
            label: 'WiFi Şifresi',
            controller: factoryPassCtrl,
            prefixIcon: Icons.lock_outline,
            isObscure: true,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Şifre gerekli' : null,
          ),
          SizedBox(height: 20.h),

          _SectionLabel('MQTT Sunucu'),
          SizedBox(height: 10.h),
          KabelTextField(
            label: 'MQTT Host',
            hint: _defaultMqttHost,
            controller: mqttHostCtrl,
            prefixIcon: Icons.dns_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'MQTT host gerekli' : null,
          ),
          SizedBox(height: 12.h),
          KabelTextField(
            label: 'Port',
            hint: '$_defaultMqttPort',
            controller: mqttPortCtrl,
            prefixIcon: Icons.numbers_rounded,
            keyboardType: TextInputType.number,
            validator: (v) {
              final p = int.tryParse(v ?? '');
              if (p == null || p < 1 || p > 65535) {
                return 'Geçerli port (1-65535)';
              }
              return null;
            },
          ),
          SizedBox(height: 8.h),

          GestureDetector(
            onTap: onToggleAdvanced,
            child: Row(
              children: [
                Icon(
                  showMqttAdvanced
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: AppColors.primary,
                  size: 18.r,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Gelişmiş MQTT (Kullanıcı / Şifre)',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          if (showMqttAdvanced) ...[
            SizedBox(height: 10.h),
            KabelTextField(
              label: 'MQTT Kullanıcı',
              controller: mqttUserCtrl,
              prefixIcon: Icons.person_outline_rounded,
            ),
            SizedBox(height: 12.h),
            KabelTextField(
              label: 'MQTT Şifre',
              controller: mqttPassCtrl,
              prefixIcon: Icons.vpn_key_rounded,
              isObscure: true,
            ),
          ],

          SizedBox(height: 28.h),
          KabelButton(
            label: 'Cihazı Yapılandır ve Bağla',
            onPressed: onProvision,
            icon: Icons.send_rounded,
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

// ─── Adım 3: Sonuç ───────────────────────────────────────────────────────────

class _Step3Result extends StatelessWidget {
  const _Step3Result({
    super.key,
    required this.isProvisioning,
    required this.success,
    required this.error,
    required this.deviceName,
    required this.mqttHost,
    required this.onDone,
    required this.onRetry,
  });

  final bool isProvisioning;
  final bool success;
  final String? error;
  final String deviceName;
  final String mqttHost;
  final VoidCallback onDone;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isProvisioning) {
      return const _LoadingView(
        message: 'Yapılandırma Gönderiliyor...',
        subtitle: 'ESP32 ağ bilgilerini alıyor ve yeniden başlatılıyor.\nBağlantı kesilirse bu normaldir.',
      );
    }

    if (error != null) {
      return _ErrorView(
        message: error!,
        hint: 'Provision sırasında bağlantı kesilmesi normaldir — '
            'ESP32 fabrika ağına geçiyor olabilir.\n'
            'Cihaz listesini 1-2 dakika sonra yenileyin.',
        onRetry: onRetry,
        retryLabel: 'Tekrar Dene',
        extraAction: TextButton(
          onPressed: onDone,
          child: const Text('Cihazlara Dön'),
        ),
      );
    }

    // Başarı
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
          child: Icon(Icons.check_rounded, color: AppColors.success, size: 48.r),
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
          'Cihaz Başarıyla Eklendi!',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.success),
        ).animate().fadeIn(delay: 200.ms),
        SizedBox(height: 8.h),
        Text(
          '"$deviceName" yapılandırıldı.\nFabrika WiFi\'ne bağlanıyor, MQTT\'ye kaydolacak.',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _MqttInfoRow(label: 'Sunucu', value: mqttHost),
              SizedBox(height: 6.h),
              _MqttInfoRow(
                label: 'Topic',
                value:
                    'kb/${deviceName.toLowerCase().replaceAll(' ', '_')}/#',
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.info, size: 16.r),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Cihaz 1-2 dakika içinde çevrimiçi görünecek. '
                  'Görünmezse kartı yeniden başlatın.',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.info),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms),
        const Spacer(),
        KabelButton(
          label: 'Cihazlara Dön',
          onPressed: onDone,
          icon: Icons.arrow_back_rounded,
        ).animate().fadeIn(delay: 600.ms),
        SizedBox(height: 8.h),
      ],
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
              border: Border.all(
                  color: iconColor.withValues(alpha: 0.4), width: 1.5),
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
  final Future<void> Function(_KabelApInfo) onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: networks.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, i) {
        final ap = networks[i];
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

class _DeviceInfoSummary extends StatelessWidget {
  const _DeviceInfoSummary({required this.info});
  final Esp32DeviceInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 16.r),
              SizedBox(width: 6.w),
              Text(
                'Cihaz Bağlantısı Başarılı',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.success),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _InfoChip(label: 'Model', value: info.model),
              SizedBox(width: 8.w),
              _InfoChip(label: 'FW', value: info.firmware),
              SizedBox(width: 8.w),
              _InfoChip(label: 'Sensör', value: '${info.sensorCount}'),
              SizedBox(width: 8.w),
              _InfoChip(label: 'Röle', value: '${info.relayCount}'),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text('MAC: ', style: AppTextStyles.labelSmall),
              Text(info.mac,
                  style: AppTextStyles.mono.copyWith(fontSize: 11.sp)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(label,
                style: AppTextStyles.labelSmall.copyWith(fontSize: 9.sp)),
            Text(
              value,
              style: AppTextStyles.mono
                  .copyWith(fontSize: 11.sp, color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: AppTextStyles.labelSmall
            .copyWith(color: AppColors.textDisabled, letterSpacing: 1.1),
      );
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.hint,
    this.onRetry,
    this.retryLabel = 'Tekrar Dene',
    this.extraAction,
  });
  final String message;
  final String hint;
  final VoidCallback? onRetry;
  final String retryLabel;
  final Widget? extraAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.r,
            height: 72.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.error, width: 1.5),
            ),
            child: Icon(Icons.wifi_off_rounded,
                color: AppColors.error, size: 36.r),
          ),
          SizedBox(height: 20.h),
          Text(
            'Bağlantı Hatası',
            style:
                AppTextStyles.headingSmall.copyWith(color: AppColors.error),
          ),
          SizedBox(height: 10.h),
          Text(message,
              style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
              border:
                  Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Text(
              hint,
              style:
                  AppTextStyles.labelSmall.copyWith(color: AppColors.warning),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),
          if (onRetry != null)
            KabelButton(
                label: retryLabel,
                onPressed: onRetry!,
                icon: Icons.refresh_rounded),
          if (extraAction != null) ...[
            SizedBox(height: 8.h),
            extraAction!,
          ],
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
              style:
                  AppTextStyles.labelSmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _MqttInfoRow extends StatelessWidget {
  const _MqttInfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60.w,
          child: Text(label, style: AppTextStyles.bodySmall),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.mono.copyWith(fontSize: 11.sp),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
