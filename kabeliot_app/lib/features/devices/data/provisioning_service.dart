import 'dart:io';
import 'package:dio/dio.dart';

/// ESP32 AP modundaki cihazın HTTP adresini temsil eder.
/// ESP32 AP modunda her zaman 192.168.4.1 IP adresini kullanır.
const _esp32BaseUrl = 'http://192.168.4.1';
const _timeoutSec = 8;

/// ESP32 cihaz bilgisi — GET /info
class Esp32DeviceInfo {
  const Esp32DeviceInfo({
    required this.chipId,
    required this.mac,
    required this.firmware,
    required this.model,
    required this.sensorCount,
    required this.relayCount,
  });

  final String chipId;
  final String mac;
  final String firmware;
  final String model;
  final int sensorCount;
  final int relayCount;

  factory Esp32DeviceInfo.fromJson(Map<String, dynamic> j) => Esp32DeviceInfo(
        chipId: j['chipId'] as String? ?? 'UNKNOWN',
        mac: j['mac'] as String? ?? 'XX:XX:XX:XX:XX:XX',
        firmware: j['firmware'] as String? ?? '1.0.0',
        model: j['model'] as String? ?? 'KABEL-ESP32',
        sensorCount: j['sensorCount'] as int? ?? 0,
        relayCount: j['relayCount'] as int? ?? 0,
      );
}

/// Provisioning isteği gövdesi — POST /provision
/// ESP32 sadece WiFi bilgilerini alır; TB token'ını Node-RED'den çeker.
class ProvisioningRequest {
  const ProvisioningRequest({
    required this.wifiSsid,
    required this.wifiPassword,
  });

  final String wifiSsid;
  final String wifiPassword;

  Map<String, dynamic> toJson() => {
        'wifiSsid': wifiSsid,
        'wifiPassword': wifiPassword,
      };
}

/// ESP32 provisioning HTTP istemcisi.
/// Gerçek cihaz olmadığında [ProvisioningService.mock] kullanılır.
class ProvisioningService {
  ProvisioningService._real()
      : _dio = Dio(BaseOptions(
          baseUrl: _esp32BaseUrl,
          connectTimeout: const Duration(seconds: _timeoutSec),
          receiveTimeout: const Duration(seconds: _timeoutSec),
          headers: {'Content-Type': 'application/json'},
        ));

  ProvisioningService._mock() : _dio = null;

  final Dio? _dio;
  bool get _isMock => _dio == null;

  /// Fabrika: Gerçek ESP32 bağlantısı.
  /// ESP32 AP'ine bağlandıktan sonra kullanılır.
  static final real = ProvisioningService._real();

  /// Fabrika: Demo/test modu — gerçek bağlantı yok.
  static final mock = ProvisioningService._mock();

  /// ESP32'nin bilgi endpoint'ini çağırır.
  /// Başarılı olursa [Esp32DeviceInfo] döner.
  /// Hata olursa açıklayıcı exception fırlatır.
  Future<Esp32DeviceInfo> fetchDeviceInfo() async {
    if (_isMock) {
      // Simüle edilmiş gecikme
      await Future.delayed(const Duration(seconds: 2));
      return const Esp32DeviceInfo(
        chipId: 'A2F3',
        mac: 'AA:BB:CC:DD:EE:FF',
        firmware: '1.2.0',
        model: 'KABEL-PCB-v2',
        sensorCount: 3,
        relayCount: 2,
      );
    }

    try {
      final resp = await _dio!.get('/info');
      return Esp32DeviceInfo.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _translateDioError(e);
    }
  }

  /// Fabrika WiFi + MQTT bilgilerini ESP32'ye gönderir.
  /// ESP32 bu bilgileri alır, STA moduna geçer, AP'ini kapatır.
  Future<void> provision(ProvisioningRequest request) async {
    if (_isMock) {
      await Future.delayed(const Duration(seconds: 3));
      return; // Başarılı kabul et
    }

    try {
      await _dio!.post('/wifi-config', data: request.toJson());
    } on DioException catch (e) {
      // 200 dışı veya timeout → ESP32 STA moduna geçince AP kapanır
      // dolayısıyla bağlantı kesilmesi NORMAL bir durumdur
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        // AP kapandı → provision başarılı sayılır
        return;
      }
      throw _translateDioError(e);
    } on SocketException {
      // Bağlantı kesildi → başarılı
      return;
    }
  }

  static String _translateDioError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout => 'ESP32\'ye bağlanılamadı. Cihazın AP modunda olduğundan emin olun.',
      DioExceptionType.connectionError => 'ESP32\'ye ulaşılamadı. Telefonun KABEL WiFi\'ne bağlı olduğunu kontrol edin.',
      DioExceptionType.receiveTimeout => 'ESP32 yanıt vermedi. Tekrar deneyin.',
      _ => 'Bağlantı hatası: ${e.message}',
    };
  }
}
