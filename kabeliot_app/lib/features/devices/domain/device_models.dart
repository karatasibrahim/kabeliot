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

  String get mqttTopic => 'kb/${id.toLowerCase()}';
}

/// Donanım limitleri
const kMaxSensors = 6;
const kMaxRelays = 8;

// ─── Firestore Modelleri ──────────────────────────────────────────────────────

/// Firestore companies/{id}/devices/{deviceId} dökümanı
class FirestoreDevice {
  const FirestoreDevice({
    required this.id,
    required this.deviceStatus,
    this.deviceName,
    this.lastSeen,
  });

  final String id;
  final bool deviceStatus;
  final String? deviceName;
  final DateTime? lastSeen;

  bool get isOnline => deviceStatus;

  static FirestoreDevice fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return FirestoreDevice(
      id: doc.id,
      deviceStatus: (d['device_status'] as bool?) ?? false,
      deviceName: d['device_name'] as String?,
      lastSeen: (d['last_seen'] as Timestamp?)?.toDate(),
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
