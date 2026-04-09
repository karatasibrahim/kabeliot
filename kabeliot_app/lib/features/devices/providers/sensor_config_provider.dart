import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/thingsboard/tb_auth_provider.dart';
import '../../../core/thingsboard/tb_websocket_service.dart';
import '../domain/device_models.dart';

part 'sensor_config_provider.g.dart';

String _sensorKey(String deviceId, int index) => 'sc_${deviceId}_$index';
String _relayKey(String deviceId, int index)  => 'rc_${deviceId}_$index';

// ─── Sensör Yapılandırması (SharedPreferences — kullanıcı tercihleri) ─────────

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

// ─── Röle Durumları — ThingsBoard WebSocket + RPC ────────────────────────────

@riverpod
class RelayStates extends _$RelayStates {
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  @override
  List<RelayConfig> build(String deviceId, int relayCount) {
    _loadFromPrefs();
    _subscribeTb();
    ref.onDispose(() => _wsSub?.cancel());
    return List.generate(relayCount, (i) => RelayConfig(name: 'Röle ${i + 1}'));
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final updated = List<RelayConfig>.from(state);
    for (int i = 0; i < state.length; i++) {
      final raw = prefs.getString(_relayKey(deviceId, i));
      if (raw != null) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          updated[i] = updated[i].copyWith(
            name: (map['name'] as String?) ?? 'Röle ${i + 1}',
            isEnabled: (map['isEnabled'] as bool?) ?? false,
          );
        } catch (_) {}
      }
    }
    state = updated;
  }

  void _subscribeTb() {
    final tbWs = ref.read(tbWebSocketServiceProvider);
    final keys = List.generate(state.length, (i) => 'relay_$i');

    _wsSub?.cancel();
    _wsSub = tbWs.subscribeToTelemetry(deviceId, keys).listen((data) {
      final updated = List<RelayConfig>.from(state);
      for (int i = 0; i < updated.length; i++) {
        final key = 'relay_$i';
        if (data.containsKey(key)) {
          final raw = data[key];
          final isOn = raw is bool ? raw : (raw == 1 || raw == true);
          updated[i] = updated[i].copyWith(isOn: isOn);
        }
      }
      state = updated;
    });
  }

  Future<void> _saveRelay(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _relayKey(deviceId, index),
      jsonEncode({'name': state[index].name, 'isEnabled': state[index].isEnabled}),
    );
  }

  void toggle(int index) {
    if (!state[index].isEnabled) return;

    final updated = List<RelayConfig>.from(state);
    final newIsOn = !updated[index].isOn;
    updated[index] = updated[index].copyWith(isOn: newIsOn);
    state = updated; // optimistic update

    // TB RPC
    final client = ref.read(tbAuthProvider.notifier).apiClient();
    client?.sendRpc(deviceId, 'setRelayState', {'relay': index, 'state': newIsOn});
  }

  Future<void> setEnabled(int index, bool enabled) async {
    final updated = List<RelayConfig>.from(state);
    updated[index] = updated[index].copyWith(isEnabled: enabled, isOn: false);
    state = updated;
    await _saveRelay(index);
  }

  Future<void> rename(int index, String name) async {
    final updated = List<RelayConfig>.from(state);
    updated[index] = updated[index].copyWith(
      name: name.trim().isEmpty ? 'Röle ${index + 1}' : name.trim(),
    );
    state = updated;
    await _saveRelay(index);
  }
}
