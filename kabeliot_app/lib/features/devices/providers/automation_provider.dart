import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/device_models.dart';
import 'live_data_provider.dart';
import 'sensor_config_provider.dart';

part 'automation_provider.g.dart';

String _automationKey(String deviceId) => 'automation_$deviceId';

@riverpod
class AutomationRules extends _$AutomationRules {
  Timer? _evalTimer;

  @override
  List<AutomationRule> build(String deviceId) {
    _loadFromPrefs();
    _evalTimer = Timer.periodic(const Duration(seconds: 3), (_) => _evaluate());
    ref.onDispose(() => _evalTimer?.cancel());
    return [];
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_automationKey(deviceId));
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      state = list
          .map((e) => AutomationRule.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _automationKey(deviceId),
      jsonEncode(state.map((r) => r.toJson()).toList()),
    );
  }

  void _evaluate() {
    for (final rule in state.where((r) => r.isEnabled)) {
      final sensorData =
          ref.read(liveSensorDataProvider(deviceId, rule.sensorIndex));
      if (sensorData.isEmpty) continue;

      final currentValue = sensorData.last;
      if (!rule.evaluate(currentValue)) continue;

      final relays =
          ref.read(relayStatesProvider(deviceId, kMaxRelays));
      if (!relays[rule.relayIndex].isEnabled) continue;
      if (relays[rule.relayIndex].isOn == rule.relayAction) continue;

      debugPrint(
        '[Automation] Kural tetiklendi: sensör=${rule.sensorIndex} '
        'değer=$currentValue ${rule.operator.symbol} ${rule.threshold} → '
        'röle=${rule.relayIndex} ${rule.relayAction ? "AÇ" : "KAPAT"}',
      );
      ref
          .read(relayStatesProvider(deviceId, kMaxRelays).notifier)
          .setRelayTo(rule.relayIndex, rule.relayAction);
    }
  }

  Future<void> addRule(AutomationRule rule) async {
    state = [...state, rule];
    await _saveToPrefs();
  }

  Future<void> updateRule(AutomationRule rule) async {
    state = [
      for (final r in state)
        if (r.id == rule.id) rule else r,
    ];
    await _saveToPrefs();
  }

  Future<void> deleteRule(String id) async {
    state = state.where((r) => r.id != id).toList();
    await _saveToPrefs();
  }

  Future<void> toggleEnabled(String id) async {
    state = [
      for (final r in state)
        if (r.id == id) r.copyWith(isEnabled: !r.isEnabled) else r,
    ];
    await _saveToPrefs();
  }
}
