import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/mqtt/mqtt_service.dart';
import '../../../core/mqtt/mqtt_providers.dart';
import '../domain/device_models.dart';

part 'sensor_config_provider.g.dart';

String _key(String deviceId, int index) => 'sc_${deviceId}_$index';

/// Belirli bir cihazın tüm sensörlerinin kullanıcı yapılandırmaları
@riverpod
class SensorConfigs extends _$SensorConfigs {
  @override
  Future<List<SensorConfig>> build(String deviceId, int sensorCount) async {
    final prefs = await SharedPreferences.getInstance();
    return List.generate(sensorCount, (i) {
      final raw = prefs.getString(_key(deviceId, i));
      if (raw == null) return SensorConfig.defaultFor(i);
      try {
        return SensorConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        return SensorConfig.defaultFor(i);
      }
    });
  }

  Future<void> updateConfig(int index, SensorConfig config) async {
    final current = await future;
    final updated = [...current];
    updated[index] = config;
    state = AsyncData(updated);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(deviceId, index), jsonEncode(config.toJson()));
  }
}

/// Röle durumları — toggle MQTT'ye publish eder, optimistic local güncelleme yapar
@riverpod
class RelayStates extends _$RelayStates {
  @override
  List<RelayConfig> build(String deviceId, int relayCount) {
    return List.generate(relayCount, (i) => RelayConfig(name: 'Röle ${i + 1}'));
  }

  void toggle(int index) {
    final updated = [...state];
    final newIsOn = !updated[index].isOn;
    updated[index] = updated[index].copyWith(isOn: newIsOn);
    state = updated;

    // MQTT publish — optimistic: local state zaten güncellendi
    final connStatus = ref.read(mqttConnectionProvider);
    if (connStatus == MqttConnectionStatus.connected) {
      final topic = 'kb/$deviceId/relay/$index/set';
      MqttService.instance.publish(topic, newIsOn ? '1' : '0');
    }
  }

  void rename(int index, String name) {
    final updated = [...state];
    updated[index] = updated[index].copyWith(name: name);
    state = updated;
  }
}
