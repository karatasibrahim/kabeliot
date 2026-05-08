import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/thingsboard/tb_api_client.dart';
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
  // RPC gönderilen rölelerin timestamp'i — bu süre içinde WS güncellemesi yok sayılır
  final Map<int, DateTime> _rpcSentAt = {};
  static const _rpcDebounce = Duration(seconds: 8);

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
    final keys = List.generate(relayCount, (i) => 'relay_${i}_status');

    _wsSub?.cancel();
    _wsSub = tbWs.subscribeToTelemetry(deviceId, keys).listen((data) {
      final updated = List<RelayConfig>.from(state);
      bool changed = false;
      for (int i = 0; i < updated.length; i++) {
        final key = 'relay_${i}_status';
        if (!data.containsKey(key)) continue;

        final raw = data[key];
        final incoming = raw is bool ? raw : (raw == 1 || raw == true || raw == 'true');

        final sentAt = _rpcSentAt[i];
        if (sentAt != null && DateTime.now().difference(sentAt) < _rpcDebounce) {
          // Debounce aktif:
          // - Gelen değer mevcut optimistic state ile AYNI ise → ESP32 onayladı, debounce kaldır
          // - Farklı ise → eski telemetry, yoksay (optimistic state'i koru)
          if (incoming == state[i].isOn) {
            _rpcSentAt.remove(i); // onaylandı
          } else {
            continue; // optimistic state'i koru
          }
        }

        updated[i] = updated[i].copyWith(isOn: incoming);
        changed = true;
      }
      if (changed) state = updated;
    });
  }

  Future<void> _saveRelay(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _relayKey(deviceId, index),
      jsonEncode({'name': state[index].name, 'isEnabled': state[index].isEnabled}),
    );
  }

  /// Röleyi aç/kapat. Hata mesajı döner (null = başarılı).
  Future<String?> toggle(int index) async {
    if (!state[index].isEnabled) return null;

    // Optimistic update
    final updated = List<RelayConfig>.from(state);
    final newIsOn = !updated[index].isOn;
    updated[index] = updated[index].copyWith(isOn: newIsOn);
    state = updated;

    _rpcSentAt[index] = DateTime.now();
    try {
      final token = await ref.read(tbAuthProvider.future);
      if (token == null) {
        _rpcSentAt.remove(index);
        _revert(index, newIsOn);
        return 'Sunucu bağlantısı yok.';
      }
      final client = TbApiClient(baseUrl: tbBaseUrl, jwtToken: token);
      await client.sendRpcOneway(
        deviceId,
        'setRelay',
        {'relay_id': index, 'state': newIsOn},
      );
      debugPrint('[RelayStates] RPC (oneway) gönderildi: relay_id=$index state=$newIsOn');
      return null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        // Bağlantı koparsa komut yine de iletilmiş olabilir
        debugPrint('[RelayStates] RPC bağlantı timeout: relay_id=$index');
        return null;
      }
      _rpcSentAt.remove(index);
      _revert(index, newIsOn);
      final statusCode = e.response?.statusCode;
      if (statusCode == 409) {
        debugPrint('[RelayStates] Cihaz çevrimdışı (409)');
        return 'Cihaz şu an çevrimdışı.';
      }
      debugPrint('[RelayStates] RPC hatası $statusCode: $e');
      return 'Röle komutu gönderilemedi.';
    } catch (e) {
      _rpcSentAt.remove(index);
      _revert(index, newIsOn);
      return 'Röle komutu gönderilemedi.';
    }
  }

  void _revert(int index, bool failedIsOn) {
    final reverted = List<RelayConfig>.from(state);
    reverted[index] = reverted[index].copyWith(isOn: !failedIsOn);
    state = reverted;
  }

  /// Otomasyon tarafından çağrılır — röleyi belirli bir değere ayarlar.
  Future<void> setRelayTo(int index, bool value) async {
    if (!state[index].isEnabled) return;
    if (state[index].isOn == value) return;

    final updated = List<RelayConfig>.from(state);
    updated[index] = updated[index].copyWith(isOn: value);
    state = updated;

    _rpcSentAt[index] = DateTime.now();
    try {
      final token = await ref.read(tbAuthProvider.future);
      if (token == null) {
        _rpcSentAt.remove(index);
        _revert(index, value);
        return;
      }
      final client = TbApiClient(baseUrl: tbBaseUrl, jwtToken: token);
      await client.sendRpcOneway(
        deviceId,
        'setRelay',
        {'relay_id': index, 'state': value},
      );
      debugPrint('[RelayStates] Otomasyon RPC: relay_id=$index state=$value');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return;
      }
      _rpcSentAt.remove(index);
      _revert(index, value);
    } catch (_) {
      _rpcSentAt.remove(index);
      _revert(index, value);
    }
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
