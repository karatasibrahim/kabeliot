import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/firebase/device_repository.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../domain/device_models.dart';

part 'sensor_config_provider.g.dart';

String _sensorKey(String deviceId, int index) => 'sc_${deviceId}_$index';
String _relayKey(String deviceId, int index) => 'rc_${deviceId}_$index';

final _repo = DeviceRepository();

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

// ─── Röle Durumları — Firestore + SharedPreferences ──────────────────────────

@riverpod
class RelayStates extends _$RelayStates {
  StreamSubscription<List<FirestoreRelay>>? _firestoreSub;

  @override
  List<RelayConfig> build(String deviceId, int relayCount) {
    _loadFromPrefs();
    _subscribeFirestore();
    ref.onDispose(() => _firestoreSub?.cancel());
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
          updated[i] = updated[i].copyWith(
            name: (map['name'] as String?) ?? 'Röle ${i + 1}',
            isEnabled: (map['isEnabled'] as bool?) ?? false,
          );
        } catch (_) {}
      }
    }
    state = updated;
  }

  /// Firestore'daki relay_status değişikliklerini dinle
  void _subscribeFirestore() {
    final session = ref.read(authStateProvider);
    if (session == null) return;

    _firestoreSub?.cancel();
    _firestoreSub = _repo
        .watchRelays(session.companyId, deviceId)
        .listen((firestoreRelays) {
      final updated = List<RelayConfig>.from(state);
      for (int i = 0; i < firestoreRelays.length && i < updated.length; i++) {
        updated[i] = updated[i].copyWith(isOn: firestoreRelays[i].relayStatus);
        // Firestore'daki relay_name'i de kullan (eğer SharedPrefs'te özel isim yoksa)
        if (updated[i].name == 'Röle ${i + 1}' && firestoreRelays[i].relayName.isNotEmpty) {
          updated[i] = updated[i].copyWith(name: firestoreRelays[i].relayName);
        }
      }
      state = updated;
    });
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
    final session = ref.read(authStateProvider);

    final updated = List<RelayConfig>.from(state);
    final newIsOn = !updated[index].isOn;
    updated[index] = updated[index].copyWith(isOn: newIsOn);
    state = updated;

    // Firestore'a yaz (optimistic — state zaten güncellendi)
    if (session != null && index < _firestoreRelayIds.length) {
      _repo.updateRelayStatus(
        session.companyId,
        deviceId,
        _firestoreRelayIds[index],
        newIsOn,
      );
    }
  }

  // Firestore'dan gelen relay doc ID'lerini tut (toggle için gerekli)
  final List<String> _firestoreRelayIds = [];

  /// Kanalı aktif / pasif yap
  Future<void> setEnabled(int index, bool enabled) async {
    final updated = List<RelayConfig>.from(state);
    updated[index] = updated[index].copyWith(isEnabled: enabled, isOn: false);
    state = updated;
    await _saveRelay(index);
  }

  /// Röle adını değiştir
  Future<void> rename(int index, String name) async {
    final updated = List<RelayConfig>.from(state);
    updated[index] = updated[index].copyWith(
      name: name.trim().isEmpty ? 'Röle ${index + 1}' : name.trim(),
    );
    state = updated;
    await _saveRelay(index);
  }
}
