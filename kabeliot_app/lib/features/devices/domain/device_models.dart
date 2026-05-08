import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Sensör tipi — kullanıcı değiştirebilir
enum SensorType {
  temperature,
  humidity,
  pressure,
  voltage,
  current,
  light,
  airQuality,
  distance,
  weight,
  flow,
  generic,
}

extension SensorTypeExt on SensorType {
  String get label => switch (this) {
        SensorType.temperature => 'Sıcaklık',
        SensorType.humidity => 'Nem',
        SensorType.pressure => 'Basınç',
        SensorType.voltage => 'Voltaj',
        SensorType.current => 'Akım',
        SensorType.light => 'Işık',
        SensorType.airQuality => 'Hava Kalitesi',
        SensorType.distance => 'Mesafe',
        SensorType.weight => 'Ağırlık',
        SensorType.flow => 'Akış',
        SensorType.generic => 'Genel',
      };

  String get defaultUnit => switch (this) {
        SensorType.temperature => '°C',
        SensorType.humidity => '%',
        SensorType.pressure => 'hPa',
        SensorType.voltage => 'V',
        SensorType.current => 'A',
        SensorType.light => 'lux',
        SensorType.airQuality => 'ppm',
        SensorType.distance => 'cm',
        SensorType.weight => 'kg',
        SensorType.flow => 'L/min',
        SensorType.generic => '',
      };

  IconData get icon => switch (this) {
        SensorType.temperature => Icons.thermostat_rounded,
        SensorType.humidity => Icons.water_drop_rounded,
        SensorType.pressure => Icons.speed_rounded,
        SensorType.voltage => Icons.bolt_rounded,
        SensorType.current => Icons.electrical_services_rounded,
        SensorType.light => Icons.light_mode_rounded,
        SensorType.airQuality => Icons.air_rounded,
        SensorType.distance => Icons.straighten_rounded,
        SensorType.weight => Icons.monitor_weight_rounded,
        SensorType.flow => Icons.water_rounded,
        SensorType.generic => Icons.sensors_rounded,
      };

  Color get color => switch (this) {
        SensorType.temperature => const Color(0xFFEF4444),
        SensorType.humidity => const Color(0xFF06B6D4),
        SensorType.pressure => const Color(0xFF8B5CF6),
        SensorType.voltage => const Color(0xFFF59E0B),
        SensorType.current => const Color(0xFFEA580C),
        SensorType.light => const Color(0xFFFBBF24),
        SensorType.airQuality => const Color(0xFF10B981),
        SensorType.distance => const Color(0xFF6366F1),
        SensorType.weight => const Color(0xFFEC4899),
        SensorType.flow => const Color(0xFF0EA5E9),
        SensorType.generic => const Color(0xFF94A3B8),
      };
}

/// Kullanıcının sensör başına özelleştirdiği yapılandırma
class SensorConfig {
  const SensorConfig({
    required this.name,
    required this.type,
    required this.unit,
    this.thresholdMin,
    this.thresholdMax,
    this.notifyOnThreshold = false,
  });

  final String name;
  final SensorType type;
  final String unit;
  final double? thresholdMin;
  final double? thresholdMax;
  final bool notifyOnThreshold;

  SensorConfig copyWith({
    String? name,
    SensorType? type,
    String? unit,
    double? thresholdMin,
    double? thresholdMax,
    bool? notifyOnThreshold,
    bool clearMin = false,
    bool clearMax = false,
  }) =>
      SensorConfig(
        name: name ?? this.name,
        type: type ?? this.type,
        unit: unit ?? this.unit,
        thresholdMin: clearMin ? null : (thresholdMin ?? this.thresholdMin),
        thresholdMax: clearMax ? null : (thresholdMax ?? this.thresholdMax),
        notifyOnThreshold: notifyOnThreshold ?? this.notifyOnThreshold,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.index,
        'unit': unit,
        'thresholdMin': thresholdMin,
        'thresholdMax': thresholdMax,
        'notifyOnThreshold': notifyOnThreshold,
      };

  factory SensorConfig.fromJson(Map<String, dynamic> j) => SensorConfig(
        name: j['name'] as String,
        type: SensorType.values[j['type'] as int],
        unit: j['unit'] as String,
        thresholdMin: j['thresholdMin'] as double?,
        thresholdMax: j['thresholdMax'] as double?,
        notifyOnThreshold: j['notifyOnThreshold'] as bool? ?? false,
      );

  factory SensorConfig.defaultFor(int index) {
    final type = SensorType.values[index % SensorType.values.length];
    return SensorConfig(
      name: '${type.label} ${index + 1}',
      type: type,
      unit: type.defaultUnit,
    );
  }
}

/// Röle yapılandırması
class RelayConfig {
  const RelayConfig({required this.name, this.isOn = false, this.isEnabled = false});
  final String name;
  final bool isOn;
  final bool isEnabled; // kullanıcı bu kanalı aktif etti mi?

  RelayConfig copyWith({String? name, bool? isOn, bool? isEnabled}) =>
      RelayConfig(
        name: name ?? this.name,
        isOn: isOn ?? this.isOn,
        isEnabled: isEnabled ?? this.isEnabled,
      );
}

/// Mock cihaz modeli
class DeviceModel {
  const DeviceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.isOnline,
    required this.sensorCount,
    required this.relayCount,
    this.firmware = '1.2.0',
    this.ipAddress = '192.168.1.100',
    this.tbDeviceId,
  });

  final String id;
  final String name;
  final String type;
  final String category;
  final bool isOnline;
  final int sensorCount;
  final int relayCount;
  final String firmware;
  final String ipAddress;
  /// ThingsBoard device UUID — used for WebSocket subscriptions and RPC calls
  final String? tbDeviceId;

  String get mqttTopic => 'kb/${id.toLowerCase()}';
}

