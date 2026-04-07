import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'mqtt_service.dart';
import 'mqtt_settings_provider.dart';

part 'mqtt_providers.g.dart';

// ─── Bağlantı Durumu ─────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class MqttConnection extends _$MqttConnection {
  StreamSubscription<MqttConnectionStatus>? _sub;

  @override
  MqttConnectionStatus build() {
    final settingsAsync = ref.watch(mqttSettingsProvider);

    settingsAsync.whenData((settings) {
      _sub?.cancel();
      _connect(settings);
      _sub = MqttService.instance.statusStream.listen((s) {
        state = s;
      });
    });

    ref.onDispose(() {
      _sub?.cancel();
      MqttService.instance.disconnect();
    });

    return MqttConnectionStatus.disconnected;
  }

  Future<void> _connect(MqttSettingsData settings) async {
    if (settings.host.isEmpty) return;
    await MqttService.instance.connect(
      host: settings.host,
      port: settings.port,
      clientId: 'kabel_app_${DateTime.now().millisecondsSinceEpoch}',
      user: settings.user.isEmpty ? null : settings.user,
      password: settings.password.isEmpty ? null : settings.password,
    );
  }

  Future<void> reconnect() async {
    final settings = await ref.read(mqttSettingsProvider.future);
    await _connect(settings);
  }
}

// ─── Cihaz Online/Offline Durumu ─────────────────────────────────────────────

/// Belirli bir cihazın MQTT LWT durumu.
/// Broker bağlı değilse — mock listesindeki `isOnline` değeri döner.
@riverpod
Stream<bool> deviceOnlineStatus(Ref ref, String deviceId) async* {
  final connStatus = ref.watch(mqttConnectionProvider);

  if (connStatus != MqttConnectionStatus.connected) {
    // Fallback: mock değer
    yield _mockOnline(deviceId);
    return;
  }

  final topic = 'kb/$deviceId/status';
  MqttService.instance.subscribe(topic);

  yield* MqttService.instance.messageStream
      .where((m) => m.topic == topic)
      .map((m) => m.payload.trim().toLowerCase() == 'online');
}

bool _mockOnline(String deviceId) {
  const onlineIds = {'KB-001-A2F3', 'KB-002-B1E9', 'KB-004-D4F8', 'KB-006-F9B3'};
  return onlineIds.contains(deviceId);
}

// ─── Sensör Veri Akışı ───────────────────────────────────────────────────────

/// Belirli bir sensörün anlık değer stream'i.
/// MQTT bağlıysa gerçek veri, değilse simülasyon.
@riverpod
Stream<double> sensorValueStream(
    Ref ref, String deviceId, int sensorIndex) async* {
  final connStatus = ref.watch(mqttConnectionProvider);

  if (connStatus == MqttConnectionStatus.connected) {
    final topic = 'kb/$deviceId/sensors/$sensorIndex';
    MqttService.instance.subscribe(topic);

    yield* MqttService.instance.messageStream
        .where((m) => m.topic == topic)
        .map((m) => double.tryParse(m.payload.trim()) ?? 0.0);
  } else {
    // Simülasyon fallback — Timer ile random walk
    yield* _simulateSensor(sensorIndex);
  }
}

Stream<double> _simulateSensor(int sensorIndex) async* {
  final rng = Random();
  double current = _initialValue(sensorIndex);

  while (true) {
    await Future.delayed(const Duration(seconds: 1));
    final delta = (rng.nextDouble() - 0.5) * current * 0.06;
    current = (current + delta)
        .clamp(_minValue(sensorIndex), _maxValue(sensorIndex));
    yield double.parse(current.toStringAsFixed(2));
  }
}

double _initialValue(int idx) => switch (idx % 11) {
      0 => 22.5,
      1 => 58.0,
      2 => 1013.0,
      3 => 220.0,
      4 => 4.5,
      5 => 3200.0,
      6 => 450.0,
      7 => 85.0,
      8 => 12.3,
      9 => 8.5,
      _ => 50.0,
    };

double _minValue(int idx) => switch (idx % 11) {
      2 => 900.0,
      3 => 190.0,
      _ => 0.0,
    };

double _maxValue(int idx) => switch (idx % 11) {
      0 => 80.0,
      1 => 100.0,
      2 => 1100.0,
      3 => 250.0,
      4 => 30.0,
      5 => 10000.0,
      6 => 2000.0,
      7 => 400.0,
      8 => 100.0,
      9 => 50.0,
      _ => 100.0,
    };

// ─── Röle Durum Akışı ────────────────────────────────────────────────────────

/// Belirli bir rölenin durumu (MQTT veya local).
@riverpod
Stream<bool> relayStateStream(
    Ref ref, String deviceId, int relayIndex) async* {
  final connStatus = ref.watch(mqttConnectionProvider);

  if (connStatus == MqttConnectionStatus.connected) {
    final topic = 'kb/$deviceId/relay/$relayIndex/state';
    MqttService.instance.subscribe(topic);

    yield* MqttService.instance.messageStream
        .where((m) => m.topic == topic)
        .map((m) => m.payload.trim() == '1');
  } else {
    yield false;
  }
}
