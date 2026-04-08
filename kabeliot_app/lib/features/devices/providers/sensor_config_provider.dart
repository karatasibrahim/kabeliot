import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/mqtt/mqtt_service.dart';
import '../../../core/mqtt/mqtt_providers.dart';
import '../domain/device_models.dart';

part 'sensor_config_provider.g.dart';

String _sensorKey(String deviceId, int index) => 'sc_${deviceId}_$index';
String _relayKey(String deviceId, int index) => 'rc_${deviceId}_$index';

// ─── Sensör Yapılandırması ────────────────────────────────────────────────────

@riverpod
class SensorConfigs extends _$SensorConfigs {
  @override
  Future<List<SensorConfig>> build(String deviceId, int sensorCount) async {
    final prefs = await SharedPreferences.getInstance();
    return List.generate(sensorCount, (i) {
      final raw = prefs.getString(_sensorKey(deviceId, i));
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
    await prefs.setString(_sensorKey(deviceId, index), jsonEncode(config.toJson()));
  }
}

// ─── Röle Durumları ───────────────────────────────────────────────────────────

@riverpod
class RelayStates extends _$RelayStates {
  @override
  List<RelayConfig> build(String deviceId, int relayCount) {
    _loadFromPrefs();
    return List.generate(relayCount, (i) => RelayConfig(name: 'Röle ${i + 1}'));
  }

  /// SharedPreferences'tan isim ve enabled durumunu yükle
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final updated = List<RelayConfig>.from(state);
    for (int i = 0; i < state.length; i++) {
      final raw = prefs.getString(_relayKey(deviceId, i));
      if (raw != null) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          updated[i] = RelayConfig(
            name: (map['name'] as String?) ?? 'Röle ${i + 1}',
            isEnabled: (map['isEnabled'] as bool?) ?? false,
            isOn: false,
          );
        } catch (_) {}
      }
    }
    state = updated;
  }

  Future<void> _saveRelay(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _relayKey(deviceId, index),
      jsonEncode({
        'name': state[index].name,
        'isEnabled': state[index].isEnabled,
      }),
    );
  }

  void toggle(int index) {
    if (!state[index].isEnabled) return;
    final updated = [...state];
    final newIsOn = !updated[index].isOn;
    updated[index] = updated[index].copyWith(isOn: newIsOn);
    state = updated;

    final connStatus = ref.read(mqttConnectionProvider);
    if (connStatus == MqttConnectionStatus.connected) {
      final topic = 'kb/$deviceId/relay/$index/set';
      MqttService.instance.publish(topic, newIsOn ? '1' : '0');
    }
  }

  /// Kanalı aktif / pasif yap
  Future<void> setEnabled(int index, bool enabled) async {
    final updated = [...state];
    updated[index] = updated[index].copyWith(isEnabled: enabled, isOn: false);
    state = updated;
    await _saveRelay(index);
  }

  /// Röle adını değiştir
  Future<void> rename(int index, String name) async {
    final updated = [...state];
    updated[index] = updated[index].copyWith(name: name.trim().isEmpty ? 'Röle ${index + 1}' : name.trim());
    state = updated;
    await _saveRelay(index);
  }
}