/// Donanım limitleri
const kMaxSensors = 6;
const kMaxRelays = 8;

// ─── Otomasyon ────────────────────────────────────────────────────────────────

enum RuleOperator { lt, gt, eq, lte, gte }

extension RuleOperatorExt on RuleOperator {
  String get symbol => switch (this) {
        RuleOperator.lt  => '<',
        RuleOperator.gt  => '>',
        RuleOperator.eq  => '=',
        RuleOperator.lte => '≤',
        RuleOperator.gte => '≥',
      };

  String get label => switch (this) {
        RuleOperator.lt  => 'küçükse',
        RuleOperator.gt  => 'büyükse',
        RuleOperator.eq  => 'eşitse',
        RuleOperator.lte => 'küçük/eşitse',
        RuleOperator.gte => 'büyük/eşitse',
      };
}

class AutomationRule {
  const AutomationRule({
    required this.id,
    required this.sensorIndex,
    required this.operator,
    required this.threshold,
    required this.relayIndex,
    required this.relayAction,
    this.isEnabled = true,
  });

  final String id;
  final int sensorIndex;
  final RuleOperator operator;
  final double threshold;
  final int relayIndex;
  final bool relayAction; // true = aç, false = kapat

  final bool isEnabled;

  bool evaluate(double value) => switch (operator) {
        RuleOperator.lt  => value < threshold,
        RuleOperator.gt  => value > threshold,
        RuleOperator.eq  => (value - threshold).abs() < 0.001,
        RuleOperator.lte => value <= threshold,
        RuleOperator.gte => value >= threshold,
      };

  AutomationRule copyWith({
    int? sensorIndex,
    RuleOperator? operator,
    double? threshold,
    int? relayIndex,
    bool? relayAction,
    bool? isEnabled,
  }) =>
      AutomationRule(
        id: id,
        sensorIndex: sensorIndex ?? this.sensorIndex,
        operator: operator ?? this.operator,
        threshold: threshold ?? this.threshold,
        relayIndex: relayIndex ?? this.relayIndex,
        relayAction: relayAction ?? this.relayAction,
        isEnabled: isEnabled ?? this.isEnabled,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sensorIndex': sensorIndex,
        'operator': operator.name,
        'threshold': threshold,
        'relayIndex': relayIndex,
        'relayAction': relayAction,
        'isEnabled': isEnabled,
      };

  factory AutomationRule.fromJson(Map<String, dynamic> j) => AutomationRule(
        id: j['id'] as String,
        sensorIndex: j['sensorIndex'] as int,
        operator: RuleOperator.values.firstWhere((e) => e.name == j['operator']),
        threshold: (j['threshold'] as num).toDouble(),
        relayIndex: j['relayIndex'] as int,
        relayAction: j['relayAction'] as bool,
        isEnabled: (j['isEnabled'] as bool?) ?? true,
      );
}

// ─── Firestore Modelleri ──────────────────────────────────────────────────────

/// Firestore companies/{id}/devices/{deviceId} dökümanı
class FirestoreDevice {
  const FirestoreDevice({
    required this.id,
    required this.deviceStatus,
    this.deviceName,
    this.lastSeen,
    this.tbDeviceId,
    this.tbAccessToken,
    this.tbCustomerToken,
  });

  final String id;
  final bool deviceStatus;
  final String? deviceName;
  final DateTime? lastSeen;
  /// ThingsBoard device UUID — set during provisioning
  final String? tbDeviceId;
  /// ThingsBoard MQTT access token — Node-RED reads this to serve ESP32
  final String? tbAccessToken;
  /// ThingsBoard customer JWT token — customer-level API auth
  final String? tbCustomerToken;

  bool get isOnline => deviceStatus;

  static FirestoreDevice fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return FirestoreDevice(
      id: doc.id,
      deviceStatus: (d['device_status'] as bool?) ?? false,
      deviceName: d['device_name'] as String?,
      lastSeen: (d['last_seen'] as Timestamp?)?.toDate(),
      tbDeviceId: d['tb_device_id'] as String?,
      tbAccessToken: d['tb_access_token'] as String?,
      tbCustomerToken: d['tb_customer_token'] as String?,
    );
  }
}

/// Firestore …/devices/{id}/sensors/{sensorId} dökümanı
class FirestoreSensor {
  const FirestoreSensor({
    required this.id,
    required this.value,
    required this.sensorName,
    required this.readingTime,
    this.alert,
  });

  final String id;
  final double value;
  final String sensorName;
  final DateTime readingTime;
  final Map<String, dynamic>? alert;

  static FirestoreSensor fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return FirestoreSensor(
      id: doc.id,
      value: ((d['value'] ?? 0) as num).toDouble(),
      sensorName: (d['sensor_name'] as String?) ?? '',
      readingTime: (d['reading_time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      alert: d['alert'] as Map<String, dynamic>?,
    );
  }
}

/// Firestore …/devices/{id}/relays/{relayId} dökümanı
class FirestoreRelay {
  const FirestoreRelay({
    required this.id,
    required this.relayStatus,
    required this.relayName,
    this.readingTime,
  });

  final String id;
  final bool relayStatus;
  final String relayName;
  final DateTime? readingTime;

  static FirestoreRelay fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return FirestoreRelay(
      id: doc.id,
      relayStatus: (d['relay_status'] as bool?) ?? false,
      relayName: (d['relay_name'] as String?) ?? '',
      readingTime: (d['reading_time'] as Timestamp?)?.toDate(),
    );
  }
}
